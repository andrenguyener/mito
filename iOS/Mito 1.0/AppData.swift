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
    open var intCurrentUserID: Int = 0
    open var intCurrIndex: Int = -1
    open var strCardNumber = ""
    open var personRecipient: Person = Person(firstName: "FName", lastName: "LName", email: "", avatar: "dd", intUserID: 0, strUsername: "", intNumFriends: 0, dateRequested: Date.distantPast)
    open var address: Address = Address(intAddressID: 0, strAddressAlias: "Fake", strCityName: "", strStateName: "", strStreetAddress1: "", strStreetAddress2: "", strZipCode: "")
    open var currPackage: Package = Package(intGiftOption: 0, strOrderDate: "", intOrderID: 0, strOrderMessage: "", strPhotoUrl: "", intSenderID: 0, strUserFName: "", strUserLName: "")
    open var strOrderMessage = "What's it for?"
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
    
    open var arrFriendsFeedItems: [FeedItem] = []
    open var arrMyFeedItems: [FeedItem] = []
    
    
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
    
    open func fnLoadMyActivity(tblview: UITableView) {
        let urlLoadMyActivity = URL(string: "https://api.projectmito.io/v1/feed/")
        let headers: HTTPHeaders = [
            "Authorization": UserDefaults.standard.object(forKey: "Authorization") as! String
        ]
        Alamofire.request(urlLoadMyActivity!, method: .get, encoding: JSONEncoding.default, headers: headers).validate().responseJSON { response in
            switch response.result {
            case .success:
                print("Loaded My Activity")
                if let dictionary = response.result.value {
                    let arrFeedItems = dictionary as! NSArray
                    //self.fnLoadActualFeedData(arrFeedItems: arrFeedItems, arr2: self.arrMyFeedItems)
                    for objFeedItem in arrFeedItems {
                        let item = objFeedItem as! NSDictionary
                        let strDate = item["OrderDate"] as! String
                        let strMessage = item["OrderMessage"] as! String
                        let strPhotoUrl = item["SenderPhotoUrl"] as! String
                        let strRecipientFName = item["RecipientFirstName"] as! String
                        let strRecipientLName = item["RecipientLastName"] as! String
                        let strSenderFName = item["SenderFirstName"] as! String
                        let strSenderLName = item["SenderLastName"] as! String
                        let intRecipientId = item["RecipientId"] as! Int
                        let intSenderId = item["SenderId"] as! Int
                        let objFeed = FeedItem(strDate: strDate, photoSenderUrl: strPhotoUrl, strMessage: strMessage, strRecipientFName: strRecipientFName, strRecipientLName: strRecipientLName, strSenderFName: strSenderFName, strSenderLName: strSenderLName, intSenderId: intSenderId, intRecipientId: intRecipientId)
                        self.arrMyFeedItems.append(objFeed)
                    }
                }
                DispatchQueue.main.async {
                    tblview.reloadData()
                }
                
            case .failure(let error):
                print("Error loading my activity")
                print(error)
            }
        }
    }
    
    open func fnLoadActualFeedData(arrFeedItems: NSArray, arr2: [FeedItem]) {
        var arr2: [FeedItem] = []
        for objFeedItem in arrFeedItems {
            let item = objFeedItem as! NSDictionary
            let strDate = item["OrderDate"] as! String
            let strMessage = item["OrderMessage"] as! String
            let strPhotoUrl = item["SenderPhotoUrl"] as! String
            let strRecipientFName = item["RecipientFirstName"] as! String
            let strRecipientLName = item["RecipientLastName"] as! String
            let strSenderFName = item["SenderFirstName"] as! String
            let strSenderLName = item["SenderLastName"] as! String
            let intRecipientId = item["RecipientId"] as! Int
            let intSenderId = item["SenderId"] as! Int
            let objFeed = FeedItem(strDate: strDate, photoSenderUrl: strPhotoUrl, strMessage: strMessage, strRecipientFName: strRecipientFName, strRecipientLName: strRecipientLName, strSenderFName: strSenderFName, strSenderLName: strSenderLName, intSenderId: intSenderId, intRecipientId: intRecipientId)
            arr2.append(objFeed)
        }
        print(arrMyFeedItems.count)
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
                        let p: Person = Person(firstName: (object["UserFname"] as? String)!,
                                               lastName: (object["UserLname"] as? String)!,
                                               email: (object["UserEmail"] as? String?)!!,
                                               avatar: (object["PhotoUrl"] as? String?)!!,
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
                        print(objPerson2)
                        let objPerson = Person(firstName: objPerson2["UserFname"] as! String, lastName: objPerson2["UserLname"] as! String, email: objPerson2["UserEmail"] as! String, avatar: objPerson2["PhotoUrl"] as! String, intUserID: objPerson2["UserId"] as! Int, strUsername: objPerson2["Username"] as! String, intNumFriends: objPerson2["NumFriends"] as! Int)
                        self.arrAllUsers.append(objPerson)
                    }
                    self.arrAllUsers.sort(by: self.fnSortMitoUsers)
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
        print("Original date String: \(date)")
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        formatter.timeZone = TimeZone(abbreviation: "UTC")
        
        // Apply UTC
        let dt = formatter.date(from: date)
        print("Date version: \(dt?.description)")
        
        // Change to current
        formatter.timeZone = TimeZone.current
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        
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
        print("Local: \(dateLocal)")
        
        return dateLocal!
    }
    
    open func fnSortMitoUsers(this: Person, that: Person) -> Bool {
        return this.intNumFriends < that.intNumFriends
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
    
    open func fnDisplaySimpleImage(strImageURL: String, img: UIImageView) {
        let urlImage = URL(string:"\(strImageURL)")
        let defaultURL = URL(string: "https://www.yankee-division.com/uploads/1/7/6/5/17659643/notavailable_2_orig.jpg?210b")
        if let data = try? Data(contentsOf: urlImage!) {
            img.image = UIImage(data: data)!
        } else if let data = try? Data(contentsOf: defaultURL!){
            img.image = UIImage(data: data)
        }
    }
}
