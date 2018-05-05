//
//  SettingsViewController.swift
//  Mito 1.0
//
//  Created by Benny on 2/25/18.
//  Copyright © 2018 Benny Souriyadeth. All rights reserved.
//

import UIKit
import Alamofire

class SettingsViewController: UIViewController {
    var appdata = AppData.shared
    
    //Login
    @IBAction func settingsToHome(_ sender: Any) {
        self.performSegue(withIdentifier: "settingsToMe", sender: self)
    }
    
    @IBAction func signout(_ sender: Any) {
        performSegue(withIdentifier: "signOut", sender: self)
        self.fnSignOut()
        UserDefaults.standard.removeObject(forKey: "UserInfo")
        appdata.arrAllUsers.removeAll()
        appdata.arrFriends.removeAll()
        appdata.arrPendingFriends.removeAll()
        if UserDefaults.standard.object(forKey: "UserInfo") == nil {
            print("Data is gone")
        } else {
            print("Data is still here")
        }
    }
    
    func fnSignOut() {
        let headers: HTTPHeaders = [
            "Authorization": UserDefaults.standard.object(forKey: "Authorization") as! String
        ]
        let urlSignOut = URL(string: "https://api.projectmito.io/v1/sessions/mine")
        Alamofire.request(urlSignOut!, method: .delete, encoding: JSONEncoding.default, headers: headers).validate().responseString { response in
            switch response.result {
            case .success:
                if let dictionary = response.result.value {
                    print(dictionary)
                    // Any code for storing locally
                }
                
            case .failure(let error):
                print("User signed out")
                print(error)
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "settingsToMe" {
            let tabBarController = segue.destination as! UITabBarController
            tabBarController.selectedIndex = 3
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}
