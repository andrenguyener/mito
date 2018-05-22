
//  NotificationViewController.swift
//  Mito 1.0
//
//  Created by Benny on 2/27/18.
//  Copyright © 2018 Benny Souriyadeth. All rights reserved.
//

import UIKit
import Alamofire

var intOrderID = 1

class NotificationViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var notificationView: UIView!
    @IBOutlet weak var tblviewNotification: UITableView!
    var appdata = AppData.shared
    
    var refresherNotification: UIRefreshControl!

    override func viewDidLoad() {
        super.viewDidLoad()
        appdata.arrNotifications.removeAll()
        appdata.arrPendingFriends.removeAll()
        appdata.arrCurrUserPackages.removeAll()
        tblviewNotification.delegate = self
        tblviewNotification.dataSource = self
        tblviewNotification.rowHeight = 100
        self.fnAddRefreshersNotificationsAndPackages()
        self.fnGetPendingFriendRequests()
        self.fnGetPendingPackages()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Hide the navigation bar on the this view controller
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    func fnAddRefreshersNotificationsAndPackages() {
        refresherNotification = UIRefreshControl()
        refresherNotification.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refresherNotification.addTarget(self, action: #selector(NotificationViewController.fnRefreshNotifications), for: UIControlEvents.valueChanged)
        tblviewNotification.addSubview(refresherNotification)
    }
    
    @objc func fnRefreshNotifications() {
        appdata.arrNotifications.removeAll()
        appdata.arrPendingFriends.removeAll()
        appdata.arrCurrUserPackages.removeAll()
        fnGetPendingFriendRequests()
        fnGetPendingPackages()
    }
    
    func fnAcceptOrDeclinePackage(strPackageAction: String, senderId: Int, orderId: Int, shippingAddressId: Int) {
        let urlAcceptOrDeclinePackage = URL(string: "https://api.projectmito.io/v1/package/")
        let parameters: Parameters = [
            "senderId": senderId,
            "orderId": orderId,
            "response": strPackageAction,
            "shippingAddressId": shippingAddressId
        ]
        let headers: HTTPHeaders = [
            "Authorization": UserDefaults.standard.object(forKey: "Authorization") as! String
        ]
        Alamofire.request(urlAcceptOrDeclinePackage!, method: .patch, parameters: parameters, encoding: JSONEncoding.default, headers: headers).validate().responseJSON { response in
            switch response.result {
            case .success:
                if let dictionary = response.result.value {
                    print(dictionary)
                    print("\(response): Successful")
                }
                if strPackageAction != "Denied" {
                    let alert = self.appdata.fnDisplayAlert(title: "Success!", message: "Packaged \(response)")
                    self.present(alert, animated: true, completion: nil)
                }
                DispatchQueue.main.async {
                    self.appdata.arrNotifications.removeAll()
                    self.fnGetPendingPackages()
                    self.fnGetPendingFriendRequests()
                }
                
            case .failure(let error):
                print("Accept or decline package error")
                print(error)
            }
        }
    }
    
    func fnGetPendingPackages() {
        self.appdata.arrCurrUserPackages.removeAll()
        let urlGetPendingPackages = URL(string: "https://api.projectmito.io/v1/package")
        let parameters: Parameters = [
            "type": "Pending"
        ]
        let headers: HTTPHeaders = [
            "Authorization": UserDefaults.standard.object(forKey: "Authorization") as! String
        ]
        Alamofire.request(urlGetPendingPackages!, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers).validate().responseJSON { response in
            switch response.result {
            case .success:
                if let dictionary = response.result.value {
                    print(dictionary)
                    let arrPackages = dictionary as! NSArray
                    for objPackageTemp in arrPackages {
                        print(objPackageTemp)
                        let elem = objPackageTemp as! NSDictionary
                        let objPackage = Package(intGiftOption: elem["GiftOption"] as! Int, strOrderDate: elem["OrderDate"] as! String, intOrderID: elem["OrderId"] as! Int, strOrderMessage: elem["OrderMessage"] as! String, strPhotoUrl: elem["PhotoUrl"] as! String, intSenderID: elem["SenderId"] as! Int, strUserFName: elem["UserFname"] as! String, strUserLName: elem["UserLname"] as! String, dateRequested: self.fnStringToDate(strDate: elem["OrderDate"] as! String))
                        self.appdata.arrNotifications.append(objPackage)
                    }
                }
                DispatchQueue.main.async {
                    self.appdata.arrNotifications.sort(by: self.fnSortNotification)
                    self.tblviewNotification.reloadData()
                    self.refresherNotification.endRefreshing()
                }
                
            case .failure(let error):
                print("Get pending packages error")
                print(error)
            }
        }
    }
    
    func fnGetPendingFriendRequests() {
        let urlGetPendingFriendRequests = URL(string: "https://api.projectmito.io/v1/friend/0")
        appdata.arrPendingFriends.removeAll()
        let headers: HTTPHeaders = [
            "Authorization": UserDefaults.standard.object(forKey: "Authorization") as! String
        ]
        Alamofire.request(urlGetPendingFriendRequests!, method: .get, encoding: JSONEncoding.default, headers: headers).validate().responseJSON { response in
            switch response.result {
            case .success:
                if let dictionary = response.result.value {
                    let dict2 = dictionary as! NSArray
                    for obj in dict2 {
                        let object = obj as! NSDictionary
                        var p: Person = Person(firstName: "", lastName: "", email: "", avatar: "", intUserID: 1, strUsername: "", intNumFriends: 1)
                        if object["CreatedDate"] != nil {
                            p = Person(firstName: (object["UserFname"] as? String)!,
                                       lastName: (object["UserLname"] as? String)!,
                                       email: (object["UserEmail"] as? String?)!!,
                                       avatar: (object["PhotoUrl"] as? String?)!!,
                                       intUserID: (object["UserId"] as? Int)!,
                                       strUsername: (object["Username"] as? String)!,
                                       intNumFriends: (object["NumFriends"] as! Int),
                                       dateRequested: self.fnStringToDate(strDate: object["CreatedDate"] as! String))
                        } else {
                            p = Person(firstName: (object["UserFname"] as? String)!,
                                       lastName: (object["UserLname"] as? String)!,
                                       email: (object["UserEmail"] as? String?)!!,
                                       avatar: (object["PhotoUrl"] as? String?)!!,
                                       intUserID: (object["UserId"] as? Int)!,
                                       strUsername: (object["Username"] as? String)!,
                                       intNumFriends: (object["NumFriends"] as! Int))
                        }
                        self.appdata.arrNotifications.append(p)
                        self.appdata.arrPendingFriends.append(p)
                    }
                    DispatchQueue.main.async {
                        self.appdata.arrNotifications.sort(by: self.fnSortNotification)
                        self.tblviewNotification.reloadData()
                    }
                }
                
            case .failure(let error):
                print("Get pending users error")
                print(error)
            }
        }
    }
    
    func fnStringToDate(strDate: String) -> Date {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        return formatter.date(from: strDate)!
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return appdata.arrNotifications.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        boolSender = false
        intOrderID = indexPath.row
        if ((appdata.arrNotifications[indexPath.row] as? Package) != nil) {
            appdata.currPackage = appdata.arrNotifications[indexPath.row] as! Package
            performSegue(withIdentifier: "NotificationToPackageDetails", sender: self)
        } else {
            appdata.personToView = appdata.arrNotifications[indexPath.row] as! Person
            performSegue(withIdentifier: "CheckFriendRequest", sender: self)
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func fnAcceptOrDeclineFriendRequest(strFriendType: String, intUserID: Int) {
        let urlAcceptFriendRequest = URL(string: "https://api.projectmito.io/v1/friend/request")
        let parameters: Parameters = [
            "friendId": intUserID,
            "friendType": strFriendType,
            "notificationType": strFriendType
        ]
        let headers: HTTPHeaders = [
            "Authorization": UserDefaults.standard.object(forKey: "Authorization") as! String
        ]
        Alamofire.request(urlAcceptFriendRequest!, method: .patch, parameters: parameters, encoding: JSONEncoding.default, headers: headers).validate().responseString { response in
            switch response.result {
            case .success:
                if response.result.value != nil {
                   print("Successfully accepted friend request")
                }
                if strFriendType == "Friend" {
                    let alert = self.appdata.fnDisplayAlert(title: "Success!", message: "Friend request accepted")
                    self.present(alert, animated: true, completion: nil)
                }
                DispatchQueue.main.async {
                    self.appdata.arrNotifications.removeAll()
                    self.fnGetPendingPackages()
                    self.fnGetPendingFriendRequests()
                }
                
            case .failure(let error):
                print("Could not accept user")
                print(error)
            }
        }
    }
    
    @objc func btnAccept(_ button: UIButton) {
        boolSender = true
        if appdata.arrNotifications[button.tag] as? Person != nil {
            let objFriend = appdata.arrNotifications[button.tag] as! Person
            intOrderID = objFriend.intUserID
            fnAcceptOrDeclineFriendRequest(strFriendType: "Friend", intUserID: intOrderID)
        } else {
            boolSender = !boolSender
            appdata.currPackage = appdata.arrNotifications[button.tag] as! Package
            performSegue(withIdentifier: "DirectAcceptPackage", sender: self)
        }
    }
    
    @objc func btnDeny(_ button: UIButton) {
        boolSender = true
        if appdata.arrNotifications[button.tag] as? Person != nil {
            let objFriend = appdata.arrNotifications[button.tag] as! Person
            fnAcceptOrDeclineFriendRequest(strFriendType: "Unfriend", intUserID: objFriend.intUserID)
        } else {
            let package = appdata.arrNotifications[button.tag] as! Package
            fnAcceptOrDeclinePackage(strPackageAction: "Denied", senderId: package.intSenderID, orderId: package.intOrderID, shippingAddressId: appdata.arrCurrUserAddresses[0].intAddressID!)
        }
    }
    
    func UTCToLocal(date:String) -> String {
        print("UTC: \(date)")
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        formatter.timeZone = TimeZone(abbreviation: "UTC")
        
        // Apply UTC
        let dt = formatter.date(from: date)
        
        // Change to current
        formatter.timeZone = TimeZone.current
        formatter.dateFormat = "MMM d, h:mm a"
        print("Local: \(formatter.string(from: dt!))")
        
        return formatter.string(from: dt!)
    }
    
    func fnConvertDateToString(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        return formatter.string(from: date)
    }
    
    func fnConvertStringToDate(date: String) -> Date {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        return formatter.date(from: date)!
    }

    func fnSortNotification(this: Notification, that: Notification) -> Bool {
        return this.dateRequested.compare(that.dateRequested) != .orderedAscending
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Friend Requests
        let cell = tblviewNotification.dequeueReusableCell(withIdentifier: "cellNotification", for: indexPath) as! NotificationTableViewCell
        let objNotification = appdata.arrNotifications[indexPath.row]
        if let objPackage = objNotification as? Package {
            let strDate = UTCToLocal(date: objPackage.strOrderDate)
            appdata.fnDisplayImage(strImageURL: objPackage.strPhotoUrl, img: cell.imgPerson, boolCircle: true)
            cell.strFirstNameLastName.text = "\(objPackage.strUserFName) has sent you a package request"
            cell.strUsername.text = strDate
            cell.btnConfirm.tag = indexPath.row
            cell.btnConfirm.addTarget(self, action: #selector(self.btnAccept(_:)), for: .touchUpInside)
            cell.btnDecline.tag = indexPath.row
            cell.btnDecline.addTarget(self, action: #selector(self.btnDeny(_:)), for: .touchUpInside)
        } else {
            let objFriendRequest = objNotification as! Person
            let strDate = fnConvertDateToString(date: objFriendRequest.dateRequested)
            let dateLocal = UTCToLocal(date: strDate)
            appdata.fnDisplayImage(strImageURL: objFriendRequest.avatar, img: cell.imgPerson, boolCircle: true)
            cell.strFirstNameLastName.text = "\(objFriendRequest.strUsername) has sent you a friend request"
            cell.strUsername.text = dateLocal
            cell.btnConfirm.tag = indexPath.row
            cell.btnConfirm.addTarget(self, action: #selector(self.btnAccept(_:)), for: .touchUpInside)
            cell.btnDecline.tag = indexPath.row
            cell.btnDecline.addTarget(self, action: #selector(self.btnDeny(_:)), for: .touchUpInside)
        }
        return cell
    }
}
