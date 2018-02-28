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
//    var handle: String = ""
//    var friendshipType: String = ""
    var email: String = ""
    var avatar: String = ""
    
    init(firstName: String, lastName: String, email: String, avatar: String) {
        self.firstName = firstName
        self.lastName = lastName
//        self.handle = handle
//        self.friendshipType = friendshipType
        self.email = email
        self.avatar = avatar
    }
    
    func description() -> String {
        return "\(self.firstName) \(self.lastName) \(self.email) \(self.avatar)"
    }
}
