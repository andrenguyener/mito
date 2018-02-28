//
//  LoginViewController.swift
//  Mito 1.0
//
//  Created by Benny on 2/25/18.
//  Copyright © 2018 Benny Souriyadeth. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {

    @IBAction func login(_ sender: Any) {
        performSegue(withIdentifier: "login", sender: self )
    }
    @IBAction func signup(_ sender: Any) {
        performSegue(withIdentifier: "signup", sender: self)
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}
