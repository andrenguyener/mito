
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
    var appdata = AppData.shared

    @IBOutlet weak var notificationView: UIView!
    @IBOutlet weak var tblviewNotification: UITableView!
    
    @IBOutlet weak var imgSender: UIImageView!
    @IBOutlet weak var strPackageSenderName: UILabel!
    
    var refresherNotification: UIRefreshControl!
    
    var urlAcceptFriendRequest = URL(string: "https://api.projectmito.io/v1/friend/request")

    override func viewDidLoad() {
        super.viewDidLoad()
        if tblviewNotification != nil {
            appdata.arrNotifications.removeAll()
            appdata.arrPendingFriends.removeAll()
            self.fnGetPendingFriendRequests()
            tblviewNotification.delegate = self
            tblviewNotification.dataSource = self
            tblviewNotification.rowHeight = 100
//            fnAddRefreshersNotificationsAndPackages()
            fnGetPendingPackages()
            appdata.arrNotifications.sort(by: )
        } else if imgSenderProfile != nil {
            appdata.fnDisplaySimpleImage(strImageURL: appdata.arrCurrUserPackages[intOrderID].strPhotoUrl, img: imgSenderProfile)
            fnRetrieveIncomingOrderDetails(intOrderID: intOrderID)
            strSenderName.text = "\(appdata.arrCurrUserPackages[intOrderID].strUserFName) \(appdata.arrCurrUserPackages[intOrderID].strUserLName)"
            lblMessage.text = appdata.arrCurrUserPackages[intOrderID].strOrderMessage
        } else {
            let objIncomingPackage = appdata.arrCurrUserPackages[intOrderID]
            strPackageSenderName.text = "\(objIncomingPackage.strUserFName) \(objIncomingPackage.strUserLName)"
            let urlPersonImage = URL(string:"\(objIncomingPackage.strPhotoUrl)")
            appdata.fnDisplaySimpleImage(strImageURL: objIncomingPackage.strPhotoUrl, img: imgSender)
//            let defaultURL = URL(string: "https://scontent.fsea1-1.fna.fbcdn.net/v/t31.0-8/17621927_1373277742718305_6317412440813490485_o.jpg?oh=4689a54bc23bc4969eacad74b6126fea&oe=5B460897")
//            if let data = try? Data(contentsOf: urlPersonImage!) {
//                imgSender.image = UIImage(data: data)!
//            } else if let data = try? Data(contentsOf: defaultURL!){
//                imgSender.image = UIImage(data: data)
//            }
            print(appdata.arrCurrUserPackages[intOrderID].intOrderID)
            fnGetOrderDetails()
        }
    }
    
    func fnRetrieveIncomingOrderDetails(intOrderID: Int) {
        let urlRetrieveIncomingOrderDetails = URL(string: "https://api.projectmito.io/v1/order/products")
        let parameters: Parameters = [
            "orderId": intOrderID
        ]
        let headers: HTTPHeaders = [
            "Authorization": UserDefaults.standard.object(forKey: "Authorization") as! String
        ]
        Alamofire.request(urlRetrieveIncomingOrderDetails!, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers).validate().responseJSON { response in
            switch response.result {
            case .success:
                if let dictionary = response.result.value {
                    print(dictionary)
                    print("\(response): Successful")
                }
                
            case .failure(let error):
                print("Can't get order details")
                print(error)
            }
        }
    }

    
    @IBOutlet weak var imgSenderProfile: UIImageView!
    @IBOutlet weak var strSenderName: UILabel!
    @IBOutlet weak var lblMessage: UILabel!

    @objc func fnRefreshNotifications() {
        fnGetPendingFriendRequests()
    }
