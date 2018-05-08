//
//  Person.swift
//  Mito 1.0
//
//  Created by JJ Guo on 2/24/18.
//  Copyright © 2018 Benny Souriyadeth. All rights reserved.
//

import Foundation

class Person {
    var firstName: String = ""
    var lastName: String = ""
    var email: String = ""
    var avatar: String = ""
    var intUserID: Int
    var strUsername: String = ""
    var intNumFriends: Int
    var strDate: String = ""
    
    init(firstName: String, lastName: String, email: String, avatar: String, intUserID: Int, strUsername: String, intNumFriends: Int, strDate: String) {
        self.firstName = firstName
        self.lastName = lastName
        self.email = email
        self.avatar = avatar
        self.intUserID = intUserID
        self.strUsername = strUsername
        self.intNumFriends = intNumFriends
        self.strDate = strDate
    }
    
    func description() -> String {
        return "\(self.intUserID) \(self.strUsername ) \(self.firstName) \(self.lastName)"
    }
}
