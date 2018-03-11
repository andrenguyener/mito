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
    
    open var friends: [Person] = []
    
    open var products: [Product] = []
    
    open var cart: [Product] = []
    
    open var feedItem: [FeedItem] = [
        FeedItem(avatar: "Sopheak.png", descr: "Ayyyy its finally time for us to ERD!!", time: "10m", whatHappened: "Sopheak Neak received a gift from Andre Nguyen"),
        FeedItem(avatar: "Andre2.png", descr: "Gang Gang", time: "50m", whatHappened: "Andre Nguyen received a gift from Ammara Touch"),
        FeedItem(avatar: "ammara.png", descr: "Gucci Gang", time: "12h", whatHappened: "Ammara Touch received a gift from Benny Souriyadeth"),
        FeedItem(avatar: "benny.png", descr: "Gang Gang", time: "6h", whatHappened: "Benny Souriyadeth received a gift from Avina Vongpradith"),
        FeedItem(avatar: "avina.png", descr: "Gucci Gang", time: "12h", whatHappened: "Avina Vongradith received a gift from Sarah Phillips"),
        FeedItem(avatar: "sarah.png", descr: "Gang Gang", time: "6h", whatHappened: "Sarah Phillips received a gift from JJ Guo"),
        FeedItem(avatar: "jj.png", descr: "Gang Gang", time: "6h", whatHappened: "JJ Guo received a gift from Sopheak Neak")
    ]
}
