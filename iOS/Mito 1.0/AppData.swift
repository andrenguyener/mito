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
    
    
//    let Andre: Person =
    open var people: [Person] = [
        Person(firstName: "Andre", lastName: "Nguyen", handle: "@andrenguyen", friendshipType: "Trusted Friend", avatar: "Andre.png"),
        Person(firstName: "Andre", lastName: "Nguyen", handle: "@andrenguyen", friendshipType: "Trusted Friend", avatar: "Andre.png"),
        Person(firstName: "Andre", lastName: "Nguyen", handle: "@andrenguyen", friendshipType: "Trusted Friend", avatar: "Andre.png"),
        Person(firstName: "Andre", lastName: "Nguyen", handle: "@andrenguyen", friendshipType: "Trusted Friend", avatar: "Andre.png"),
        Person(firstName: "Andre", lastName: "Nguyen", handle: "@andrenguyen", friendshipType: "Trusted Friend", avatar: "Andre.png"),
        Person(firstName: "Andre", lastName: "Nguyen", handle: "@andrenguyen", friendshipType: "Trusted Friend", avatar: "Andre.png")
    ]
    
    open var feedItem: [FeedItem] = [
        FeedItem(avatar: "Andre.png", descr: "Gucci Gang", time: "12h", whatHappened: "Andre Nguyen received a gift from Sopheak Neak"),
        FeedItem(avatar: "Andre.png", descr: "Gucci Gang", time: "12h", whatHappened: "Andre Nguyen received a gift from Sopheak Neak"),
        FeedItem(avatar: "Andre.png", descr: "Gucci Gang", time: "12h", whatHappened: "Andre Nguyen received a gift from Sopheak Neak"),
        FeedItem(avatar: "Andre.png", descr: "Gucci Gang", time: "12h", whatHappened: "Andre Nguyen received a gift from Sopheak Neak"),
        FeedItem(avatar: "Andre.png", descr: "Gucci Gang", time: "12h", whatHappened: "Andre Nguyen received a gift from Sopheak Neak"),
        FeedItem(avatar: "Andre.png", descr: "Gucci Gang", time: "12h", whatHappened: "Andre Nguyen received a gift from Sopheak Neak")
    ]
}
