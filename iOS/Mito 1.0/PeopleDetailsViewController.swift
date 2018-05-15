//
//  ViewController.swift
//  Mito 1.0
//
//  Created by Benny on 2/22/18.
//  Copyright © 2018 Benny Souriyadeth. All rights reserved.
//

import UIKit
import Alamofire
import UIKit

class PeopleDetailsViewController: UIViewController {

    var appdata = AppData.shared
    
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblUsername: UILabel!
    @IBOutlet weak var img: UIImageView!
    @IBOutlet weak var btnNumFriends: UIButton!
    @IBOutlet weak var addFriendbtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadPersonData()
    }
    
    func loadPersonData() {
        fnCheckFriendStatus()
        let friend = appdata.personToView
        let strName = "\(friend.firstName) \(friend.lastName)"
        lblName.text = strName
        self.navigationItem.title = strName
        lblUsername.text = "@\(friend.strUsername)"
        btnNumFriends.setTitle("\(friend.intNumFriends) friends", for: .normal)
        appdata.fnDisplaySimpleImage(strImageURL: friend.avatar, img: img)
    }
    
    func fnCheckFriendStatus() {
        print("Section: \(mySection)")
        print("Row: \(myIndex)")
        let intFriendID = appdata.personToView.intUserID
        let parameters: Parameters = [
            "friendId": intFriendID
        ]
        
        let headers: HTTPHeaders = [
            "Authorization": UserDefaults.standard.object(forKey: "Authorization") as! String
        ]
        
        Alamofire.request("https://api.projectmito.io/v1/friend/type", method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers).validate().responseString { response in
            switch response.result {
            case .success:
                if let dictionary = response.result.value {
                    print(dictionary)
                    if dictionary == "Friend" {
                        self.addFriendbtn.setTitle("Friends", for: .normal)
                        self.addFriendbtn.isEnabled = false
                        self.addFriendbtn.backgroundColor = UIColor.gray
                    }
                }
                
            case .failure(let error):
                print("Request: \(String(describing: response.request))")
                print(error)
            }
        }
    }

    @IBAction func fnAddFriend(_ sender: Any) {
        let friend = appdata.arrCurrFriendsAndAllMitoUsers[mySection][myIndex]
        let intUser2Id = friend.intUserID
        
        let parameters: Parameters = [
            "friendId": intUser2Id
        ]
        
        let headers: HTTPHeaders = [
            "Authorization": UserDefaults.standard.object(forKey: "Authorization") as! String
        ]
        
        Alamofire.request("https://api.projectmito.io/v1/friend", method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers).validate().responseString { response in
            switch response.result {
            case .success:
                if let dictionary = response.result.value {
                    print("Request: \(String(describing: response.request))")
                    print("JSON: \(dictionary)") // serialized json response
                    DispatchQueue.main.async {
                        let alert = self.appdata.fnDisplayAlert(title: "Done", message: "Friend Request Sent")
                        self.present(alert, animated: true, completion: nil)
                    }
                }
                
            case .failure(let error):
                print("Request: \(String(describing: response.request))")
                print(error)
            }
        }
    }
    
    @IBAction func backButton(_ sender: Any) {
        performSegue(withIdentifier: "segPeopleDetailsToSearchView", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "segPeopleDetailsToSearchView" {
            let tabBarController = segue.destination as! UITabBarController
            tabBarController.selectedIndex = 1
        } else if segue.identifier == "searchToMitoProfile" {
            let backItem = UIBarButtonItem()
            backItem.title = "Search People"
            navigationItem.backBarButtonItem = backItem
        }
    }
}

