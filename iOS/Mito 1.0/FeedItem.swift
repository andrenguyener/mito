//
//  FeedItem.swift
//  Mito 1.0
//
//  Created by JJ Guo on 2/25/18.
//  Copyright © 2018 Benny Souriyadeth. All rights reserved.
//

import Foundation

class FeedItem {
    var avatar: String = ""
    var descr: String = ""
    var time: String = ""
    var whatHappened: String = ""
    
    init(avatar: String, descr: String, time: String, whatHappened: String) {
        self.avatar = avatar
        self.descr = descr
        self.time = time
        self.whatHappened = whatHappened
    }
}
