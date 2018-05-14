//
//  HomeViewController.swift
//  Mito 1.0
//
//  Created by JJ Guo on 2/25/18.
//  Copyright © 2018 Benny Souriyadeth. All rights reserved.
//

import UIKit
import Alamofire
import Starscream

class HomeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var greenTopView: UIView!

    func fnLoadCurrUserAddresses() {
        let urlGetMyAddresses = URL(string: "https://api.projectmito.io/v1/address/")
        let headers: HTTPHeaders = [
            "Authorization": UserDefaults.standard.object(forKey: "Authorization") as! String
        ]
        Alamofire.request(urlGetMyAddresses!, method: .get, encoding: JSONEncoding.default, headers: headers).validate().responseJSON { response in
            switch response.result {
            case .success:
                if let dictionary = response.result.value {
                    self.appdata.arrCurrUserAddresses.removeAll()
                    let arrAddresses = dictionary as! NSArray
                    for elem in arrAddresses {
                        let objAddress = elem as! NSDictionary
                        print(objAddress)
                        var strAddress2 = ""
                        if objAddress["StreetAddress2"] != nil {
                            strAddress2 = objAddress["StreetAddress2"] as! String
                        }
                        let objAddressObject = Address(intAddressID: objAddress["AddressId"] as! Int, strAddressAlias: objAddress["Alias"] as! String, strCityName: objAddress["CityName"] as! String, strStateName: objAddress["StateName"] as! String, strStreetAddress1: objAddress["StreetAddress"] as! String, strStreetAddress2: strAddress2, strZipCode: objAddress["ZipCode"] as! String)
                        print("\(objAddress["Alias"] as! String) \(String(describing: objAddress["AddressId"]))")
                        self.appdata.arrCurrUserAddresses.append(objAddressObject)
                    }
                    print("This user has \(self.appdata.arrCurrUserAddresses.count) addresses")
                }
                DispatchQueue.main.async {
                    if (self.appdata.arrCurrUserAddresses.count > 0) {
                        print("Load Current User Addresses: \(self.appdata.arrCurrUserAddresses[self.appdata.arrCurrUserAddresses.count - 1].strAddressAlias)")
                    }
                    //                    self.appdata.address = self.appdata.arrCurrUserAddresses[self.appdata.arrCurrUserAddresses.count - 1]
//                    self.tblviewAddress.reloadData()
                }
                
            case .failure(let error):
                print("Get all addresses error")
                print(error.localizedDescription)
            }
        }
    }

    @IBOutlet weak var tableView: UITableView!
    var appdata = AppData.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = 133
        
        fnLoadCurrUserAddresses()
//        greenTopView.backgroundColor = UIColor(rgb: 41DD7C)
        
        let userURL = "https://api.projectmito.io/v1/friend/\(appdata.intCurrentUserID)"
        print("Authorization: \(String(describing: UserDefaults.standard.object(forKey: "Authorization")))")
        let authToken = UserDefaults.standard.object(forKey: "Authorization") as! String

//        var request = URLRequest(url: URL(string: "wss://api.projectmito.io/v1/ws?auth=\(String(describing: UserDefaults.standard.object(forKey: "Authorization")))")!)
        var urlWebsocket = "wss://api.projectmito.io/v1/ws?auth=\(authToken)"
        urlWebsocket = urlWebsocket.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)!
        var request = URLRequest(url: URL(string: urlWebsocket)!)
        print("Request: \(request)")
        request.timeoutInterval = 5
        appdata.socket = WebSocket(request: request)
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appdata.socket.delegate = appDelegate.self
        appdata.socket.connect()
//        fnLoadFriendActivity()
        appdata.fnLoadMyActivity()
    }
    
    func fnLoadFriendActivity() {
        let urlLoadFriendActivity = URL(string: "https://api.projectmito.io/v1/feed/friends")
        let headers: HTTPHeaders = [
            "Authorization": UserDefaults.standard.object(forKey: "Authorization") as! String
        ]
        Alamofire.request(urlLoadFriendActivity!, method: .get, encoding: JSONEncoding.default, headers: headers).validate().responseJSON { response in
            switch response.result {
            case .success:
                print("Loaded Friend Activity")
                if let dictionary = response.result.value {
                    let arrFeedItems = dictionary as! NSArray
                    for objFeedItem in arrFeedItems {
                        let item = objFeedItem as! NSDictionary
                        let strDate = item["OrderDate"] as! String
                        let strMessage = item["OrderMessage"] as! String
                        let strPhotoUrl = item["SenderPhotoUrl"] as! String
                        let strRecipientFName = item["RecipientFirstName"] as! String
                        let strRecipientLName = item["RecipientLastName"] as! String
                        let strSenderFName = item["SenderFirstName"] as! String
                        let strSenderLName = item["SenderLastName"] as! String
                        let intRecipientId = item["RecipientId"] as! Int
                        let intSenderId = item["SenderId"] as! Int
                        let objFeed = FeedItem(strDate: strDate, photoSenderUrl: strPhotoUrl, strMessage: strMessage, strRecipientFName: strRecipientFName, strRecipientLName: strRecipientLName, strSenderFName: strSenderFName, strSenderLName: strSenderLName, intSenderId: intSenderId, intRecipientId: intRecipientId)
                        self.appdata.arrFriendsFeedItems.append(objFeed)
                    }
                    
                }
                
            case .failure(let error):
                print("Error loading friend activity")
                print(error)
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        tableView.reloadData()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return appdata.arrMyFeedItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "homeCell", for: indexPath) as! HomeTableViewCell
        let feedItemObj = appdata.arrMyFeedItems[indexPath.row]
        let urlProductImage = URL(string: "\(feedItemObj.photoSenderUrl)")
        if let data = try? Data(contentsOf: urlProductImage!) {
            cell.img.image = UIImage(data: data)!
        }
        var strSender = "\(feedItemObj.strSenderFName) \(feedItemObj.strSenderLName)"
        var strRecipient = "\(feedItemObj.strRecipientFName) \(feedItemObj.strRecipientLName)"
        if feedItemObj.intSenderId == appdata.intCurrentUserID {
            strSender = "You"
        }
        if feedItemObj.intRecipientId == appdata.intCurrentUserID {
            strRecipient = "You"
        }
        cell.whatHappened.text = "\(strSender) sent \(strRecipient)"
        cell.time.text = "\(appdata.fnUTCToLocal(date: feedItemObj.strDate))"
        cell.descr.text = "\(feedItemObj.strMessage)"
        cell.whatHappened.numberOfLines = 2
        return cell
    }

    @IBAction func cart(_ sender: Any) {
        performSegue(withIdentifier: "homeToCart", sender: self)
    }
    
    
}
