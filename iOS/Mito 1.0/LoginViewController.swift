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
//        performSegue(withIdentifier: "login", sender: self )
        let u = username.text
        let p = password.text
        var JSONObj: [String: Any] = [
            "userEmail": u,
            "password": p
            
        ]
        let jsonData = try? JSONSerialization.data(withJSONObject: JSONObj)
        let url = URL(string: "https://api.projectmito.io/v1/sessions")!
        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        request.httpBody = jsonData
        print("Print \(jsonData)")
//        var stringf = jsonData as String
//        var somedata = jsonData.data(using: String.Encoding.utf8)
//        var backToString = String(data: somedata!, encoding: String.Encoding.utf8) as String!
//        var data = jsonData.data(using: .utf8)
//        let dictionary = try? JSONSerialization.jsonObject(with: jsonData!, options: .mutableLeaves)
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {                                                 // check for fundamental networking error
                print("error=\(error)")
                return
            }
            
            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {           // check for http errors
                print("statusCode should be 200, but is \(httpStatus.statusCode)")
                print("response = \(response)")
            }
            
            let responseString = String(data: data, encoding: .utf8)
            print("responseString = \(responseString)")
            var data2 = responseString?.data(using: .utf8)
            let dictionary = try? JSONSerialization.jsonObject(with: data2!, options: .mutableLeaves)
            print(dictionary)

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
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}
