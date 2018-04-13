//
//  ViewController.swift
//  Mito 1.0
//
//  Created by Benny on 2/22/18.
//  Copyright © 2018 Benny Souriyadeth. All rights reserved.
//

import UIKit
import Alamofire

class PeopleDetailsViewController: UIViewController {

    var appdata = AppData.shared
    
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblEmail: UILabel!
    @IBOutlet weak var img: UIImageView!
    @IBOutlet weak var lblNumFriends: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadPersonData()
    }
    
    func loadPersonData() {
        let friend = appdata.arrAllUsers[myIndex]
        lblName.text = "\(friend.firstName) \(friend.lastName)"
        lblEmail.text = "\(friend.email)"
//        lblNumFriends.text =
        let url = URL(string:"\(friend.avatar)")
        if let data = try? Data(contentsOf: url!) {
            img.image = UIImage(data: data)!
        }
        print("\(lblName.text)'s ID: \(friend.intUserID)")
    }

    @IBAction func fnAddFriend(_ sender: Any) {
        print(appdata.arrAllUsers[myIndex].description())
        print(appdata.intCurrentUserID)
        let intUser2Id = appdata.arrAllUsers[myIndex].intUserID
        
        let parameters: Parameters = [
            "friendId": intUser2Id
        ]
        
        let headers: HTTPHeaders = [
            "Authorization": UserDefaults.standard.object(forKey: "Authorization") as! String
        ]
        print(UserDefaults.standard.object(forKey: "Authorization"))
        
        Alamofire.request("https://api.projectmito.io/v1/friend", method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers).validate().responseString { response in
            switch response.result {
            case .success:
                
                if let dictionary = response.result.value {
                    print("Request: \(response.request)")
                    print("JSON: \(dictionary)") // serialized json response
                    DispatchQueue.main.async {
                        self.fnAlertRequestSent()
                    }
                }
                
                
            case .failure(let error):
                print("Request: \(response.request)")
                print(error)
            }
        }
    }

    
    func fnAlertRequestSent() {
        let alertController = UIAlertController(title: "Done", message: "Friend Request Sent", preferredStyle: .alert)
        let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(defaultAction)
        present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func backButton(_ sender: Any) {
        performSegue(withIdentifier: "segPeopleDetailsToSearchView", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "segPeopleDetailsToSearchView" {
            let tabBarController = segue.destination as! UITabBarController
            tabBarController.selectedIndex = 1
        }
    }
}

