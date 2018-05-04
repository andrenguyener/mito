//
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

    @IBOutlet weak var packageInView: UIView!
    @IBOutlet weak var notificationView: UIView!
    @IBOutlet weak var tblviewPackage: UITableView!
    @IBOutlet weak var segment: UISegmentedControl!
    @IBOutlet weak var tblviewNotification: UITableView!
    
    @IBOutlet weak var imgSender: UIImageView!
    @IBOutlet weak var strPackageSenderName: UILabel!
    
    var refresherNotification: UIRefreshControl!
    var refresherPackage: UIRefreshControl!
    
    var urlAcceptFriendRequest = URL(string: "https://api.projectmito.io/v1/friend/request")
    
    @IBAction func segmentControl(_ sender: Any) {
        if segment.selectedSegmentIndex == 0 {
            tblviewNotification.isHidden = false
            tblviewPackage.isHidden = true
            UIView.transition(from: packageInView, to: notificationView, duration: 0, options: .showHideTransitionViews)
        } else {
            tblviewPackage.isHidden = false
            tblviewNotification.isHidden = true
            fnGetPendingPackages()
            UIView.transition(from: notificationView, to: packageInView, duration: 0, options: .showHideTransitionViews)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        if tblviewPackage != nil && tblviewNotification != nil {
            tblviewPackage.isHidden = true
            appdata.arrPendingFriends.removeAll()
            self.fnGetPendingFriendRequests()
            tblviewNotification.delegate = self
            tblviewNotification.dataSource = self
            tblviewNotification.rowHeight = 100
            tblviewPackage.delegate = self
            tblviewPackage.dataSource = self
            tblviewPackage.rowHeight = 100
            refresherNotification = UIRefreshControl()
            refresherNotification.attributedTitle = NSAttributedString(string: "Pull to refresh")
            refresherNotification.addTarget(self, action: #selector(NotificationViewController.fnRefreshNotifications), for: UIControlEvents.valueChanged)
            tblviewNotification.addSubview(refresherNotification)
            refresherPackage = UIRefreshControl()
            refresherPackage.attributedTitle = NSAttributedString(string: "Pull to refresh")
            refresherPackage.addTarget(self, action: #selector(NotificationViewController.fnRefreshPackages), for: UIControlEvents.valueChanged)
            tblviewPackage.addSubview(refresherPackage)
            fnGetPendingPackages()
        } else if imgSenderProfile != nil {
            appdata.fnDisplaySimpleImage(strImageURL: appdata.arrCurrUserPackages[intOrderID].strPhotoUrl, img: imgSenderProfile)
            strSenderName.text = "\(appdata.arrCurrUserPackages[intOrderID].strUserFName) \(appdata.arrCurrUserPackages[intOrderID].strUserLName)"
            lblMessage.text = appdata.arrCurrUserPackages[intOrderID].strOrderMessage
        } else {
            let objIncomingPackage = appdata.arrCurrUserPackages[intOrderID]
            strPackageSenderName.text = "\(objIncomingPackage.strUserFName) \(objIncomingPackage.strUserLName)"
            let urlPersonImage = URL(string:"\(objIncomingPackage.strPhotoUrl)")
            let defaultURL = URL(string: "https://scontent.fsea1-1.fna.fbcdn.net/v/t31.0-8/17621927_1373277742718305_6317412440813490485_o.jpg?oh=4689a54bc23bc4969eacad74b6126fea&oe=5B460897")
            if let data = try? Data(contentsOf: urlPersonImage!) {
                imgSender.image = UIImage(data: data)!
            } else if let data = try? Data(contentsOf: defaultURL!){
                imgSender.image = UIImage(data: data)
            }
            print(appdata.arrCurrUserPackages[intOrderID].intOrderID)
            fnGetOrderDetails()
        }
    }
    
    @IBOutlet weak var imgSenderProfile: UIImageView!
    @IBOutlet weak var strSenderName: UILabel!
    @IBOutlet weak var lblMessage: UILabel!
    
    
    
    @objc func fnRefreshNotifications() {
        fnGetPendingFriendRequests()
    }
    
    @objc func fnRefreshPackages() {
        fnGetPendingPackages()
    }
    
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
                        let objPackage = Package(intGiftOption: elem["GiftOption"] as! Int, strOrderDate: elem["OrderDate"] as! String, intOrderID: elem["OrderId"] as! Int, strOrderMessage: elem["OrderMessage"] as! String, strPhotoUrl: elem["PhotoUrl"] as! String, intSenderID: elem["SenderId"] as! Int, strUserFName: elem["UserFname"] as! String, strUserLName: elem["UserLname"] as! String)//
                        self.appdata.arrCurrUserPackages.append(objPackage)
                    }
                    print("User has \(self.appdata.arrCurrUserPackages.count) packages")
                }
                DispatchQueue.main.async {
                    self.tblviewPackage.reloadData()
                    self.refresherPackage.endRefreshing()
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
                        let p: Person = Person(firstName: (object["UserFname"] as? String)!,
                                               lastName: (object["UserLname"] as? String)!,
                                               email: (object["UserEmail"] as? String?)!!,
                                               avatar: (object["PhotoUrl"] as? String?)!!,
                                               intUserID: (object["UserId"] as? Int)!,
                                               strUsername: (object["Username"] as? String)!,
                                               intNumFriends: (object["NumFriends"] as! Int))
                        self.appdata.arrPendingFriends.append(p)
                    }
                    print("Pending Friend Requests: \(self.appdata.arrPendingFriends.count)")
                    DispatchQueue.main.async {
                        self.tblviewNotification.reloadData()
                        self.refresherNotification.endRefreshing()
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
        if segment.selectedSegmentIndex == 0 {
            return appdata.arrPendingFriends.count
        } else {
            return appdata.arrCurrUserPackages.count
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if segment.selectedSegmentIndex == 1 {
            boolSender = false
            intOrderID = indexPath.row
            performSegue(withIdentifier: "NotificationToPackageDetails", sender: self)
        }
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
        let intUserID = appdata.arrPendingFriends[button.tag].intUserID
        fnAcceptOrDeclineFriendRequest(strFriendType: "Friend", intUserID: intUserID)
    }
    
    @objc func btnDeclineFriendRequest(_ button: UIButton) {
        print(appdata.arrPendingFriends[button.tag].intUserID)
        let intUserID = appdata.arrPendingFriends[button.tag].intUserID
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
                    self.tblviewNotification.reloadData()
                    self.appdata.arrPendingFriends.removeAll()
                    self.fnGetPendingFriendRequests()
                }
                
            case .failure(let error):
                print("Could not accept user")
                print(error)
            }
        }
    }
    
    @objc func btnAcceptPackage(_ button: UIButton) {
        let package = appdata.arrCurrUserPackages[button.tag]
        fnAcceptOrDeclinePackage(response: "Accepted", senderId: package.intSenderID, orderId: package.intOrderID, shippingAddressId: appdata.arrCurrUserAddresses[0].intAddressID)
    }
    
    @objc func btnDenyPackage(_ button: UIButton) {
        let package = appdata.arrCurrUserPackages[button.tag]
        fnAcceptOrDeclinePackage(response: "Denied", senderId: package.intSenderID, orderId: package.intOrderID, shippingAddressId: appdata.arrCurrUserAddresses[0].intAddressID)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Friend Requests
        if segment.selectedSegmentIndex == 0 {
            let cell = tblviewNotification.dequeueReusableCell(withIdentifier: "cellNotification", for: indexPath) as! NotificationTableViewCell
            if appdata.arrPendingFriends.count > 0 {
                let objPerson = appdata.arrPendingFriends[indexPath.row]
                cell.strFirstNameLastName.text = "\(objPerson.firstName) \(objPerson.lastName)"
                cell.strUsername.text =  objPerson.strUsername
                let urlPersonImage = URL(string:"\(objPerson.avatar)")
                let defaultURL = URL(string: "https://scontent.fsea1-1.fna.fbcdn.net/v/t31.0-8/17621927_1373277742718305_6317412440813490485_o.jpg?oh=4689a54bc23bc4969eacad74b6126fea&oe=5B460897")
                if let data = try? Data(contentsOf: urlPersonImage!) {
                    cell.imgPerson.image = UIImage(data: data)!
                } else if let data = try? Data(contentsOf: defaultURL!){
                    cell.imgPerson.image = UIImage(data: data)
                }
                cell.btnConfirm.tag = indexPath.row
                cell.btnConfirm.addTarget(self, action: #selector(self.btnAcceptFriendRequest(_:)), for: .touchUpInside)
                cell.btnDecline.tag = indexPath.row
                cell.btnDecline.addTarget(self, action: #selector(self.btnDeclineFriendRequest(_:)), for: .touchUpInside)
            }
            return cell
        } else { // In
            let cell = tblviewPackage.dequeueReusableCell(withIdentifier: "cellPackage", for: indexPath) as! PackageTableViewCell
            let objPackage = appdata.arrCurrUserPackages[indexPath.row]
            cell.strFnameLname.text = "\(objPackage.strUserFName) \(objPackage.strUserLName)"
            let urlPersonImage = URL(string:"\(objPackage.strPhotoUrl)")
            let defaultURL = URL(string: "https://scontent.fsea1-1.fna.fbcdn.net/v/t31.0-8/17621927_1373277742718305_6317412440813490485_o.jpg?oh=4689a54bc23bc4969eacad74b6126fea&oe=5B460897")
            if let data = try? Data(contentsOf: urlPersonImage!) {
                cell.imgPerson.image = UIImage(data: data)!
            } else if let data = try? Data(contentsOf: defaultURL!){
                cell.imgPerson.image = UIImage(data: data)
            }
            cell.btnAccept.tag = indexPath.row
            cell.btnAccept.addTarget(self, action: #selector(self.btnAcceptPackage(_:)), for: .touchUpInside)
            cell.btnDeny.tag = indexPath.row
            cell.btnDeny.addTarget(self, action: #selector(self.btnDenyPackage(_:)), for: .touchUpInside)
            return cell
        }
    }
}
