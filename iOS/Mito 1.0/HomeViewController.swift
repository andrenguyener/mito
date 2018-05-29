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
    
    @IBOutlet weak var noFeedView: UIView!
    @IBOutlet weak var segmentChooser: UISegmentedControl!
    @IBOutlet weak var imgProfile: UIImageView!
    
    var refresherNotification: UIRefreshControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = 133
        let nib = UINib(nibName: "FeedCopyTableViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "FeedCopyCell")
        let data = UserDefaults.standard.object(forKey: "UserInfo") as! NSDictionary
        var strPhotoUrl = data["profileImageString"] as! String
        if strPhotoUrl.count < 100 {
            strPhotoUrl = data["photoURL"] as! String
        }
        appdata.fnDisplayImage(strImageURL: strPhotoUrl, img: imgProfile, boolCircle: true)
        imgProfile.isUserInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.fnGoToSettings))
        imgProfile.addGestureRecognizer(tapGesture)
        
        fnLoadCurrUserAddresses()
        //        greenTopView.backgroundColor = UIColor(rgb: 41DD7C)
        
        let userURL = "https://api.projectmito.io/v1/friend/\(appdata.intCurrentUserID)"
//        print("Authorization: \(String(describing: UserDefaults.standard.object(forKey: "Authorization")))")
        let authToken = UserDefaults.standard.object(forKey: "Authorization") as! String
        
        //        var request = URLRequest(url: URL(string: "wss://api.projectmito.io/v1/ws?auth=\(String(describing: UserDefaults.standard.object(forKey: "Authorization")))")!)
        var urlWebsocket = "wss://api.projectmito.io/v1/ws?auth=\(authToken)"
        urlWebsocket = urlWebsocket.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)!
        var request = URLRequest(url: URL(string: urlWebsocket)!)
