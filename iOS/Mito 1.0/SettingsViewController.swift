//
//  SettingsViewController.swift
//  Mito 1.0
//
//  Created by Benny on 2/25/18.
//  Copyright © 2018 Benny Souriyadeth. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController {


    //Login
    @IBAction func settingsToHome(_ sender: Any) {
        performSegue(withIdentifier: "settingsToMe", sender: self)
    }
    @IBAction func signout(_ sender: Any) {
        performSegue(withIdentifier: "signOut", sender: self)
        UserDefaults.standard.removeObject(forKey: "UserInfo")
        if UserDefaults.standard.object(forKey: "UserInfo") == nil {
            print("Data is gone")
        } else {
            print("Data is still here")
        }
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}
