//
//  AppData.swift
//  Mito 1.0
//
//  Created by Benny on 2/23/18.
//  Copyright © 2018 Benny Souriyadeth. All rights reserved.
//

import UIKit
import Alamofire
import Starscream

class AppData: NSObject {
    static let shared = AppData()
    open var socket: WebSocket!
    open var intNumItems = 0
    open var priceSum : Decimal = 0.00
    open var intCurrentUserID: Int = 0
    open var intCurrIndex: Int = -1
    
    open var personRecipient: Person = Person(firstName: "FName", lastName: "LName", email: "", avatar: "dd", intUserID: 0, strUsername: "", intNumFriends: 0, dateRequested: Date.distantPast)
    open var strOrderMessage = "What's it for?"
    open var strCardNumber = ""
    open var address: Address = Address(intAddressID: 0, strAddressAlias: "Fake", strCityName: "", strStateName: "", strStreetAddress1: "", strStreetAddress2: "", strZipCode: "")
    
    open var currPackage: Package = Package(intGiftOption: 0, strOrderDate: "", intOrderID: 0, strOrderMessage: "", strPhotoUrl: "", intSenderID: 0, strUserFName: "", strUserLName: "")
    open let mainMitoColor = "41DD7C"
    open var personToView: Person = Person(firstName: "FName", lastName: "LName", email: "", avatar: "dd", intUserID: 0, strUsername: "", intNumFriends: 0, dateRequested: Date.distantPast)
    
    open var arrFriends: [Person] = []
    open var arrCurrFriends: [Person] = []
    open var arrAllUsers: [Person] = []
    open var arrCurrAllUsers: [Person] = []
    open var arrPendingFriends: [Person] = []
    open var arrQuantity = ["1", "2", "3", "4", "5", "6", "7", "8", "9", "10"]
    open var arrCurrUserAddresses: [Address] = []
    open var arrCurrUserCurrCart: [LineItem] = []
    open var arrCurrUserPackages: [Package] = []
    open var arrFriendsAndAllMitoUsers: [[Person]] = []
    open var arrCurrFriendsAndAllMitoUsers: [[Person]] = []
    open var arrMitoProfileFeedItems: [FeedItem] = []
    open var arrFriendsFeedItems: [FeedItem] = []
    open var arrMyFeedItems: [FeedItem] = []
    
    open var arrPaymentInfoTitles: [String] = ["Payment method", "Billing address"]
    
    
    // AnyObject array
    open var arrNotifications: [Notification] = []
    
    open var arrSections = ["Friends", "Other people on Mito"]
    
    open let strNoImageAvailable = "https://www.yankee-division.com/uploads/1/7/6/5/17659643/notavailable_2_orig.jpg?210b"
    
    open var arrProductSearchResults: [Product] = []
    
    open var arrMonths: [Month] = []
    open var arrDays: [String] = ["01", "02", "03", "04", "05", "06", "07", "08", "09", "10", "11", "12", "13", "14", "15", "16", "17", "18", "19", "20", "21", "22", "23", "24", "25", "26", "27", "28", "29", "30", "31"]
    open var arrYears: [String] = []
    
    open var arrStates: [State] = []
    
    open var arrCartLineItems: [LineItem] = []
    
    open var tempAccountHolder : Parameters = (Dictionary<String, Any>)()
    
    open func fnLoadMitoProfileFeed(tblview: UITableView, intUserId: Int) {
        let urlLoadProfileActivity = URL(string: "https://api.projectmito.io/v1/feed/")
        let parameters: Parameters = [
            "friendId": intUserId
        ]
        let headers: HTTPHeaders = [
            "Authorization": UserDefaults.standard.object(forKey: "Authorization") as! String
        ]
        Alamofire.request(urlLoadProfileActivity!, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers).validate().responseJSON { response in
            switch response.result {
            case .success:
                print("Loaded My Activity")
                if let dictionary = response.value {
                    print(dictionary)
                }
                if let dictionary = response.data {
                    let decoder = JSONDecoder()
                    do {
                        self.arrMitoProfileFeedItems = try decoder.decode([FeedItem].self, from: dictionary)
                    } catch let jsonErr {
                        print("Failed to decode: \(jsonErr)")
                    }
                    self.arrMitoProfileFeedItems.sort(by: self.fnSortFeedItems)
                    DispatchQueue.main.async {
                        tblview.reloadData()
                    }
                }
                
            case .failure(let error):
                print("Error loading my activity")
                print(error)
            }
        }
    }
    
