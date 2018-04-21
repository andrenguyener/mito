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

class LoginViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate {
    
    // Error-Handling
    // Name constraints?
    // username should throw error if username is already taken, green checkmark if valid?
    // http://uigarage.net/wp-content/uploads/2016/10/2016-09-10-12.00.44.png
    // two passwords must be equal
    // send email to verify real email, code to determine if email is valid
    // State dropdown
    // Verify real address before continuing?
    
    
    @IBOutlet weak var username: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var monthPicker: UIPickerView!
    @IBOutlet weak var btnMonth: UIButton!
    @IBOutlet weak var btnNext: UIButton!
    @IBOutlet weak var confirmPicker: UIStackView!
    @IBOutlet weak var confirmStatePicker: UIStackView!
    
    var urlStates = URL(string: "https://api.myjson.com/bins/penjf") // JSON file containing US states
    var urlMonths = URL(string: "https://api.myjson.com/bins/1175mz") // JSON file containing months
    var appdata = AppData.shared
    
    @IBAction func btnBirthdayPressed(_ sender: Any) {
        if monthPicker.isHidden == true {
            monthPicker.isHidden = false
            confirmPicker.isHidden = false
            btnNext.isHidden = true
        }
        monthPicker.selectRow(2, inComponent: 0, animated: false) // Pre-select row not working
        appdata.arrMonths.sort(by: fnSortMonthsByNumber)
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

    
//    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
//        if monthPicker != nil && !monthPicker.isHidden {
//            monthPicker.isHidden = true
//            confirmPicker.isHidden = true
//            btnNext.isHidden = false
//            strMonth = String(appdata.arrMonths[row].intNum)
//            strDay = appdata.arrDays[monthPicker.selectedRow(inComponent: 1)]
//            strYear = appdata.arrYears[monthPicker.selectedRow(inComponent: 2)]
//            strUserDOB = "\(strMonth)/\(strDay)/\(strYear)"
//            btnMonth.setTitle(strUserDOB, for: .normal)
//        } else if pickerviewStateAA != nil && !pickerviewStateAA.isHidden {
//            pickerviewStateAA.isHidden = true
//            strState = appdata.arrStates[row].value
//            btnChooseState.setTitle(appdata.arrStates[row].abbrev, for: .normal)
//        }
//    }
    
    // Opening Login Page
    @IBAction func btnLoginPressed(_ sender: Any) {
        let parameters: Parameters = [
            "userEmail": username.text!,
            "password": password.text!
        ]
        
        Alamofire.request("https://api.projectmito.io/v1/sessions", method: .post, parameters: parameters, encoding: JSONEncoding.default).validate().responseJSON { response in
            switch response.result {
            case .success:
                // http url response
                let authHeader = response.response?.allHeaderFields["Authorization"] ?? ""
                if let dictionary = response.result.value {
                    DispatchQueue.main.async {
                        self.performSegue(withIdentifier: "login", sender: self)
                        UserDefaults.standard.set(dictionary, forKey: "UserInfo")
                        UserDefaults.standard.set(authHeader, forKey: "Authorization")
                        if UserDefaults.standard.object(forKey: "UserInfo") != nil {
                            let data = UserDefaults.standard.object(forKey: "UserInfo") as! NSDictionary
                            self.appdata.intCurrentUserID = (data["userId"] as? Int)!
                        }
                    }
                }
                
            case .failure(let error):
                print(error)
            }
        }

    }
    
    @IBAction func btnSignUpPressed(_ sender: Any) {
        self.performSegue(withIdentifier: "signup", sender: self)
        self.fnLoadMonthData()
        self.fnLoadStateData()
    }
    
    // Sign up page
    
    @IBOutlet weak var userFnameSU: UITextField!
    @IBOutlet weak var strLastName: UITextField!
    @IBOutlet weak var usernameSU: UITextField!
    @IBOutlet weak var passwordSU: UITextField!
    @IBOutlet weak var passwordConfSU: UITextField!
    @IBOutlet weak var userEmailSU: UITextField!
    
    @IBOutlet weak var signupScrollView: UIScrollView!
    
    var strMonth = ""
    var strDay = ""
    var strYear = ""
    var strUserDOB = ""
    
    @IBAction func btnNextPressed(_ sender: Any) {
        let strFirstName = userFnameSU.text
        let strLastName = self.strLastName.text
        let strUserName = usernameSU.text
        let strPassword = passwordSU.text
        let strPasswordConfirmation = passwordConfSU.text
        let strEmail = userEmailSU.text
        let strUserDOB = "\(strMonth)/\(strDay)/\(strYear)"
        print(strUserDOB)
        
        // Should have last name field so we don't default to Smith
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
        print(self.appdata.tempAccountHolder)
    
        Alamofire.request("https://api.projectmito.io/v1/users/validate", method: .post, parameters: parameters, encoding: JSONEncoding.default).validate().responseJSON { response in
            switch response.result {
            case .success:
                // http url response
                if let dictionary = response.result.value {
                    print("JSON: \(dictionary)") // serialized json response
                    self.performSegue(withIdentifier: "signUpToAddress", sender: self)
                    
                }

            case .failure(let error):
                print(error)
            }
        }

//        Alamofire.request("https://api.projectmito.io/v1/users", method: .post, parameters: parameters, encoding: JSONEncoding.default).validate().responseJSON { response in
//            switch response.result {
//            case .success:
//                // http url response
//                let authHeader = response.response?.allHeaderFields["Authorization"] ?? ""
//                if let dictionary = response.result.value {
//                    print("JSON: \(dictionary)") // serialized json response
//                    self.performSegue(withIdentifier: "signUpToAddress", sender: self)
//                    DispatchQueue.main.async {
//                        UserDefaults.standard.set(dictionary, forKey: "UserInfo")
//                        UserDefaults.standard.set(authHeader, forKey: "Authorization")
//                        if UserDefaults.standard.object(forKey: "UserInfo") != nil {
//                            let data = UserDefaults.standard.object(forKey: "UserInfo") as! NSDictionary
//                            self.appdata.intCurrentUserID = (data["userId"] as? Int)!
//                        }
//                    }
//                }
//
//            case .failure(let error):
//                print(error)
//            }
//        }
    }
    
    // Add Address page
    
    @IBOutlet weak var addressNickname: UITextField!
    @IBOutlet weak var address1AA: UITextField!
    @IBOutlet weak var address2AA: UITextField!
    @IBOutlet weak var cityAA: UITextField!
    @IBOutlet weak var stateAA: UITextField! // can't figure out what this is
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
                let authHeader = response.response?.allHeaderFields["Authorization"] ?? ""
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
                            //                    UserDefaults.standard.set(dictionary, forKey: "AddressInfo")
                            //                    print(UserDefaults.standard.object(forKey: "AddressInfo") as! NSDictionary)
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
    

    func fnLoadStateData() {
        Alamofire.request(urlStates!, method: .get, encoding: JSONEncoding.default).validate().responseJSON { response in
            switch response.result {
            case .success:
                if let dictionary = response.result.value as! NSDictionary?{
                    for obj in dictionary {
                        let stateObj = State(abbrev: obj.key as! String, value: obj.value as! String)
                        self.appdata.arrStates.append(stateObj)
                    }
                }
                
            case .failure(let error):
                print("Get all users error")
                print(error)
            }
        }
    }
    
    func fnLoadMonthData() {
        Alamofire.request(urlMonths!, method: .get, encoding: JSONEncoding.default).validate().responseJSON { response in
            switch response.result {
            case .success:
                if let dictionary = response.result.value as! NSDictionary?{
                    for obj in dictionary {
                        let objMonthValues = obj.value as! NSDictionary
                        let objMonth = Month(strName: objMonthValues["name"] as! String, strAbbrev: objMonthValues["short"] as! String, strNum: objMonthValues["number"] as! String, intNumDays: objMonthValues["days"] as! Int)
                        self.appdata.arrMonths.append(objMonth)
                    }
                    
                }
                
            case .failure(let error):
                print("Get all users error")
                print(error)
            }
        }
    }
    
    func fnSortMonthsByNumber(this: Month, that: Month) -> Bool {
        return this.intNum < that.intNum
    }
    
    func fnSortStateAlphabetically(this: State, that: State) -> Bool {
        return this.value < that.value
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
        super.viewDidLoad()
        self.hideKeyboard()
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
