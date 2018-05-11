//
//  LoginViewController.swift
//  Mito 1.0
//
//  Created by Benny on 2/25/18.
//  Copyright © 2018 Benny Souriyadeth. All rights reserved.
//

import UIKit
import UserNotifications
import Alamofire
import GooglePlaces

class LoginViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate {
    
    var placesClient: GMSPlacesClient!
    
    // http://uigarage.net/wp-content/uploads/2016/10/2016-09-10-12.00.44.png
    
    @IBAction func textFieldPasswordChecker(_ sender: Any) {
        if fnPasswordLessThanSixCharacters(text: passwordSU.text!) {
            passwordSU.textColor = UIColor.red
        } else {
            passwordSU.textColor = UIColor.black
        }
    }
    
    func fnPasswordLessThanSixCharacters(text: String) -> Bool {
        var result = false
        if text.count < 6 {
            result = true
        }
        return result
    }
    
    @IBAction func textFieldConfirmPassword(_ sender: Any) {
        if fnPasswordsDoNotMatch(text: passwordConfSU.text!) {
            passwordSU.textColor = UIColor.red
            passwordConfSU.textColor = UIColor.red
        } else {
            passwordSU.textColor = UIColor.black
            passwordConfSU.textColor = UIColor.black
        }
    }
    
    func fnPasswordsDoNotMatch(text: String) -> Bool {
        var result = false
        if text != passwordSU.text {
            result = true
        }
        return result
    }
    
    @IBAction func textFieldVerifyEmail(_ sender: Any) {
        if !fnVerifyEmail(text: userEmailSU.text!) {
            userEmailSU.textColor = UIColor.red
        } else {
            userEmailSU.textColor = UIColor.black
        }
    }
    
