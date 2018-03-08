//
//  LoginViewController.swift
//  Mito 1.0
//
//  Created by Benny on 2/25/18.
//  Copyright © 2018 Benny Souriyadeth. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {

    
    @IBOutlet weak var username: UITextField!
    @IBOutlet weak var password: UITextField!
    
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
                }
            }
            //success = true
        }
        task.resume()
    }
    
    @IBAction func signup(_ sender: Any) {
        performSegue(withIdentifier: "signup", sender: self)
    }

    // Sign up page
    @IBAction func signupButton(_ sender: Any) {
        performSegue(withIdentifier: "signUpToAddress", sender: self)
    }
    
    // Add Address page
    @IBAction func createAccountButton(_ sender: Any) {
        performSegue(withIdentifier: "createAccount", sender: self)
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if ((notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue) != nil {
            if self.view.frame.origin.y == 0 {
                self.view.frame.origin.y -= 75
            }
        }
        username.returnKeyType = .next
        password.returnKeyType = .done

    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        if ((notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue) != nil {
            if self.view.frame.origin.y == -75 {
                self.view.frame.origin.y += 75
            }
        }
    }
    
    @objc func dismissKeyboard (_ sender: UITapGestureRecognizer) {
//        username.resignFirstResponder()
//        password.resignFirstResponder()
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard (_:)))
        self.view.addGestureRecognizer(tapGesture)
        NotificationCenter.default.addObserver(self, selector: #selector(LoginViewController.keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(LoginViewController.keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
  


//        if UserDefaults.standard.object(forKey: "UserInfo") == nil {
//            print("There is no local data")
//        } else {
//            performSegue(withIdentifier: "login", sender: self)
//        }
    }
}
