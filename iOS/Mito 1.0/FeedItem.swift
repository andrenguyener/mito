//
//  FeedItem.swift
//  Mito 1.0
//
//  Created by JJ Guo on 2/25/18.
//  Copyright © 2018 Benny Souriyadeth. All rights reserved.
//

import Foundation

class FeedItem {
    var strDate: String = ""
    var photoSenderUrl: String = ""
    var strMessage: String = ""
    var strRecipientFName: String = ""
    var strRecipientLName: String = ""
    var strSenderFName: String = ""
    var strSenderLName: String = ""
    var intRecipientId: Int = 0
    var intSenderId: Int = 0
    
    init(strDate: String, photoSenderUrl: String, strMessage: String, strRecipientFName: String, strRecipientLName: String, strSenderFName: String, strSenderLName: String, intSenderId : Int, intRecipientId : Int) {
        self.strDate = strDate
        self.photoSenderUrl = photoSenderUrl
        self.strMessage = strMessage
        self.strRecipientFName = strRecipientFName
        self.strRecipientLName = strRecipientLName
        self.strSenderFName = strSenderFName
        self.strSenderLName = strSenderLName
        self.intSenderId = intSenderId
        self.intRecipientId = intRecipientId
    }

}
