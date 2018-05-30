//
//  TabBarViewController.swift
//  Mito 1.0
//
//  Created by Benny on 5/30/18.
//  Copyright © 2018 Benny Souriyadeth. All rights reserved.
//

import UIKit
import Alamofire

class TabBarViewController: UITabBarController {

    var appdata = AppData.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.appdata.arrNotifications.removeAll()
        fnGetPendingFriendRequests()
        fnGetPendingPackages()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
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
                        var strAvatar = object["ProfileImage"] as! String
                        if strAvatar == self.appdata.strImageDefault || strAvatar == "AAP4AHUXf+Y=" {
                            strAvatar = object["PhotoUrl"] as! String
                        }
                        if object["CreatedDate"] != nil {
                            p = Person(firstName: (object["UserFname"] as? String)!,
                                       lastName: (object["UserLname"] as? String)!,
                                       email: (object["UserEmail"] as? String?)!!,
                                       avatar: strAvatar,
                                       intUserID: (object["UserId"] as? Int)!,
                                       strUsername: (object["Username"] as? String)!,
                                       intNumFriends: (object["NumFriends"] as! Int),
                                       dateRequested: self.fnStringToDate(strDate: object["CreatedDate"] as! String))
                        } else {
                            p = Person(firstName: (object["UserFname"] as? String)!,
                                       lastName: (object["UserLname"] as? String)!,
                                       email: (object["UserEmail"] as? String?)!!,
                                       avatar: strAvatar,
                                       intUserID: (object["UserId"] as? Int)!,
                                       strUsername: (object["Username"] as? String)!,
                                       intNumFriends: (object["NumFriends"] as! Int))
                        }
                        self.appdata.arrNotifications.append(p)
                        self.appdata.arrPendingFriends.append(p)
                    }
                    self.appdata.arrNotifications.sort(by: self.fnSortNotification)
                    DispatchQueue.main.async {
                        self.tabBar.items?.last?.badgeValue = String(self.appdata.arrNotifications.count)
                    }
                }
                
            case .failure(let error):
                print("Get pending users error")
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
                        print(elem)
                        var strAvatar = elem["SenderProfileImage"] as! String
                        if strAvatar == self.appdata.strImageDefault || strAvatar == "AAP4AHUXf+Y=" {
                            strAvatar = elem["PhotoUrl"] as! String
                        }
                        let objPackage = Package(intGiftOption: elem["GiftOption"] as! Int, strOrderDate: elem["OrderDate"] as! String, intOrderID: elem["OrderId"] as! Int, strOrderMessage: elem["OrderMessage"] as! String, strPhotoUrl: strAvatar, intSenderID: elem["SenderId"] as! Int, strUserFName: elem["UserFname"] as! String, strUserLName: elem["UserLname"] as! String, dateRequested: self.fnStringToDate(strDate: elem["OrderDate"] as! String))
                        self.appdata.arrNotifications.append(objPackage)
                    }
                }
                self.appdata.arrNotifications.sort(by: self.fnSortNotification)
                DispatchQueue.main.async {
                    // to apply it to your last tab
                    self.tabBar.items?.last?.badgeValue = String(self.appdata.arrNotifications.count)
                }
                
            case .failure(let error):
                print("Get pending packages error")
                print(error)
            }
        }
    }
    
    func fnSortNotification(this: Notification, that: Notification) -> Bool {
        return this.dateRequested.compare(that.dateRequested) != .orderedAscending
    }
    
    func fnStringToDate(strDate: String) -> Date {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        return formatter.date(from: strDate)!
    }
    
}
