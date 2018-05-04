//
//  Package.swift
//  Mito 1.0
//
//  Created by JJ Guo on 4/18/18.
//  Copyright © 2018 Benny Souriyadeth. All rights reserved.
//

import Foundation

class Package {
    var intGiftOption: Int = 0
    var strOrderDate: String = ""
    var intOrderID: Int = 0
    var strOrderMessage: String = ""
    var strPhotoUrl: String = ""
    var intSenderID: Int = 0
    var strUserFName: String = ""
    var strUserLName: String = ""
    
    init(intGiftOption: Int, strOrderDate: String, intOrderID: Int, strOrderMessage: String, strPhotoUrl: String, intSenderID: Int, strUserFName: String, strUserLName: String) {
        self.intGiftOption = intGiftOption
        self.strOrderDate = strOrderDate
        self.intOrderID = intOrderID
        self.strOrderMessage = strOrderMessage
        self.strPhotoUrl = strPhotoUrl
        self.intSenderID = intSenderID
        self.strUserFName = strUserFName
        self.strUserLName = strUserLName
    }
}
