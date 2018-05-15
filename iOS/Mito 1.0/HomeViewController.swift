//
//  HomeViewController.swift
//  Mito 1.0
//
//  Created by JJ Guo on 2/25/18.
//  Copyright © 2018 Benny Souriyadeth. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireImage
import Starscream
import SwiftyJSON

class HomeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var greenTopView: UIView!
    
    @IBOutlet weak var segmentChooser: UISegmentedControl!
    
    @IBAction func switchTab(_ sender: UISegmentedControl) {
        if segmentChooser.selectedSegmentIndex == 1 {
            appdata.fnLoadMyActivity(tblview: tableView)
        } else {
            fnLoadFriendActivity()
        }
    }
    
    func fnLoadCurrUserAddresses() {
        let urlGetMyAddresses = URL(string: "https://api.projectmito.io/v1/address/")
        let headers: HTTPHeaders = [
            "Authorization": UserDefaults.standard.object(forKey: "Authorization") as! String
        ]
        Alamofire.request(urlGetMyAddresses!, method: .get, encoding: JSONEncoding.default, headers: headers).validate().responseJSON { response in
            switch response.result {
            case .success:
                if let dictionary = response.data {
                    let decoder = JSONDecoder()
                    do {
                        self.appdata.arrCurrUserAddresses = try decoder.decode([Address].self, from: dictionary)
                    } catch let jsonErr {
                        print("Failed to decode: \(jsonErr)")
                    }
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
        fnLoadFriendActivity()
    }
    
    func fnLoadFriendActivity() {
        let urlLoadFriendActivity = URL(string: "https://api.projectmito.io/v1/feed/friends")
        let headers: HTTPHeaders = [
            "Authorization": UserDefaults.standard.object(forKey: "Authorization") as! String
        ]
        Alamofire.request(urlLoadFriendActivity!, method: .get, encoding: URLEncoding.default, headers: headers).validate().responseJSON { response in
            switch response.result {
            case .success:
                print("Loaded Friend Activity")
                if let dictionary = response.data {
                    let decoder = JSONDecoder()
                    do {
                        self.appdata.arrFriendsFeedItems = try decoder.decode([FeedItem].self, from: dictionary)
                    } catch let jsonErr {
                        print("Failed to decode: \(jsonErr)")
                    }
//                    let arrFeedItems = dictionary as! NSArray
//                    for objFeedItem in arrFeedItems {
//                        let item = objFeedItem as! NSDictionary
//                        let strDate = item["OrderDate"].stringValue
//                        print(strDate)
//                        let strMessage = item["OrderMessage"] as! String
//                        let strPhotoUrl = item["SenderPhotoUrl"] as! String
//                        let strRecipientFName = item["RecipientFirstName"] as! String
//                        let strRecipientLName = item["RecipientLastName"] as! String
//                        let strSenderFName = item["SenderFirstName"] as! String
//                        let strSenderLName = item["SenderLastName"] as! String
//                        let intRecipientId = item["RecipientId"] as! Int
//                        let intSenderId = item["SenderId"] as! Int
//                        let objFeed = FeedItem(strDate: strDate, photoSenderUrl: strPhotoUrl, strMessage: strMessage, strRecipientFName: strRecipientFName, strRecipientLName: strRecipientLName, strSenderFName: strSenderFName, strSenderLName: strSenderLName, intSenderId: intSenderId, intRecipientId: intRecipientId)
//                        self.appdata.arrFriendsFeedItems.append(objFeed)
//                      }
                    self.appdata.arrFriendsFeedItems.sort(by: self.appdata.fnSortFeedItems)
                }
                print("Total Friend Feed Items: \(self.appdata.arrFriendsFeedItems.count)")
                DispatchQueue.main.async {
                    self.tableView.reloadData()
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
        if segmentChooser.selectedSegmentIndex == 0 {
            return appdata.arrFriendsFeedItems.count
        }
        return appdata.arrMyFeedItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "homeCell", for: indexPath) as! HomeTableViewCell
        var feedItemObj = FeedItem(strDate: "", photoSenderUrl: "", strMessage: "", strRecipientFName: "", strRecipientLName: "", strSenderFName: "", strSenderLName: "", intRecipientId: 0, intSenderId: 0)
        print(indexPath.row)
        if segmentChooser.selectedSegmentIndex == 0 {
            feedItemObj = appdata.arrFriendsFeedItems[indexPath.row]
        } else {
            feedItemObj = appdata.arrMyFeedItems[indexPath.row]
        }
        Alamofire.request(feedItemObj.photoSenderUrl).responseImage(completionHandler: { (response) in
            print(response)
            if let image = response.result.value {
                let circularImage = image.af_imageRoundedIntoCircle()
                DispatchQueue.main.async {
                    cell.img.image = circularImage
                }
            }
        })
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
