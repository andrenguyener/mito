//
//  LoginViewController.swift
//  Mito 1.0
//
//  Created by Benny on 2/25/18.
//  Copyright © 2018 Benny Souriyadeth. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {

    // Opening Login Page
    @IBAction func login(_ sender: Any) {
        performSegue(withIdentifier: "login", sender: self )
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
