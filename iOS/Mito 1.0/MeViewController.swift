//
//  MeViewController.swift
//  Mito 1.0
//
//  Created by Benny on 2/25/18.
//  Copyright © 2018 Benny Souriyadeth. All rights reserved.
//

import UIKit

class MeViewController: UIViewController {

    @IBOutlet weak var userID: UILabel!
    @IBOutlet weak var userEmail: UILabel!
    @IBOutlet weak var username: UILabel!
    @IBOutlet weak var userFname: UILabel!
    @IBOutlet weak var userLname: UILabel!
    @IBOutlet weak var userDOB: UILabel!
    @IBOutlet weak var photoURL: UILabel!
    
    @IBAction func meToSettings(_ sender: Any) {
        performSegue(withIdentifier: "meToSettings", sender: self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if UserDefaults.standard.object(forKey: "UserInfo") != nil {
            let data = UserDefaults.standard.object(forKey: "UserInfo") as! NSDictionary
            self.userID.text = data["userId"] as? String
            self.userEmail.text = data["userEmail"] as? String
            self.username.text = data["username"] as? String
            self.userFname.text = data["userFname"] as? String
            self.userLname.text = data["userLname"] as? String
            self.userDOB.text = data["userDOB"] as? String
            self.photoURL.text = data["photoURL"] as? String
        }
        print("Tom Brady \(UserDefaults.standard.object(forKey: "UserInfo"))")
    }
}
