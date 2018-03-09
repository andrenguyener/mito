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
        FeedItem(avatar: "Sopheak.png", descr: "Testing a multiline comment because we need to test it why not", time: "12h", whatHappened: "Andre Nguyen received a gift from Sopheak Neak"),
        FeedItem(avatar: "Andre2.png", descr: "Gang Gang", time: "6h", whatHappened: "Andre Nguyen received a gift from Sopheak Neak"),
        FeedItem(avatar: "Sopheak.png", descr: "Gucci Gang", time: "12h", whatHappened: "Andre Nguyen received a gift from Sopheak Neak"),
        FeedItem(avatar: "Andre2.png", descr: "Gang Gang", time: "6h", whatHappened: "Andre Nguyen received a gift from Sopheak Neak"),
        FeedItem(avatar: "Sopheak.png", descr: "Gucci Gang", time: "12h", whatHappened: "Andre Nguyen received a gift from Sopheak Neak"),
        FeedItem(avatar: "Andre2.png", descr: "Gang Gang", time: "6h", whatHappened: "Andre Nguyen received a gift from Sopheak Neak")
    ]
}