//        print("Request: \(request)")
        request.timeoutInterval = 5
        appdata.socket = WebSocket(request: request)
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appdata.socket.delegate = appDelegate.self
        appdata.socket.connect()
        fnAddRefreshersNotificationsAndPackages()
        DispatchQueue.main.async {
            self.appdata.fnLoadFriendActivity(tblview: self.tableView, refresherNotification: self.refresherNotification, view: self.noFeedView)
            if (self.appdata.arrMyFeedItems.count == 0) {
                self.noFeedView.isHidden = false
            } else {
                self.noFeedView.isHidden = true
            }
        }

    }
    
    @objc func fnGoToSettings() {
        performSegue(withIdentifier: "segHomeToMe", sender: self)
    }
    
    func fnAddRefreshersNotificationsAndPackages() {
        refresherNotification = UIRefreshControl()
        refresherNotification.addTarget(self, action: #selector(HomeViewController.fnRefreshNotifications), for: UIControlEvents.valueChanged)
        tableView.addSubview(refresherNotification)
    }
    
    @objc func fnRefreshNotifications() {
        if segmentChooser.selectedSegmentIndex == 0 {
            appdata.arrFriendsFeedItems.removeAll()
            print("First Refresh array size: \(appdata.arrFriendsFeedItems.count)")
            appdata.fnLoadFriendActivity(tblview: tableView, refresherNotification: refresherNotification, view: noFeedView)
        } else {
            appdata.arrMyFeedItems.removeAll()
            appdata.fnLoadMyActivity(tblview: tableView, intUserId: appdata.intCurrentUserID, arr: appdata.arrMyFeedItems, refresherNotification: refresherNotification, view: noFeedView)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    // Preloading
    func fnSearchByASIN(strASIN: String) {
//        dispatchGroup.enter()
        let urlGetMyAddresses = URL(string: "https://api.projectmito.io/v1/amazonproductvariety/")
        let parameters: Parameters = [
            "parentASIN": strASIN
        ]
        let headers: HTTPHeaders = [
            "Authorization": UserDefaults.standard.object(forKey: "Authorization") as! String
        ]
        Alamofire.request(urlGetMyAddresses!, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers).validate().responseJSON { response in
            switch response.result {
            case .success:
                if let dictionary = response.value {
                    let objColors = dictionary as! NSDictionary
                    let objColorsKeys = objColors.allKeys as NSArray
                    var intIndex = 0
                    var boolNewIndex = true
                    for color in objColorsKeys {
                        let strColor = color as! String
                        let arrSizes = objColors[strColor] as! NSArray
                        for size in arrSizes {
                            let objSize = size as! NSDictionary
                            let arrASIN = objSize["ASIN"] as! NSArray
                            let strASIN = "\(arrASIN[0])"
                            
                            let arrImageSets = objSize["ImageSets"] as! NSArray
                            let objImageSets = arrImageSets[0] as! NSDictionary
                            let arrImageSet = objImageSets["ImageSet"] as! NSArray
                            var arrImages: [String] = []
                            for image in arrImageSet {
                                let objImage = image as! NSDictionary
                                let arrMedImage = objImage["MediumImage"] as! NSArray
                                let objMedImage = arrMedImage[0] as! NSDictionary
                                let arrURL = objMedImage["URL"] as! NSArray
                                let strURL = arrURL[0] as! String
                                arrImages.append(strURL)
                            }
                            let arrAttributes = objSize["ItemAttributes"] as! NSArray
                            let objAttributes = arrAttributes[0] as! NSDictionary
                            let arrTitle = objAttributes["Title"] as! NSArray
                            let strTitle = arrTitle[0] as! String
                            let arrSize = objAttributes["Size"] as! NSArray
                            let strSize = arrSize[0] as! String
                            
                            let item: Item = Item(strTitle: strTitle, strASIN: strASIN, strSize: strSize, arrImages: arrImages, strColor: strColor)
                            if boolNewIndex {
                                print("New Index: \(intIndex)")
                                self.appdata.arrVariations.insert([item], at: intIndex)
                                boolNewIndex = false
                            } else {
                                self.appdata.arrVariations[intIndex].append(item)
                            }
                        }
                        intIndex += 1
                        boolNewIndex = true
                    }
//                    self.dispatchGroup.leave()
//                    self.dispatchGroup.notify(queue: .main, execute: {
//                        self.viewProductImages.reloadData()
//                    })
                    //                    DispatchGroup.notify(dispatchGroup, DispatchQueue.main, {
                    //                        self.viewProductImages.reloadData()
                    //                    })
                    //                    DispatchQueue.main.asyncAfter(deadline: .now() + 15.0) {
                    //                        self.viewProductImages.reloadData()
                    //                    }
                    //                    DispatchQueue.main.asyncAfter(deadline: .now() + 5.0, execute: nil) {
                    //                        self.viewProductImages.reloadData()
                    //                    }
                    //                    DispatchQueue.main.async {
                    //                        print(self.appdata.arrVariations.count)
                    //                        self.viewProductImages.reloadData()
                    //                    }
                }
            case .failure(let error):
                print("Get products error")
                print(error.localizedDescription)
            }
        }
    }
    
    @IBAction func switchTab(_ sender: UISegmentedControl) {
        if segmentChooser.selectedSegmentIndex == 1 {
            appdata.fnLoadMyActivity(tblview: tableView, intUserId: appdata.intCurrentUserID, arr: appdata.arrMyFeedItems, refresherNotification: refresherNotification, view: noFeedView)
//            if (appdata.arrMyFeedItems.count == 0) {
//                noFeedView.isHidden = false
//            } else {
//                noFeedView.isHidden = true
//            }
        } else {
//            if (appdata.arrFriendsFeedItems.count == 0) {
//                noFeedView.isHidden = false
//            } else {
//                noFeedView.isHidden = true
//            }
            appdata.fnLoadFriendActivity(tblview: tableView, refresherNotification: refresherNotification, view: noFeedView)
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
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 106
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FeedCopyCell", for: indexPath) as! FeedCopyTableViewCell
        var feedItemObj = FeedItem(strDate: "", photoSenderUrl: "", strMessage: "", strRecipientFName: "", strRecipientLName: "", strSenderFName: "", strSenderLName: "", intRecipientId: 0, intSenderId: 0, strPhotoBytes: "")
        if segmentChooser.selectedSegmentIndex == 0 {
            feedItemObj = appdata.arrFriendsFeedItems[indexPath.row]
        } else {
            feedItemObj = appdata.arrMyFeedItems[indexPath.row]
        }
        if feedItemObj.strPhotoBytes != nil {
            appdata.fnDisplayImage(strImageURL: feedItemObj.strPhotoBytes!, img: cell.imgProfile, boolCircle: true)
        } else {
            appdata.fnDisplayImage(strImageURL: feedItemObj.photoSenderUrl, img: cell.imgProfile, boolCircle: true)
        }
        var strSender = "\(feedItemObj.strSenderFName) \(feedItemObj.strSenderLName)"
        var strRecipient = "\(feedItemObj.strRecipientFName) \(feedItemObj.strRecipientLName)"
        if feedItemObj.intSenderId == appdata.intCurrentUserID {
            strSender = "You"
        }
        if feedItemObj.intRecipientId == appdata.intCurrentUserID {
            strRecipient = "You"
        }
        cell.strWho.text = "\(strSender) sent \(strRecipient)"
        cell.strDate.text = "\(appdata.fnUTCToLocal(date: feedItemObj.strDate))"
        cell.strDescr.text = "\(feedItemObj.strMessage)"
        cell.strDescr.numberOfLines = 2
        return cell
    }

    @IBAction func cart(_ sender: Any) {
        performSegue(withIdentifier: "homeToCart", sender: self)
    }
    
    
    
}

extension Dictionary where Key == String, Value == AnyObject {
    func prettyPrint() -> String{
        var string: String = ""
        if let data = try? JSONSerialization.data(withJSONObject: self, options: .prettyPrinted){
            if let nstr = NSString(data: data, encoding: String.Encoding.utf8.rawValue){
                string = nstr as String
            }
        }
        return string
    }
}
