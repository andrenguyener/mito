//
//  NotificationViewController.swift
//  Mito 1.0
//
//  Created by Benny on 2/27/18.
//  Copyright © 2018 Benny Souriyadeth. All rights reserved.
//

import UIKit
import Alamofire

class NotificationViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    var appdata = AppData.shared

    @IBOutlet weak var packageInView: UIView!
    @IBOutlet weak var notificationView: UIView!
    @IBOutlet weak var tblviewPackage: UITableView!
    @IBOutlet weak var segment: UISegmentedControl!
    @IBOutlet weak var tblviewNotification: UITableView!
    
    var urlPeopleCall = URL(string: "https://api.projectmito.io/v1/friend/")
    var urlAcceptFriendRequest = URL(string: "https://api.projectmito.io/v1/friend/request")
    var urlGetPendingPackages = URL(string: "https://api.projectmito.io/v1/package/pending")
    
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
        tblviewPackage.isHidden = true
        appdata.arrPendingFriends.removeAll()
        self.fnGetPendingFriendRequests()
        tblviewNotification.delegate = self
        tblviewNotification.dataSource = self
        tblviewNotification.rowHeight = 100
        tblviewPackage.delegate = self
        tblviewPackage.dataSource = self
        tblviewPackage.rowHeight = 100
        fnGetPendingPackages()
    }
    
    func fnGetPendingPackages() {
        appdata.arrCurrUserPackages.removeAll()
        let urlGetPendingPackages = URL(string: "https://api.projectmito.io/v1/package/pending")
        let headers: HTTPHeaders = [
            "Authorization": UserDefaults.standard.object(forKey: "Authorization") as! String
        ]
        Alamofire.request(urlGetPendingPackages!, method: .get, encoding: JSONEncoding.default, headers: headers).validate().responseJSON { response in
            switch response.result {
            case .success:
                if let dictionary = response.result.value {
                    print(dictionary)
                    let arrPackages = dictionary as! NSArray
                    for objPackageTemp in arrPackages {
                        let elem = objPackageTemp as! NSDictionary
                        print(elem)
                        let objPackage = Package(intGiftOption: elem["GiftOption"] as! Int, strOrderDate: elem["OrderDate"] as! String, intOrderID: elem["OrderId"] as! Int, strOrderMessage: elem["OrderMessage"] as! String, strPhotoUrl: elem["PhotoUrl"] as! String, intSenderID: elem["SenderId"] as! Int, strUserFName: elem["UserFname"] as! String, strUserLName: elem["UserLname"] as! String)//
                        self.appdata.arrCurrUserPackages.append(objPackage)
                    }
                    print("User has \(self.appdata.arrCurrUserPackages.count) packages")
                }
                DispatchQueue.main.async {
                    self.tblviewPackage.reloadData()
                }
                
            case .failure(let error):
                print("Get pending packages error")
                print(error)
            }
        }
    }
    
    func fnGetPendingFriendRequests() {
        let urlGetFriends = URL(string: (urlPeopleCall?.absoluteString)! + "0")
        let headers: HTTPHeaders = [
            "Authorization": UserDefaults.standard.object(forKey: "Authorization") as! String
        ]
        Alamofire.request(urlGetFriends!, method: .get, encoding: JSONEncoding.default, headers: headers).validate().responseJSON { response in
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
                        self.appdata.arrPendingFriends.append(p)
                        DispatchQueue.main.async {
                            self.tblviewNotification.reloadData()
                        }
                    }
                }
                
            case .failure(let error):
                print("Get pending users error")
                print(error)
            }
        }
    }
    
    @IBAction func btnAcceptPackage(_ sender: Any) {
        print("Hypothetical accept")
//        fnAcceptOrDeclinePackage(response: "Accepted")
    }

    @IBAction func btnDenyPackage(_ sender: Any) {
        print("Hypothetical denied")
//        fnAcceptOrDeclinePackage(response: "Denied")
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
        if segment.selectedSegmentIndex == 0 {
            let person = appdata.arrPendingFriends[indexPath.row]
            self.fnAcceptFriendRequest(person: person)
        } else {
            let package = appdata.arrCurrUserPackages[indexPath.row]
            print("\(appdata.arrCurrUserAddresses.count)")
            fnAcceptOrDeclinePackage(response: "Accepted", senderId: package.intSenderID, orderId: package.intOrderID, shippingAddressId: appdata.arrCurrUserAddresses[0].intAddressID)
        }
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
                    print("Success")
                }
                
            case .failure(let error):
                print("Accept or decline package error")
                print(error)
            }
        }
    }
    
    func fnAcceptFriendRequest(person: Person) {
        let parameters: Parameters = [
            "friendId": person.intUserID,
            "friendType": "Friend",
            "notificationType": "Friend"
        ]
        let headers: HTTPHeaders = [
            "Authorization": UserDefaults.standard.object(forKey: "Authorization") as! String
        ]
        Alamofire.request(urlAcceptFriendRequest!, method: .patch, parameters: parameters, encoding: JSONEncoding.default, headers: headers).validate().responseString { response in
            switch response.result {
            case .success:
                if response.result.value != nil {
                    DispatchQueue.main.async {
                        self.tblviewNotification.reloadData()
                        self.appdata.arrPendingFriends.removeAll()
                        self.fnGetPendingFriendRequests()
                    }
                }
                
            case .failure(let error):
                print("Get pending users error")
                print(error)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
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
            }
            return cell
        } else {
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
            return cell
        }
    }
}