//
//    @objc func fnRefreshPackages() {
//        fnGetPendingPackages()
//    }
    
    func fnGetOrderDetails() {
        let urlGetOrderDetails = URL(string: "https://api.projectmito.io/v1/order/products")
        let parameters: Parameters = [
            "orderId": appdata.arrCurrUserPackages[intOrderID].intOrderID
        ]
        let headers: HTTPHeaders = [
            "Authorization": UserDefaults.standard.object(forKey: "Authorization") as! String
        ]
        Alamofire.request(urlGetOrderDetails!, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers).validate().responseJSON { response in
            switch response.result {
            case .success:
                if let dictionary = response.result.value {
                    print("Successfully pulled down")
                    print(dictionary)
                }
                
            case .failure(let error):
                print("Get order details error")
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
                        let elem = objPackageTemp as! NSDictionary
                        let objPackage = Package(intGiftOption: elem["GiftOption"] as! Int, strOrderDate: elem["OrderDate"] as! String, intOrderID: elem["OrderId"] as! Int, strOrderMessage: elem["OrderMessage"] as! String, strPhotoUrl: elem["PhotoUrl"] as! String, intSenderID: elem["SenderId"] as! Int, strUserFName: elem["UserFname"] as! String, strUserLName: elem["UserLname"] as! String)
                        self.appdata.arrNotifications.append(objPackage)
//                        self.appdata.arrCurrUserPackages.append(objPackage)
                    }
//                    print("User has \(self.appdata.arrCurrUserPackages.count) packages")
                }
                DispatchQueue.main.async {
                    self.tblviewNotification.reloadData()
//                    self.refresherNotification.endRefreshing()
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
                        print(object)
                        let p: Person = Person(firstName: (object["UserFname"] as? String)!,
                                               lastName: (object["UserLname"] as? String)!,
                                               email: (object["UserEmail"] as? String?)!!,
                                               avatar: (object["PhotoUrl"] as? String?)!!,
                                               intUserID: (object["UserId"] as? Int)!,
                                               strUsername: (object["Username"] as? String)!,
                                               intNumFriends: (object["NumFriends"] as! Int))
                        self.appdata.arrNotifications.append(p)
                        self.appdata.arrPendingFriends.append(p)
                    }
                    print("Pending Friend Requests: \(self.appdata.arrPendingFriends.count)")
                    DispatchQueue.main.async {
                        self.tblviewNotification.reloadData()
//                        self.refresherNotification.endRefreshing()
                    }
                }
                
            case .failure(let error):
                print("Get pending users error")
                print(error)
            }
        }
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
        print(indexPath.row)
