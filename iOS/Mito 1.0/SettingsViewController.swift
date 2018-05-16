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
        appdata.arrMyFeedItems.removeAll()
        appdata.arrFriendsFeedItems.removeAll()
        if UserDefaults.standard.object(forKey: "UserInfo") == nil {
            print("Data is gone")
        } else {
            print("Data is still here")
        }
    }
    
    @IBAction func btnChangePassword(_ sender: Any) {
        performSegue(withIdentifier: "SettingsToChangePassword", sender: self)
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
                if UserDefaults.standard.object(forKey: "UserInfo") != nil {
                    let data = UserDefaults.standard.object(forKey: "UserInfo") as! NSDictionary
                    self.appdata.intCurrentUserID = (data["userId"] as? Int)!
                    print("UserInfo: \(String(describing: data["UserInfo"]))")
                    print("UserID: \(String(describing: data["userId"]))")
                } else {
                    print("data[\"UserInfo\"] should be gone")
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
