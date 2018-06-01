
//  AppDelegate.swift
//  Mito 1.0
//
//  Created by Benny on 2/22/18.
//  Copyright © 2018 Benny Souriyadeth. All rights reserved.
//

import UIKit
import GooglePlaces
import GoogleMaps
import Starscream
import Alamofire

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, WebSocketDelegate {
    
    var appdata = AppData.shared
    let tabBarController = UITabBarController()
    
    func websocketDidConnect(socket: WebSocketClient) {
        print("websocket is connected")
    }
    
    func websocketDidDisconnect(socket: WebSocketClient, error: Error?) {
        if let e = error as? WSError {
            print("websocket is disconnected: \(e.message)")
        } else if let e = error {
            print("websocket is disconnected: \(e.localizedDescription)")
        } else {
            print("websocket disconnected")
        }
    }
    
    func websocketDidReceiveMessage(socket: WebSocketClient, text: String) {
        
        //        print("Received text: \(text)")
        let jsonData = text.data(using: .utf8)
        let dictionary = try? JSONSerialization.jsonObject(with: jsonData!, options: .mutableLeaves) as! NSDictionary
        print(dictionary)
        self.appdata.arrNotifications.removeAll()
//        self.fnGetPendingFriendRequests()
//        self.fnGetPendingPackages()
        let dictType = dictionary!["type"] as! String
        switch dictType {
        case "ebay-token":
            let strToken = dictionary!["dataEbay"] as! String
            UserDefaults.standard.set(strToken, forKey: "strEbayToken")
        case "friend-request":
            let friend = dictionary!["data"] as! NSDictionary
            let strFname = friend["userFname"] as! String
            let strLname = friend["userLname"] as! String
            var topWindow: UIWindow? = UIWindow(frame: UIScreen.main.bounds)
            topWindow?.rootViewController = UIViewController()
            topWindow?.windowLevel = UIWindowLevelAlert + 1
            let alert = UIAlertController(title: "Mito", message: "\(strFname) \(strLname) has sent you a friend request.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Confirm"), style: .cancel, handler: { (_ action: UIAlertAction) -> Void in
                topWindow?.isHidden = true
                topWindow = nil
            }))
            topWindow?.makeKeyAndVisible()
            topWindow?.rootViewController?.present(alert, animated: true, completion: nil)
            print("friend-request") // write function for what you want to do when friend-request comes in
        case "friend-accept":
            let friend = dictionary!["data"] as! NSDictionary
            let strFname = friend["userFname"] as! String
            let strLname = friend["userLname"] as! String
            var topWindow: UIWindow? = UIWindow(frame: UIScreen.main.bounds)
            topWindow?.rootViewController = UIViewController()
            topWindow?.windowLevel = UIWindowLevelAlert + 1
            let alert = UIAlertController(title: "Mito", message: "\(strFname) \(strLname) has accepted your friend request.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Confirm"), style: .cancel, handler: { (_ action: UIAlertAction) -> Void in
                topWindow?.isHidden = true
                topWindow = nil
            }))
            topWindow?.makeKeyAndVisible()
            topWindow?.rootViewController?.present(alert, animated: true, completion: nil)
            print("friend-accept")
        case "package-pending":
            let friend = dictionary!["data"] as! NSDictionary
            let strFname = friend["userFname"] as! String
            let strLname = friend["userLname"] as! String
            var topWindow: UIWindow? = UIWindow(frame: UIScreen.main.bounds)
            topWindow?.rootViewController = UIViewController()
            topWindow?.windowLevel = UIWindowLevelAlert + 1
            let alert = UIAlertController(title: "Mito", message: "\(strFname) \(strLname) has sent you a package request", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Confirm"), style: .cancel, handler: { (_ action: UIAlertAction) -> Void in
                topWindow?.isHidden = true
                topWindow = nil
            }))
            topWindow?.makeKeyAndVisible()
            topWindow?.rootViewController?.present(alert, animated: true, completion: nil)
            print("friend-accept")
        case "package-accept":
            let friend = dictionary!["data"] as! NSDictionary
            let strFname = friend["userFname"] as! String
            let strLname = friend["userLname"] as! String
            var topWindow: UIWindow? = UIWindow(frame: UIScreen.main.bounds)
            topWindow?.rootViewController = UIViewController()
            topWindow?.windowLevel = UIWindowLevelAlert + 1
            let alert = UIAlertController(title: "Mito", message: "\(strFname) \(strLname) has accepted your package request.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Confirm"), style: .cancel, handler: { (_ action: UIAlertAction) -> Void in
                topWindow?.isHidden = true
                topWindow = nil
            }))
            topWindow?.makeKeyAndVisible()
            topWindow?.rootViewController?.present(alert, animated: true, completion: nil)
            print("package-request")
        case "package-denied":
            let friend = dictionary!["data"] as! NSDictionary
            let strFname = friend["userFname"] as! String
            let strLname = friend["userLname"] as! String
            var topWindow: UIWindow? = UIWindow(frame: UIScreen.main.bounds)
            topWindow?.rootViewController = UIViewController()
            topWindow?.windowLevel = UIWindowLevelAlert + 1
            let alert = UIAlertController(title: "Mito", message: "\(strFname) \(strLname) has denied your package request.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Confirm"), style: .cancel, handler: { (_ action: UIAlertAction) -> Void in
                topWindow?.isHidden = true
                topWindow = nil
            }))
            topWindow?.makeKeyAndVisible()
            topWindow?.rootViewController?.present(alert, animated: true, completion: nil)
            print("package-denied")
        default:
            print("default message")
        }
//        print(dictionary as Any)
    }
    
    func websocketDidReceiveData(socket: WebSocketClient, data: Data) {
        print("Received data: \(data.count)")
    }
    
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        let storyboard = UIStoryboard(name: "Login", bundle: nil)
        self.window?.rootViewController = storyboard.instantiateViewController(withIdentifier: "Open")
        GMSPlacesClient.provideAPIKey(Constants.GMSPlacesClientAPIKey)
        GMSServices.provideAPIKey(Constants.GMSServicesAPIKey)
        UINavigationBar.appearance().barTintColor = UIColor(red:0.25, green:0.87, blue:0.49, alpha:0.5)
        UINavigationBar.appearance().tintColor = UIColor.white
        UINavigationBar.appearance().titleTextAttributes = [NSAttributedStringKey.foregroundColor : UIColor.white]
        return true
    }
    
    func fnGetPendingFriendRequests() {
        let tabBarController = UITabBarController()
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
                        if self.appdata.arrNotifications.count == 0 {
                            self.tabBarController.tabBar.items?.last?.badgeValue = nil
                        } else {
                            self.tabBarController.tabBar.items?.last?.badgeValue = String(self.appdata.arrNotifications.count)
                        }
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
                    if self.appdata.arrNotifications.count == 0 {
                        self.tabBarController.tabBar.items?.last?.badgeValue = nil
                    } else {
                        self.tabBarController.tabBar.items?.last?.badgeValue = String(self.appdata.arrNotifications.count)
                    }
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

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

