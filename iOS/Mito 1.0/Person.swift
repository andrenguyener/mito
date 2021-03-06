//
//  Person.swift
//  Mito 1.0
//
//  Created by JJ Guo on 2/24/18.
//  Copyright © 2018 Benny Souriyadeth. All rights reserved.
//

import Foundation

class Person: Notification {
    var firstName: String = ""
    var lastName: String = ""
    var email: String = ""
    var avatar: String = ""
    var intUserID: Int
    var strUsername: String = ""
    var intNumFriends: Int
    
    init(firstName: String, lastName: String, email: String, avatar: String, intUserID: Int, strUsername: String, intNumFriends: Int, dateRequested: Date) {
        self.firstName = firstName
        self.lastName = lastName
        self.email = email
        self.avatar = avatar
        self.intUserID = intUserID
        self.strUsername = strUsername
        self.intNumFriends = intNumFriends
        super.init(dateRequested: dateRequested)
    }
    
    init(firstName: String, lastName: String, email: String, avatar: String, intUserID: Int, strUsername: String, intNumFriends: Int) {
        self.firstName = firstName
        self.lastName = lastName
        self.email = email
        self.avatar = avatar
        self.intUserID = intUserID
        self.strUsername = strUsername
        self.intNumFriends = intNumFriends
        super.init(dateRequested: Date.distantPast)
    }
    
    func description() -> String {
        return "\(self.intUserID) \(self.strUsername ) \(self.firstName) \(self.lastName)"
    }
}
