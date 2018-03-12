//
//  AppData.swift
//  Mito 1.0
//
//  Created by Benny on 2/23/18.
//  Copyright © 2018 Benny Souriyadeth. All rights reserved.
//

import UIKit

class AppData: NSObject {
    static let shared = AppData()
    open var userID: Int = 0
    
    open var friends: [Person] = []
    
    open var products: [Product] = []
    
    open var cart: [Product] = []
    
    open var feedItem: [FeedItem] = [
        FeedItem(avatar: "Sopheak.png", descr: "Ayyyy its finally time for us to ERD!!", time: "12m", whatHappened: "Sopheak Neak sent a gift to Andre Nguyen"),
        FeedItem(avatar: "Andre2.png", descr: "WoW such talent! Hope this help improve your skills even more!", time: "50m", whatHappened: "Andre Nguyen sent a gift to Ammara Touch"),
        FeedItem(avatar: "ammara.png", descr: "When life give you lemons, you make lemonade from the lemons, but remember to add water and sugar.", time: "1h", whatHappened: "Ammara Touch sent a gift to Benny Souriyadeth"),
        FeedItem(avatar: "benny.png", descr: "hi", time: "3h", whatHappened: "Benny Souriyadeth sent a gift to Avina Vongpradith"),
        FeedItem(avatar: "avina.png", descr: "Hey I appreciate you :)", time: "15h", whatHappened: "Avina Vongradith sent a gift to Sarah Phillips"),
        FeedItem(avatar: "sarah.png", descr: "Heres something to help you get through all those nights of ERD's yo!", time: "1d", whatHappened: "Sarah Phillips sent a gift to JJ Guo"),
        FeedItem(avatar: "jj.png", descr: "bro tonight is the night to ERD! Enjoy the gift.", time: "3d", whatHappened: "JJ Guo sent a gift to Sopheak Neak")
    ]
}
