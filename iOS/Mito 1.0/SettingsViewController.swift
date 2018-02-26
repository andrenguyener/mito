//
//  SettingsViewController.swift
//  Mito 1.0
//
//  Created by Benny on 2/25/18.
//  Copyright © 2018 Benny Souriyadeth. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController {


    @IBAction func settingsToHome(_ sender: Any) {
        performSegue(withIdentifier: "settingsToMe", sender: self)
    }
    
    @IBAction func signOut(_ sender: Any) {
        performSegue(withIdentifier: "signOut", sender: self)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}
