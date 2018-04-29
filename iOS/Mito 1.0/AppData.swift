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
    
    open var arrFriends: [Person] = []
    open var arrCurrFriends: [Person] = []
    open var arrAllUsers: [Person] = []
    open var arrCurrAllUsers: [Person] = []
    open var arrPendingFriends: [Person] = []
    open var arrQuantity = ["1", "2", "3", "4", "5", "6", "7", "8", "9", "10+"]
    open var arrCurrUserAddresses: [Address] = []
    open var arrCurrUserCurrCart: [LineItem] = []
    open var arrCurrUserPackages: [Package] = []
    open var arrFriendsAndAllMitoUsers: [[Person]] = []
    open var arrCurrFriendsAndAllMitoUsers: [[Person]] = []
    
    open var arrSections = ["Friends", "Other people on Mito"]
    
    open var arrProductSearchResults: [Product] = []
    
    open var arrMonths: [Month] = []
    open var arrDays: [String] = ["01", "02", "03", "04", "05", "06", "07", "08", "09", "10", "11", "12", "13", "14", "15", "16", "17", "18", "19", "20", "21", "22", "23", "24", "25", "26", "27", "28", "29", "30", "31"]
    open var arrYears: [String] = ["1996", "1997", "1998"]
    
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
    
    open func printHi() {
        print("Hi")
    }
    
    open func fnLoadStateData() {
        var urlStates = URL(string: "https://api.myjson.com/bins/penjf") // JSON file containing US states
        Alamofire.request(urlStates!, method: .get, encoding: JSONEncoding.default).validate().responseJSON { response in
            switch response.result {
            case .success:
                if let dictionary = response.result.value as! NSDictionary?{
                    for obj in dictionary {
                        let stateObj = State(abbrev: obj.key as! String, value: obj.value as! String)
                        self.arrStates.append(stateObj)
//                        self.appdata.arrStates.append(stateObj)
                    }
                }
                
            case .failure(let error):
                print("Get all users error")
                print(error)
            }
        }
    }
    
    open func fnLoadMonthData() {
        var urlMonths = URL(string: "https://api.myjson.com/bins/1175mz") // JSON file containing months
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
                print("Get all users error")
                print(error)
            }
        }
    }
}
