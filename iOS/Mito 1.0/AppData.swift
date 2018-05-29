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
    open var arrPaymentMethods: [PaymentMethod] = []
    open var arrVariations: [[Item]] = []
    
    open var arrPaymentInfoTitles: [String] = ["Payment method", "Billing address"]
    
    // AnyObject array
    open var arrNotifications: [Notification] = []
    
    open var arrSections = ["Friends", "Other people on Mito"]
    
    open let strNoImageAvailable = "https://www.yankee-division.com/uploads/1/7/6/5/17659643/notavailable_2_orig.jpg?210b"
    
    open var arrProductSearchResults: [Product] = []
    open var arrEbaySearchResults: [EbayProduct] = []
    
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
    
    open func fnLoadMyActivity(tblview: UITableView, intUserId: Int, arr: [FeedItem], refresherNotification: UIRefreshControl, view: UIView) {
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
                if let dictionary = response.value {
                    print(dictionary)
                }
                if let dictionary = response.data {
                    let decoder = JSONDecoder()
                    do {
                        self.arrMyFeedItems = try decoder.decode([FeedItem].self, from: dictionary)
                    } catch let jsonErr {
                        print("Failed to decode: \(jsonErr)")
                    }
                    self.arrMyFeedItems.sort(by: self.fnSortFeedItems)
                    if (self.arrMyFeedItems.count == 0) {
                        view.isHidden = false
                    } else {
                        view.isHidden = true
                    }

                    DispatchQueue.main.async {
                        tblview.reloadData()
                        refresherNotification.endRefreshing()
                    }
                }
                
            case .failure(let error):
                print("Error loading my activity")
                print(error)
            }
        }
    }
    
    func fnLoadFriendActivity(tblview: UITableView, refresherNotification: UIRefreshControl, view: UIView, feedView: UIView, spinner: UIActivityIndicatorView) {
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
                    if (self.arrFriendsFeedItems.count == 0) {
                        view.isHidden = false
                        feedView.isHidden = true
                        tblview.isHidden = true
                    } else {
                        view.isHidden = true
                        feedView.isHidden = false
                        tblview.isHidden = false
                    }
                    spinner.stopAnimating()
                    tblview.reloadData()
                    refresherNotification.endRefreshing()
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
                        var strAvatar = object["ProfileImage"] as! String
                        if strAvatar == self.strImageDefault || strAvatar == "AAP4AHUXf+Y=" {
                            strAvatar = object["PhotoUrl"] as! String
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
    
    open func fnViewPaymentMethods(tblview: UITableView) {
        let urlInsertNewAddress = URL(string: "https://api.projectmito.io/v1/payment/")
        let headers: HTTPHeaders = [
            "Authorization": UserDefaults.standard.object(forKey: "Authorization") as! String
        ]
        Alamofire.request(urlInsertNewAddress!, method: .get, encoding: JSONEncoding.default, headers: headers).validate().responseJSON { response in
            switch response.result {
            case .success:
                if let dictionary = response.data {
                    let decoder = JSONDecoder()
                    do {
                        self.arrPaymentMethods = try decoder.decode([PaymentMethod].self, from: dictionary)
                    } catch let jsonErr {
                        print("Failed to decode: \(jsonErr)")
                    }
                }
                DispatchQueue.main.async {
                    tblview.reloadData()
                }
                if let dictionary = response.result.value {
                    print("Successfully got payment methods")
                    print(dictionary)
                }
                
            case .failure(let error):
                print("Retrieve payment methods error")
                print(error)
            }
        }
    }
    
    let strImageDefault = "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"
    
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
                        var strAvatar = objPerson2["ProfileImage"] as! String
                        if strAvatar == self.strImageDefault || strAvatar == "AAP4AHUXf+Y=" {
                            strAvatar = objPerson2["PhotoUrl"] as! String
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
        if strImageURL.contains("http://") || strImageURL.contains("https://"){
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
        } else if strImageURL != "dd" {
            let decodedImage = Data(base64Encoded: strImageURL)
            var image = UIImage(data: decodedImage!)
            image = image?.af_imageRoundedIntoCircle()
            img.image = image
        }
    }
    
    open func fnShowPrice(str: String) -> NSString {
        let dblValue = Double(str)
        return Double(round(100 * dblValue!)/100).roundTo2f()
    }
}
