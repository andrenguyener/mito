//
//  AppData.swift
//  Mito 1.0
//
//  Created by Benny on 2/23/18.
//  Copyright © 2018 Benny Souriyadeth. All rights reserved.
//

import UIKit
import Alamofire

class AppData: NSObject {
    static let shared = AppData()
    open var intCurrentUserID: Int = 0
    open var intCurrIndex: Int = -1
    open var strCardNumber = ""
    open var personRecipient: Person = Person(firstName: "FName", lastName: "LName", email: "", avatar: "dd", intUserID: 0, strUsername: "", intNumFriends: 0)
    open var address: Address = Address(intAddressID: 0, strAddressAlias: "Fake", strCityName: "", strStateName: "", strStreetAddress1: "", strStreetAddress2: "", strZipCode: "")
    open var strOrderMessage = "What's it for?"
    open let mainMitoColor = "41DD7C"
    open var strSearchQuery = ""
    
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
    
    
    // AnyObject array
    open var arrNotifications: [AnyObject] = []
    
    open var arrSections = ["Friends", "Other people on Mito"]
    
    open let strNoImageAvailable = "https://www.yankee-division.com/uploads/1/7/6/5/17659643/notavailable_2_orig.jpg?210b"
    
    open var arrProductSearchResults: [Product] = []
    
    open var arrMonths: [Month] = []
    open var arrDays: [String] = ["01", "02", "03", "04", "05", "06", "07", "08", "09", "10", "11", "12", "13", "14", "15", "16", "17", "18", "19", "20", "21", "22", "23", "24", "25", "26", "27", "28", "29", "30", "31"]
    open var arrYears: [String] = []
    
    open var arrStates: [State] = []
    
    open var arrCartLineItems: [LineItem] = []
    
    open var arrFeedItems: [FeedItem] = [
        FeedItem(avatar: "Sopheak.png", descr: "Ayyyy its finally time for us to ERD!!", time: "12m", whatHappened: "Sopheak Neak sent a gift to Andre Nguyen"),
        FeedItem(avatar: "Andre2.png", descr: "WoW such talent! Hope this help improve your skills even more!", time: "50m", whatHappened: "Andre Nguyen sent a gift to Ammara Touch"),
        FeedItem(avatar: "ammara.png", descr: "When life give you lemons, you make lemonade from the lemons, but remember to add water and sugar.", time: "1h", whatHappened: "Ammara Touch sent a gift to Benny Souriyadeth"),
        FeedItem(avatar: "benny.png", descr: "hi", time: "3h", whatHappened: "Benny Souriyadeth sent a gift to Avina Vongpradith"),
        FeedItem(avatar: "avina.png", descr: "Hey I appreciate you :)", time: "15h", whatHappened: "Avina Vongradith sent a gift to Sarah Phillips"),
        FeedItem(avatar: "sarah.png", descr: "Heres something to help you get through all those nights of ERD's yo!", time: "1d", whatHappened: "Sarah Phillips sent a gift to JJ Guo"),
        FeedItem(avatar: "jj.png", descr: "bro tonight is the night to ERD! Enjoy the gift.", time: "3d", whatHappened: "JJ Guo sent a gift to Sopheak Neak")
    ]
    
    open var tempAccountHolder : Parameters = (Dictionary<String, Any>)()
    
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
        self.fnLoadAllUsers(tableview: tableview)
        
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
    
    open func fnLoadAllUsers(tableview: UITableView) {
        let urlAllUserCall = URL(string: "https://api.projectmito.io/v1/users/all")
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
                        let data = UserDefaults.standard.object(forKey: "UserInfo") as! NSDictionary
                        if objPerson2["userId"] as! Int != data["userId"] as! Int {
                            let objPerson = Person(firstName: objPerson2["userFname"] as! String, lastName: objPerson2["userLname"] as! String, email: objPerson2["userEmail"] as! String, avatar: objPerson2["photoURL"] as! String, intUserID: objPerson2["userId"] as! Int, strUsername: objPerson2["username"] as! String, intNumFriends: objPerson2["NumFriends"] as! Int)
                            self.arrAllUsers.append(objPerson)
                        }
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