    func fnVerifyEmail(text: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: text)
    }
    
    @IBOutlet weak var username: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var monthPicker: UIPickerView!
    @IBOutlet weak var btnMonth: UIButton!
    @IBOutlet weak var btnNext: UIButton!
    @IBOutlet weak var confirmPicker: UIStackView!
    @IBOutlet weak var confirmStatePicker: UIStackView!
    
    var appdata = AppData.shared
    
    @IBAction func btnBirthdayPressed(_ sender: Any) {
        if monthPicker.isHidden == true {
            monthPicker.isHidden = false
            confirmPicker.isHidden = false
            btnNext.isHidden = true
        }
        monthPicker.selectRow(2, inComponent: 0, animated: false) // Pre-select row not working
        appdata.arrMonths.sort(by: fnSortMonthsByNumber)
        appdata.arrYears.sort(by: fnSortYearChronologically)
    }
    
    @IBAction func btnSelectBirthdayDone(_ sender: Any) {
        monthPicker.isHidden = true
        confirmPicker.isHidden = true
        btnNext.isHidden = false
        strMonth = String(appdata.arrMonths[monthPicker.selectedRow(inComponent: 0)].intNum)
        strDay = appdata.arrDays[monthPicker.selectedRow(inComponent: 1)]
        strYear = appdata.arrYears[monthPicker.selectedRow(inComponent: 2)]
        strUserDOB = "\(strMonth)/\(strDay)/\(strYear)"
        btnMonth.setTitle(strUserDOB, for: .normal)
    }
    
    @IBAction func btnSelectStateDone(_ sender: Any) {
        pickerviewStateAA.isHidden = true
        confirmStatePicker.isHidden = true
        let objStateSelected = appdata.arrStates[pickerviewStateAA.selectedRow(inComponent: 0)]
        strState = objStateSelected.value
        btnChooseState.setTitle(objStateSelected.abbrev, for: .normal)
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        if monthPicker != nil && !monthPicker.isHidden {
            return 3
        }
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if monthPicker != nil && !monthPicker.isHidden {
            if component == 0 {
                return appdata.arrMonths.count
            } else if component == 1 {
                return appdata.arrDays.count
            } else {
                return appdata.arrYears.count
            }
        } else if (pickerviewStateAA != nil) && !pickerviewStateAA.isHidden {
            return appdata.arrStates.count
        } else {
            return 1
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if monthPicker != nil && !monthPicker.isHidden {
            if component == 0 {
                return appdata.arrMonths[row].strName
            } else if component == 1 {
                return appdata.arrDays[row]
            } else {
                return appdata.arrYears[row]
            }
        } else if pickerviewStateAA != nil && !pickerviewStateAA.isHidden {
            return appdata.arrStates[row].value
        } else {
            return ""
        }
    }
    
    // Opening Login Page
    @IBAction func btnLoginPressed(_ sender: Any) {
        let parameters: Parameters = [
            "usercred": username.text!,
            "password": password.text!
        ]
        
        Alamofire.request("https://api.projectmito.io/v1/sessions", method: .post, parameters: parameters, encoding: JSONEncoding.default).validate().responseJSON { response in
            switch response.result {
            case .success:
                // http url response
                let authHeader = response.response?.allHeaderFields["Authorization"] as! String
                if !authHeader.isEmpty {
                    if let dictionary = response.result.value {
                        DispatchQueue.main.async {
                            self.performSegue(withIdentifier: "login", sender: self)
                            UserDefaults.standard.set(dictionary, forKey: "UserInfo")
                            UserDefaults.standard.set(authHeader, forKey: "Authorization")
                            if UserDefaults.standard.object(forKey: "UserInfo") != nil {
                                let data = UserDefaults.standard.object(forKey: "UserInfo") as! NSDictionary
                                self.appdata.intCurrentUserID = (data["userId"] as? Int)!
                                print("UserInfo: \(String(describing: data["UserInfo"]))")
                                print("UserID: \(String(describing: data["userId"]))")
                            }
//                            let data = UserDefaults.standard.object(forKey: "UserInfo") as! NSDictionary
                            
                        }
                    }
                }
                
                
            case .failure(let error):
                let alert = self.appdata.fnDisplayAlert(title: "Whoops!", message: "Incorrect email or password")
                self.present(alert, animated: true, completion: nil)
                print(error)
            }
        }

    }
    
    @IBAction func btnSignUpPressed(_ sender: Any) {
        self.performSegue(withIdentifier: "signup", sender: self)
        let date = Date()
        let calendar = Calendar.current
        let year = calendar.component(.year, from: date)
        appdata.arrYears.removeAll()
        for num in 1900...year {
            appdata.arrYears.append(String(num))
        }
        appdata.arrMonths.removeAll()
        appdata.arrStates.removeAll()
        appdata.fnLoadMonthData()
        appdata.fnLoadStateData()
    }
    
    // Sign up page
    
    @IBOutlet weak var userFnameSU: UITextField!
    @IBOutlet weak var strLastName: UITextField!
    @IBOutlet weak var usernameSU: UITextField!
    @IBOutlet weak var passwordSU: UITextField!
    @IBOutlet weak var passwordConfSU: UITextField!
    @IBOutlet weak var userEmailSU: UITextField!
    
    @IBOutlet weak var signupScrollView: UIScrollView!
    @IBOutlet weak var addressScrollView: UIScrollView!
    
    var strMonth = ""
    var strDay = ""
    var strYear = ""
    var strUserDOB = ""
    
    @IBAction func btnNextPressed(_ sender: Any) {
        let strFirstName = userFnameSU.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        let strLastName = self.strLastName.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        let strUserName = usernameSU.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        let strPassword = passwordSU.text
        let strPasswordConfirmation = passwordConfSU.text
        let strEmail = userEmailSU.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        let strUserDOB = "\(strMonth)/\(strDay)/\(strYear)"
        
        let parameters: Parameters = [
            "userFname": strFirstName!,
            "userLname": strLastName!,
            "username": strUserName!,
            "userEmail": strEmail!,
            "password": strPassword!,
            "passwordConf": strPasswordConfirmation!,
            "userDOB": strUserDOB
        ]
        
        self.appdata.tempAccountHolder = parameters
        print("Temp Account Holder: \(self.appdata.tempAccountHolder)")
    
        Alamofire.request("https://api.projectmito.io/v1/users/validate", method: .post, parameters: parameters, encoding: JSONEncoding.default).validate().responseJSON { response in
            switch response.result {
            case .success:
                if response.result.value != nil {
                    self.performSegue(withIdentifier: "signUpToAddress", sender: self)
                }

            case .failure(let error):
                if let data = response.data, let utf8Text = String(data: data, encoding: .utf8) {
                    if utf8Text.contains("username") {
                        self.usernameSU.textColor = UIColor.red
                    } else if utf8Text.contains("email") {
                        self.userEmailSU.textColor = UIColor.red
                    }
                }
                print(error)
            }
        }
    }
    
    // Add Address page
    
    @IBOutlet weak var addressNickname: UITextField!
    @IBOutlet weak var address1AA: UITextField!
    @IBOutlet weak var address2AA: UITextField!
    @IBOutlet weak var cityAA: UITextField!
    @IBOutlet weak var stateAA: UITextField!
    @IBOutlet weak var zipcodeAA: UITextField!
    @IBOutlet weak var pickerviewStateAA: UIPickerView!
    @IBOutlet weak var btnChooseState: UIButton!
    
    var strState = ""
    
    @IBAction func btnCreateAccountPressed(_ sender: Any) {
        var userID: Int?
        

        print("global var: \(self.appdata.tempAccountHolder)")

        let parametersAccount : Parameters = self.appdata.tempAccountHolder
        
        print("parametersAccount: \(parametersAccount)")
        
        Alamofire.request("https://api.projectmito.io/v1/users", method: .post, parameters: parametersAccount, encoding: JSONEncoding.default).validate().responseJSON { response in
            switch response.result {
            case .success:
                // http url response
                let authHeader = response.response?.allHeaderFields["Authorization"] as! String
                if !authHeader.isEmpty {
                    if let dictionary = response.result.value {
                        print("JSON: \(dictionary)") // serialized json response
                        //                    self.performSegue(withIdentifier: "signUpToAddress", sender: self)
                        DispatchQueue.main.async {
                            UserDefaults.standard.set(dictionary, forKey: "UserInfo")
                            UserDefaults.standard.set(authHeader, forKey: "Authorization")
                            if UserDefaults.standard.object(forKey: "UserInfo") != nil {
                                let data = UserDefaults.standard.object(forKey: "UserInfo") as! NSDictionary
                                self.appdata.intCurrentUserID = (data["userId"] as? Int)!
                            }
                            
                            if UserDefaults.standard.object(forKey: "UserInfo") != nil {
                                let data = UserDefaults.standard.object(forKey: "UserInfo") as! NSDictionary
                                userID = data["userId"] as? Int
                                print("data = \(data)")
                                print("userId = \(String(describing: data["userId"]))")
                                self.appdata.intCurrentUserID = userID!
                            }
                            let alias = self.addressNickname.text
                            let strAddress1 = self.address1AA.text
                            let strAddress2 = self.address2AA.text
                            let strCity = self.cityAA.text
                            let strState = self.stateAA.text
                            let zipcode = self.zipcodeAA.text
                            
                            let parametersAddress: Parameters = [
                                "userId": userID!,
                                "streetAddress1": strAddress1!,
                                "streetAddress2": strAddress2!,
                                "cityName": strCity!,
                                "zipCode": zipcode!,
                                "stateName": strState!,
                                "aliasName": alias!
                            ]
                            
                            self.addAddress(parameterAddress: parametersAddress)
                        }
                    }
                }
                

            case .failure(let error):
                print(error)
            }
        }
    }
    
    func addAddress(parameterAddress: Parameters) {
        let headers: HTTPHeaders = [
            "Authorization": UserDefaults.standard.object(forKey: "Authorization") as! String
        ]
    
        Alamofire.request("https://api.projectmito.io/v1/address", method: .post, parameters: parameterAddress, encoding: JSONEncoding.default, headers: headers).validate().responseJSON { response in
            switch response.result {
                case .success:
                    if let dictionary = response.result.value {
                        print("JSON: \(dictionary)") // serialized json response
                        DispatchQueue.main.async {
                            self.performSegue(withIdentifier: "createAccount", sender: self)
                        }
                    }
    
                case .failure(let error):
                    print(error)
            }
        }
    }
    
    @IBAction func btnStatePressed(_ sender: Any) {
        if pickerviewStateAA.isHidden {
            pickerviewStateAA.isHidden = false
            confirmStatePicker.isHidden = false
        }
        appdata.arrStates.sort(by: fnSortStateAlphabetically)
    }
   
    
    //////////// Keyboard Functions, Superview ////////

    func fnSortMonthsByNumber(this: Month, that: Month) -> Bool {
        return this.intNum < that.intNum
    }
    
    func fnSortStateAlphabetically(this: State, that: State) -> Bool {
        return this.value < that.value
    }
    
    func fnSortYearChronologically(this: String, that: String) -> Bool {
        return Int(this)! > Int(that)!
    }
    
    var activeTextField: UITextField!
    
    override func viewDidLoad() {
        if monthPicker != nil {
            monthPicker.isHidden = true
            monthPicker.delegate = self
            monthPicker.dataSource = self
        } else if pickerviewStateAA != nil {
            pickerviewStateAA.isHidden = true
            pickerviewStateAA.delegate = self
            pickerviewStateAA.dataSource = self
        }
        if zipcodeAA != nil {
            zipcodeAA.keyboardType = UIKeyboardType.decimalPad
        }
        super.viewDidLoad()
        if signupScrollView != nil {
            signupScrollView.keyboardDismissMode = .onDrag
        }
        if addressScrollView != nil {
            addressScrollView.keyboardDismissMode = .onDrag
        }
        self.hideKeyboard()
        
        NotificationCenter.default.addObserver(self, selector: #selector(LoginViewController.keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(LoginViewController.keyboardWillShow), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    
    }
    
//    override func viewWillDisappear(_ animated: Bool) {
//        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: self.view.window)
//        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: self.view.window)
//    }
    
    // add textfield as delegate of viewcontroller first
    // increment tags to delegate which uitextfield will be active after pressing return
    // Only shifts up if tag is > 3
    // --> want to be able to change to "if uitextfield is height of keyboard" 
    // Start Editing The Text Field
    func textFieldDidBeginEditing(_ textField: UITextField) {
        print("Your textfield position : \(textField.frame)") // (x,y,width,height)
        //print("Your stack position : \(userpassstack.frame)")
        if textField.tag > 3 {
            moveTextField(textField, moveDistance: -200, up: true)
            print("Hey i entered")
        }
    }
    
    @IBOutlet weak var userpassstack: UIStackView!
    
    // Finish Editing The Text Field
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField.tag > 3 {
            moveTextField(textField, moveDistance: 200, up: true)
            print("hey i ended")
        }
    }
    
    // Hide the keyboard when the return key pressed
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        let nextTag = textField.tag + 1
        if let nextResponder = textField.superview?.viewWithTag(nextTag) {
            nextResponder.becomeFirstResponder()
            print("next yo")
        } else {
            textField.resignFirstResponder()
        }
        return true
    }
    
    // Move the text field in a pretty animation!
    func moveTextField(_ textField: UITextField, moveDistance: Int, up: Bool) {
        let moveDuration = 0.3
        let movement: CGFloat = CGFloat(up ? moveDistance : -moveDistance)
        
        UIView.beginAnimations("animateTextField", context: nil)
        UIView.setAnimationBeginsFromCurrentState(true)
        UIView.setAnimationDuration(moveDuration)
        self.view.frame = self.view.frame.offsetBy(dx: 0, dy: movement)
        UIView.commitAnimations()
    }
    
    @objc func keyboardWillShow(sender: NSNotification) {
       // let keyboardFrame:CGRect = (userInfo[UIKeyboardFrameBeginUserInfoKey] as! NSValue).CGRectValue()
    }
    
}

extension UIViewController {
    func hideKeyboard() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
    }

    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}
