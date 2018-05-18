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
            appdata.fnLoadMyActivity(tblview: tableView, intUserId: appdata.intCurrentUserID, arr: appdata.arrMyFeedItems)
        } else {
            appdata.fnLoadFriendActivity(tblview: tableView)
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
//        let nib = UINib(nibName: "HomeTableViewCell", bundle: nil)
//        tableView.register(nib, forCellReuseIdentifier: "homeCell")
        
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
        appdata.fnLoadFriendActivity(tblview: tableView)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        tableView.reloadData()
        if tableView != nil {
            self.navigationController?.setNavigationBarHidden(true, animated: animated)
        }
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
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 106
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = Bundle.main.loadNibNamed("HomeTableViewCell", owner: self, options: nil)?.first as! HomeTableViewCell
        let cell = tableView.dequeueReusableCell(withIdentifier: "homeCell", for: indexPath) as! HomeTableViewCell
        var feedItemObj = FeedItem(strDate: "", photoSenderUrl: "", strMessage: "", strRecipientFName: "", strRecipientLName: "", strSenderFName: "", strSenderLName: "", intRecipientId: 0, intSenderId: 0)
        print(indexPath.row)
        if segmentChooser.selectedSegmentIndex == 0 {
            feedItemObj = appdata.arrFriendsFeedItems[indexPath.row]
        } else {
            feedItemObj = appdata.arrMyFeedItems[indexPath.row]
        }
        Alamofire.request(feedItemObj.photoSenderUrl).responseImage(completionHandler: { (response) in
//            print(response)
            if let image = response.result.value {
                let circularImage = image.af_imageRoundedIntoCircle()
                print(circularImage)
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
