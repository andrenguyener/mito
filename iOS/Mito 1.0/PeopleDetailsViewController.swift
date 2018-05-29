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

class PeopleDetailsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var appdata = AppData.shared
    
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblUsername: UILabel!
    @IBOutlet weak var img: UIImageView!
    @IBOutlet weak var btnNumFriends: UIButton!
    @IBOutlet weak var addFriendbtn: UIButton!
    @IBOutlet weak var tblviewFeed: UITableView!
    @IBOutlet weak var btnShopForFriend: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadPersonData()
        btnShopForFriend.setTitle("Shop for \(appdata.personToView.firstName)", for: .normal)
        self.navigationController?.isNavigationBarHidden = false
        tblviewFeed.delegate = self
        tblviewFeed.dataSource = self
        tblviewFeed.rowHeight = 106
        let nibAddNewAddress = UINib(nibName: "FeedCopyTableViewCell", bundle: nil)
        tblviewFeed.register(nibAddNewAddress, forCellReuseIdentifier: "FeedCopyCell")
    }
    
    @IBAction func btnShopNowForFriend(_ sender: Any) {
        appdata.personRecipient = appdata.personToView
        performSegue(withIdentifier: "segShopNowForFriend", sender: self)
        self.tabBarController?.selectedIndex = 2
    }
    
    func loadPersonData() {
        fnCheckFriendStatus()
        let friend = appdata.personToView
        print("\(friend.firstName) \(friend.lastName)")
        print(friend.intUserID)
        appdata.fnLoadMitoProfileFeed(tblview: tblviewFeed, intUserId: friend.intUserID)
//        appdata.fnLoadMyActivity(tblview: tblviewFeed, intUserId: friend.intUserID, arr: appdata.arrMitoProfileFeedItems)
        let strName = "\(friend.firstName) \(friend.lastName)"
        lblName.text = strName
        self.navigationItem.title = strName
        lblUsername.text = "@\(friend.strUsername)"
        var strNumFriends = "friends"
        if friend.intNumFriends == 1 {
            strNumFriends = "friend"
        }
        btnNumFriends.setTitle("\(friend.intNumFriends) \(strNumFriends)", for: .normal)
        appdata.fnDisplayImage(strImageURL: friend.avatar, img: img, boolCircle: true)
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
                        self.addFriendbtn.setTitle("✓ Friends", for: .normal)
                        self.btnShopForFriend.isHidden = false
                        self.addFriendbtn.isEnabled = false
//                        self.addFriendbtn.backgroundColor = UIColor.white
                        self.addFriendbtn.setTitleColor(UIColor(red:0.25, green:0.87, blue:0.49, alpha:1.0), for: .normal)
                    } else if dictionary == "Pending" {
                        self.addFriendbtn.setTitle("Friend Request Sent", for: .normal)
                        self.addFriendbtn.setTitleColor(UIColor(red:0.25, green:0.87, blue:0.49, alpha:1.0), for: .normal)
                    } else {
                        self.btnShopForFriend.isHidden = true
                        self.addFriendbtn.setTitle("Add friend", for: .normal)
                        self.addFriendbtn.setTitleColor(UIColor.gray, for: .normal)
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "searchToMitoProfile" {
            let backItem = UIBarButtonItem()
            backItem.title = "Search People"
            navigationItem.backBarButtonItem = backItem
        }
//        } else if segue.identifier == "segShopNowForFriend" {
//            let tabBarController = segue.destination as! UITabBarController
//            tabBarController.selectedIndex = 2
//        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print(appdata.arrMitoProfileFeedItems.count)
        return appdata.arrMitoProfileFeedItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FeedCopyCell", for: indexPath) as! FeedCopyTableViewCell
        let feedItemObj = appdata.arrMitoProfileFeedItems[indexPath.row]
        var strSender = "\(feedItemObj.strSenderFName) \(feedItemObj.strSenderLName)"
        var strRecipient = "\(feedItemObj.strRecipientFName) \(feedItemObj.strRecipientLName)"
        if feedItemObj.intSenderId == appdata.intCurrentUserID {
            strSender = "You"
        }
        if feedItemObj.intRecipientId == appdata.intCurrentUserID {
            strRecipient = "You"
        }
        appdata.fnDisplayImage(strImageURL: feedItemObj.photoSenderUrl, img: cell.imgProfile, boolCircle: true)
        cell.strWho.text = "\(strSender) sent \(strRecipient)"
        cell.strDate.text = "\(appdata.fnUTCToLocal(date: feedItemObj.strDate))"
        cell.strDescr.text = "\(feedItemObj.strMessage)"
        cell.strDescr.numberOfLines = 2
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
}

