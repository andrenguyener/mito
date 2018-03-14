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

class LoginViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
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
    
    var appdata = AppData.shared
    var months = ["January", "February", "March", "April", "May", "June", "July", "August",
                    "September", "October", "November", "December"]
    
    @IBAction func monthPressed(_ sender: Any) {
        if monthPicker.isHidden == true {
            monthPicker.isHidden = false
        }
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return months.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return months[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        btnMonth.setTitle(months[row], for: .normal)
        monthPicker.isHidden = true
    }
    
    
    // Opening Login Page
    @IBAction func login(_ sender: Any) {
        let u = username.text
        let p = password.text
        let JSONObj: [String: Any] = [
            "userEmail": u!,
            "password": p!
        ]
        //var success = false
        let jsonData = try? JSONSerialization.data(withJSONObject: JSONObj)
        let url = URL(string: "https://api.projectmito.io/v1/sessions")!
        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        request.httpBody = jsonData
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {                                                 // check for fundamental networking error
                print("error=\(String(describing: error))")
                return
            }
            
            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {           // check for http errors
                print("statusCode should be 200, but is \(httpStatus.statusCode)")
                print("response = \(String(describing: response))")
            }
            
            let responseString = String(data: data, encoding: .utf8)
            let data2 = responseString?.data(using: .utf8)
            let dictionary = try? JSONSerialization.jsonObject(with: data2!, options: .mutableLeaves)
            DispatchQueue.main.async {
                if (dictionary != nil) {
                    self.performSegue(withIdentifier: "login", sender: self)
                    UserDefaults.standard.set(dictionary, forKey: "UserInfo")
                    print(UserDefaults.standard.object(forKey: "UserInfo") as! NSDictionary)
                    if UserDefaults.standard.object(forKey: "UserInfo") != nil {
                        let data = UserDefaults.standard.object(forKey: "UserInfo") as! NSDictionary
                        //userID = data["userId"] as? Int
                        self.appdata.userID = (data["userId"] as? Int)!
                    }
                    //appdata.userID =
                }
            }
            //success = true
        }
        task.resume()
    }
    
    @IBAction func signup(_ sender: Any) {
        performSegue(withIdentifier: "signup", sender: self)
        let content = UNMutableNotificationContent()
        content.title = "Notification"
        content.subtitle = "Notification subtitle"
        content.body = "Andre has sent you a friend request"
        content.badge = 1
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
        let request = UNNotificationRequest(identifier: "timerDone", content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
    }

    // Sign up page
    
    @IBOutlet weak var userFnameSU: UITextField!
    @IBOutlet weak var usernameSU: UITextField!
    @IBOutlet weak var passwordSU: UITextField!
    @IBOutlet weak var passwordConfSU: UITextField!
    @IBOutlet weak var userEmailSU: UITextField!
    @IBAction func signupButton(_ sender: Any) {
        let uFname = userFnameSU.text
        let uname = usernameSU.text
        let pass = passwordSU.text
        let passConf = passwordConfSU.text
        let uEmail = userEmailSU.text
        
        let JSONObj: [String: Any] = [
            "userFname": uFname!,
            "userLname": "Smith",
            "username": uname!,
            "userEmail": uEmail!,
            "password": pass!,
            "passwordConf": passConf!,
            "userDOB": "01/01/2000"
        ]
        
        let jsonData = try? JSONSerialization.data(withJSONObject: JSONObj)
        let url = URL(string: "https://api.projectmito.io/v1/users")!
        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        request.httpBody = jsonData
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {                                                 // check for fundamental networking error
                print("error=\(String(describing: error))")
                return
            }
            
            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode > 300 {           // check for http errors
                print("statusCode should be 200, but is \(httpStatus.statusCode)")
                print("response = \(String(describing: response))")
            }
            
            let responseString = String(data: data, encoding: .utf8)
            let data2 = responseString?.data(using: .utf8)
            let dictionary = try? JSONSerialization.jsonObject(with: data2!, options: .mutableLeaves)
            DispatchQueue.main.async {
                if (dictionary != nil) {
                    self.performSegue(withIdentifier: "signUpToAddress", sender: self)
                    UserDefaults.standard.set(dictionary, forKey: "UserInfo")
                    //print(UserDefaults.standard.object(forKey: "UserInfo") as! NSDictionary)
                    if UserDefaults.standard.object(forKey: "UserInfo") != nil {
                        let data = UserDefaults.standard.object(forKey: "UserInfo") as! NSDictionary
                        //userID = data["userId"] as? Int
                        self.appdata.userID = (data["userId"] as? Int)!
                    }
                }
            }
            //success = true
        }
        task.resume()
        
        
    }
    
    // Add Address page
    
    @IBOutlet weak var address1AA: UITextField!
    @IBOutlet weak var address2AA: UITextField!
    @IBOutlet weak var cityAA: UITextField!
    @IBOutlet weak var stateAA: UITextField!
    @IBOutlet weak var zipcodeAA: UITextField!
    @IBAction func createAccountButton(_ sender: Any) {
        var userID: Int?
        if UserDefaults.standard.object(forKey: "UserInfo") != nil {
            let data = UserDefaults.standard.object(forKey: "UserInfo") as! NSDictionary
            userID = data["userId"] as? Int
            print("data = \(data)")
            print("userId = \(String(describing: data["userId"]))")
            appdata.userID = userID!
        }
        let address1 = address1AA.text
        let address2 = address2AA.text
        let city = cityAA.text
        let state = stateAA.text
        let zipcode = zipcodeAA.text
        let alias = "Home Address"
        
        let JSONObj: [String: Any] = [
            "userId": userID!,
            "streetAddress1": address1!,
            "streetAddress2": address2!,
            "cityName": city!,
            "zipCode": zipcode!,
            "stateName": state!,
            "aliasName": alias
        ]
        
        
        
        let jsonData = try? JSONSerialization.data(withJSONObject: JSONObj)
        let url = URL(string: "https://api.projectmito.io/v1/address")!
        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        request.httpBody = jsonData
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {                                                 // check for fundamental networking error
                print("error=\(String(describing: error))")
                return
            }
            
            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode > 300 {           // check for http errors
                print("statusCode should be 200, but is \(httpStatus.statusCode)")
                print("response = \(String(describing: response))")
            }
            
            let responseString = String(data: data, encoding: .utf8)
            let data2 = responseString?.data(using: .utf8)
            let dictionary = try? JSONSerialization.jsonObject(with: data2!, options: .mutableLeaves)
            DispatchQueue.main.async {
                if (dictionary != nil) {
                    self.performSegue(withIdentifier: "createAccount", sender: self)
                    print(dictionary)
                    //                    UserDefaults.standard.set(dictionary, forKey: "AddressInfo")
                    //                    print(UserDefaults.standard.object(forKey: "AddressInfo") as! NSDictionary)
                }
            }
            //success = true
        }
        task.resume()
    }

    
    @objc func keyboardWillShow(notification: NSNotification) {
        if ((notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue) != nil {
            if self.view.frame.origin.y == 0 {
                self.view.frame.origin.y -= 75
            }
        }
//        username.returnKeyType = .next
//        password.returnKeyType = .done

    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        if ((notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue) != nil {
            if self.view.frame.origin.y == -75 {
                self.view.frame.origin.y += 75
            }
        }
    }
    
    @objc func dismissKeyboard (_ sender: UITapGestureRecognizer) {
        if username != nil && password != nil {
            username.resignFirstResponder()
            password.resignFirstResponder()
        }
    }
    
    override func viewDidLoad() {
        if monthPicker != nil {
            monthPicker.isHidden = true
            monthPicker.delegate = self
            monthPicker.dataSource = self
        }
        super.viewDidLoad()
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard (_:)))
        self.view.addGestureRecognizer(tapGesture)
        NotificationCenter.default.addObserver(self, selector: #selector(LoginViewController.keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(LoginViewController.keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge], completionHandler: {didAllow, error in
            
        })
//        if UserDefaults.standard.object(forKey: "UserInfo") == nil {
//            print("There is no local data")
//        } else {
//            performSegue(withIdentifier: "login", sender: self)
//        }
    }
}