    open func fnLoadMyActivity(tblview: UITableView, intUserId: Int, arr: [FeedItem]) {
        let urlLoadMyActivity = URL(string: "https://api.projectmito.io/v1/feed/")
        let parameters: Parameters = [
            "friendId": intUserId
        ]
        let headers: HTTPHeaders = [
            "Authorization": UserDefaults.standard.object(forKey: "Authorization") as! String
        ]
        Alamofire.request(urlLoadMyActivity!, method: .get, parameters: parameters, encoding: JSONEncoding.default, headers: headers).validate().responseJSON { response in
            switch response.result {
            case .success:
                print("Loaded My Activity")
                if let dictionary = response.data {
                    let decoder = JSONDecoder()
                    do {
                        self.arrMyFeedItems = try decoder.decode([FeedItem].self, from: dictionary)
                    } catch let jsonErr {
                        print("Failed to decode: \(jsonErr)")
                    }
                    self.arrMyFeedItems.sort(by: self.fnSortFeedItems)
                    DispatchQueue.main.async {
                        tblview.reloadData()
                    }
                }
                
            case .failure(let error):
                print("Error loading my activity")
                print(error)
            }
        }
    }
    
    func fnLoadFriendActivity(tblview: UITableView) {
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
                        self.arrFriendsFeedItems = try decoder.decode([FeedItem].self, from: dictionary)
                    } catch let jsonErr {
                        print("Failed to decode: \(jsonErr)")
                    }
                    self.arrFriendsFeedItems.sort(by: self.fnSortFeedItems)
                }
                print("Total Friend Feed Items: \(self.arrFriendsFeedItems.count)")
                DispatchQueue.main.async {
                    tblview.reloadData()
                }
                
            case .failure(let error):
                print("Error loading friend activity")
                print(error)
            }
        }
    }
    
    open func fnLoadStateData() {
        let urlStates = URL(string: "https://api.myjson.com/bins/penjf")
        Alamofire.request(urlStates!, method: .get, encoding: JSONEncoding.default).validate().responseJSON { response in
            switch response.result {
            case .success:
                if let dictionary = response.result.value as! NSDictionary?{
                    for obj in dictionary {
                        let stateObj = State(abbrev: obj.key as! String, value: obj.value as! String)
                        self.arrStates.append(stateObj)
                    }
                }
                
            case .failure(let error):
                print("Get all users error")
                print(error)
            }
        }
    }
    
    open func fnLoadMonthData() {
        let urlMonths = URL(string: "https://api.myjson.com/bins/1175mz")
        Alamofire.request(urlMonths!, method: .get, encoding: JSONEncoding.default).validate().responseJSON { response in
            switch response.result {
            case .success:
                if let dictionary = response.result.value as! NSDictionary?{
                    for obj in dictionary {
                        let objMonthValues = obj.value as! NSDictionary
                        let objMonth = Month(strName: objMonthValues["name"] as! String, strAbbrev: objMonthValues["short"] as! String, strNum: objMonthValues["number"] as! String, intNumDays: objMonthValues["days"] as! Int)
                        self.arrMonths.append(objMonth)
                    }
                }
                
            case .failure(let error):
                print("Get all months error")
                print(error)
            }
        }
    }
    
    open func fnLoadFriendsAndAllUsers(tableview: UITableView) {
        self.arrFriendsAndAllMitoUsers.removeAll()
        self.arrFriends.removeAll()
        self.arrAllUsers.removeAll()
        self.fnLoadFriendData(tableview: tableview)
        self.fnLoadOtherMitoUsers(tableview: tableview)
        
        self.arrCurrFriendsAndAllMitoUsers = self.arrFriendsAndAllMitoUsers
        self.arrCurrFriends = self.arrFriends
        self.arrCurrAllUsers = self.arrAllUsers
    }
    
    // pass in the table needed to be refreshed
    open func fnLoadFriendData(tableview: UITableView) {
        let urlPeopleCall = URL(string: "https://api.projectmito.io/v1/friend/1")
        let headers: HTTPHeaders = [
            "Authorization": UserDefaults.standard.object(forKey: "Authorization") as! String
        ]
        Alamofire.request(urlPeopleCall!, method: .get, encoding: JSONEncoding.default, headers: headers).validate().responseJSON { response in
            switch response.result {
            case .success:
                print("Loaded all friends")
                if let dictionary = response.result.value {
                    let dict2 = dictionary as! NSArray
                    for obj in dict2 {
                        let object = obj as! NSDictionary
                        var strAvatar = ""
                        if object["ProfileImage"] != nil {
                            strAvatar = (object["ProfileImage"] as? String)!
                        } else {
                            strAvatar = (object["PhotoUrl"] as? String)!
                        }
                        let p: Person = Person(firstName: (object["UserFname"] as? String)!,
                                               lastName: (object["UserLname"] as? String)!,
                                               email: (object["UserEmail"] as? String?)!!,
                                               avatar: strAvatar,
                                               intUserID: (object["UserId"] as? Int)!,
                                               strUsername: (object["Username"] as? String)!,
                                               intNumFriends: (object["NumFriends"] as? Int)!)
                        self.arrFriends.append(p)
                    }
                    self.arrFriendsAndAllMitoUsers.append(self.arrFriends)
                    self.arrCurrFriendsAndAllMitoUsers = self.arrFriendsAndAllMitoUsers
                    DispatchQueue.main.async {
                        let arrZeroIdx = self.arrCurrFriendsAndAllMitoUsers[0]
                        if self.arrCurrFriendsAndAllMitoUsers.count > 1 && arrZeroIdx.count > self.arrCurrFriendsAndAllMitoUsers[1].count {
                            self.arrCurrFriendsAndAllMitoUsers[0] = self.arrCurrFriendsAndAllMitoUsers[1]
                            self.arrCurrFriendsAndAllMitoUsers[1] = arrZeroIdx
                        }
                        tableview.reloadData()
                    }
                }
                
            case .failure(let error):
                print("Get all friends error")
                print(error)
            }
        }
    }
    
    open func fnLoadOtherMitoUsers(tableview: UITableView) {
        let urlAllUserCall = URL(string: "https://api.projectmito.io/v1/friend/non")
        let headers: HTTPHeaders = [
            "Authorization": UserDefaults.standard.object(forKey: "Authorization") as! String
        ]
        Alamofire.request(urlAllUserCall!, method: .get, encoding: JSONEncoding.default, headers: headers).validate().responseJSON { response in
            switch response.result {
            case .success:
                print("Loaded all users")
                if let dictionary = response.result.value {
                    let objUsers = dictionary as! NSArray
                    for objUser in objUsers {
                        let objPerson2 = objUser as! NSDictionary
                        var strAvatar = ""
                        if objPerson2["ProfileImage"] != nil {
                            strAvatar = (objPerson2["ProfileImage"] as? String)!
                        } else {
                            strAvatar = (objPerson2["PhotoUrl"] as? String)!
                        }
                        let p: Person = Person(firstName: (objPerson2["UserFname"] as? String)!,
                                               lastName: (objPerson2["UserLname"] as? String)!,
                                               email: (objPerson2["UserEmail"] as? String?)!!,
                                               avatar: strAvatar,
                                               intUserID: (objPerson2["UserId"] as? Int)!,
                                               strUsername: (objPerson2["Username"] as? String)!,
                                               intNumFriends: (objPerson2["NumFriends"] as? Int)!)
                        self.arrAllUsers.append(p)
                    }
//                    self.arrAllUsers.sort(by: self.fnSortMitoUsers)
                    self.arrCurrAllUsers = self.arrAllUsers
                    self.arrFriendsAndAllMitoUsers.append(self.arrAllUsers)
                    self.arrCurrFriendsAndAllMitoUsers = self.arrFriendsAndAllMitoUsers
                }
                DispatchQueue.main.async {
                    let arrZeroIdx = self.arrCurrFriendsAndAllMitoUsers[0]
                    if self.arrCurrFriendsAndAllMitoUsers.count > 1 && arrZeroIdx.count > self.arrCurrFriendsAndAllMitoUsers[1].count {
                        self.arrCurrFriendsAndAllMitoUsers[0] = self.arrCurrFriendsAndAllMitoUsers[1]
                        self.arrCurrFriendsAndAllMitoUsers[1] = arrZeroIdx
                    }
                    tableview.reloadData()
                }
                
            case .failure(let error):
                print("Get all users error")
                print(error)
            }
        }
    }
    
    func fnUTCToLocal(date:String) -> String {
//        print("Original date String: \(date)")
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        formatter.timeZone = TimeZone(abbreviation: "UTC")
        
        // Apply UTC
        let dt = formatter.date(from: date)
//        print("Date version: \(dt?.description)")
        
        // Change to current
        formatter.timeZone = TimeZone.current
        formatter.dateFormat = "MMM d, h:mm a"
        
        return formatter.string(from: dt!)
    }
    
    func fnUTCToLocalDate(date: String, formatter: DateFormatter) -> Date {
        let strLocal = fnUTCToLocal(date: date)
        let dateLocal = formatter.date(from: strLocal)
//        print("String Local: \(strLocal)")
//        let formatter = DateFormatter()
//        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
//        formatter.timeZone = TimeZone.current
//        let localDate: Date = formatter.date(from: strLocal)!
//        print("Local: \(dateLocal)")
        
        return dateLocal!
    }
    
    open func fnSortMitoUsers(this: Person, that: Person) -> Bool {
        return this.intNumFriends < that.intNumFriends
    }
    
    open func fnSortFeedItems(this: FeedItem, that: FeedItem) -> Bool {
        return this.strDate > that.strDate
    }
    
    open func fnDisplayAlert(title: String, message: String) -> UIAlertController {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(defaultAction)
        return alertController
    }
    
//    open func fnDisplayAlertSegue(strTitle: String, strMessage: String, strSegue: String) -> UIAlertController {
//        let alertController = UIAlertController(title: strTitle, message: strMessage, preferredStyle: .alert)
//        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
//            performSegue(withIdentifier: strSegue, sender: self)
//        }))
//        present(alertController, animated: true, completion: nil)
//    }
    
    open func fnDisplayImage(strImageURL: String, img: UIImageView, boolCircle: Bool) {
        Alamofire.request(strImageURL).responseImage(completionHandler: { (response) in
            print(response)
            if var image = response.result.value {
                if boolCircle {
                    image = image.af_imageRoundedIntoCircle()
                }
                DispatchQueue.main.async {
                    img.image = image
                }
            }
        })
    }
}
