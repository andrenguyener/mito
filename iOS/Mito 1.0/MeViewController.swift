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
    let url = URL(string: "https://api.myjson.com/bins/gyctp") // https://localhost:4000/v1/users/id
    
    @IBAction func meToSettings(_ sender: Any) {
        performSegue(withIdentifier: "meToSettings", sender: self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        if let path = Bundle.main.path(forResource: "profileInfo", ofType: "json") {
//            do {
//                let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
//                let jsonResult = try JSONSerialization.jsonObject(with: data, options: .mutableLeaves) as! NSDictionary
//                self.userID.text = jsonResult["userId"] as? String
//                self.userEmail.text = jsonResult["userEmail"] as? String
//                self.username.text = jsonResult["username"] as? String
//                self.userFname.text = jsonResult["userFname"] as? String
//                self.userLname.text = jsonResult["userLname"] as? String
//                self.userDOB.text = jsonResult["userDOB"] as? String
//                self.photoURL.text = jsonResult["photoURL"] as? String
////                if let jsonResult = jsonResult as? Dictionary<String, AnyObject>, let person = jsonResult["person"] as? [Any] {
////                    // do stuff
////                }
//            } catch {
//                // handle error
//            }
//        }
        let task = URLSession.shared.dataTask(with: url!) { (data, response, error) in
            if error != nil {
                print("ERROR")
            } else {
                if let content = data {
                    do {
                        let myJson = try JSONSerialization.jsonObject(with: content, options: JSONSerialization.ReadingOptions.mutableContainers) as! NSDictionary
                        DispatchQueue.main.async {
                            let data = UserDefaults.standard.object(forKey: "UserInfo") as! NSDictionary
                            print(data)
                            self.userID.text = data["userId"] as? String
                            self.userEmail.text = data["userEmail"] as? String
                            self.username.text = data["username"] as? String
                            self.userFname.text = data["userFname"] as? String
                            self.userLname.text = data["userLname"] as? String
                            self.userDOB.text = data["userDOB"] as? String
                            self.photoURL.text = data["photoURL"] as? String
                        }
                    } catch {
                        print("Catch")
                    }
                } else {
                    print("Error")
                }
            }
        }
        task.resume()
    }
}