//            performSegue(withIdentifier: "NotificationToPackageDetails", sender: self)
    }
    
    // Accept currently creates errors above
    
    @IBAction func btnPackageDetailsBackToNotification(_ sender: Any) {
        performSegue(withIdentifier: "PackageDetailsBackToNotification", sender: self)
    }
    
    @IBAction func btnAcceptAndChooseReceivingAddress(_ sender: Any) {
        boolSender = false
        performSegue(withIdentifier: "PackageToChooseReceivingAddress", sender: self)
    }
    
    func fnAcceptOrDeclinePackage(response: String, senderId: Int, orderId: Int, shippingAddressId: Int) {
        let urlAcceptOrDeclinePackage = URL(string: "https://api.projectmito.io/v1/package/")
        let parameters: Parameters = [
            "senderId": senderId,
            "orderId": orderId,
            "response": response,
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
                let alert = self.appdata.fnDisplayAlert(title: "Success!", message: "Packaged \(response)")
                self.present(alert, animated: true, completion: nil)
                
            case .failure(let error):
                print("Accept or decline package error")
                print(error)
            }
        }
    }
    
    @objc func btnAcceptFriendRequest(_ button: UIButton) {
        let objFriend = appdata.arrNotifications[button.tag] as! Person
        let intUserID = objFriend.intUserID
        fnAcceptOrDeclineFriendRequest(strFriendType: "Friend", intUserID: intUserID)
    }
    
    @objc func btnDeclineFriendRequest(_ button: UIButton) {
        let objFriend = appdata.arrNotifications[button.tag] as! Person
        let intUserID = objFriend.intUserID
        fnAcceptOrDeclineFriendRequest(strFriendType: "Unfriend", intUserID: intUserID)
    }
    
    func fnAcceptOrDeclineFriendRequest(strFriendType: String, intUserID: Int) {
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
    
    @objc func btnAcceptPackage(_ button: UIButton) {
        boolSender = false
        let package = appdata.arrNotifications[button.tag] as! Package
        let intOrderID = package.intOrderID
        performSegue(withIdentifier: "DirectAcceptPackage", sender: self)
    }
    
    @objc func btnDenyPackage(_ button: UIButton) {
        boolSender = false
        let package = appdata.arrNotifications[button.tag] as! Package
        fnAcceptOrDeclinePackage(response: "Denied", senderId: package.intSenderID, orderId: package.intOrderID, shippingAddressId: appdata.arrCurrUserAddresses[0].intAddressID)
    }
    
    func UTCToLocal(date:String) -> String {
        let formatter = DateFormatter()
        // formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        formatter.timeZone = TimeZone(abbreviation: "UTC")
        
        let dt = formatter.date(from: date)
        print(dt?.description)
        formatter.timeZone = TimeZone.current
        print(TimeZone.current.description)
        formatter.dateFormat = "h:mm a"
        print(formatter.string(from: dt!))
        
        return formatter.string(from: dt!)
    }
    
    func fnSortMitoUsers(this: Person, that: Person) -> Bool {
        return this.intNumFriends < that.intNumFriends
    }

    func fnSortNotification(this: Package, that: Person) {
        return this.strDate 
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Friend Requests
        let cell = tblviewNotification.dequeueReusableCell(withIdentifier: "cellNotification", for: indexPath) as! NotificationTableViewCell
        print(indexPath.row)
        let objNotification = appdata.arrNotifications[indexPath.row]
        if let objPackage = objNotification as? Package {
            let strDate = UTCToLocal(date: objPackage.strOrderDate)
            let urlPersonImage = URL(string:"\(objPackage.strPhotoUrl)")
            let defaultURL = URL(string: "https://scontent.fsea1-1.fna.fbcdn.net/v/t31.0-8/17621927_1373277742718305_6317412440813490485_o.jpg?oh=4689a54bc23bc4969eacad74b6126fea&oe=5B460897")
            if let data = try? Data(contentsOf: urlPersonImage!) {
                cell.imgPerson.image = UIImage(data: data)!
            } else if let data = try? Data(contentsOf: defaultURL!){
                cell.imgPerson.image = UIImage(data: data)
            }
            cell.strFirstNameLastName.text = "\(objPackage.strUserFName) \(objPackage.strUserLName) has sent you a package request"
            cell.strUsername.text = strDate
            cell.btnConfirm.tag = indexPath.row
            cell.btnConfirm.addTarget(self, action: #selector(self.btnAcceptPackage(_:)), for: .touchUpInside)
            cell.btnDecline.tag = indexPath.row
            cell.btnDecline.addTarget(self, action: #selector(self.btnDenyPackage(_:)), for: .touchUpInside)
        } else {
            let objFriendRequest = objNotification as! Person
            let urlPersonImage = URL(string:"\(objFriendRequest.avatar)")
            let defaultURL = URL(string: "https://scontent.fsea1-1.fna.fbcdn.net/v/t31.0-8/17621927_1373277742718305_6317412440813490485_o.jpg?oh=4689a54bc23bc4969eacad74b6126fea&oe=5B460897")
            if let data = try? Data(contentsOf: urlPersonImage!) {
                cell.imgPerson.image = UIImage(data: data)!
            } else if let data = try? Data(contentsOf: defaultURL!){
                cell.imgPerson.image = UIImage(data: data)
            }
            cell.strFirstNameLastName.text = "\(objFriendRequest.firstName) \(objFriendRequest.lastName) has sent you a friend request"
            cell.strUsername.text = String(objFriendRequest.intNumFriends)
            cell.btnConfirm.tag = indexPath.row
            cell.btnConfirm.addTarget(self, action: #selector(self.btnAcceptFriendRequest(_:)), for: .touchUpInside)
            cell.btnDecline.tag = indexPath.row
            cell.btnDecline.addTarget(self, action: #selector(self.btnDeclineFriendRequest(_:)), for: .touchUpInside)
        }
        return cell
    }
}
