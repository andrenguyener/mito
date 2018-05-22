//
//  FeedItem.swift
//  Mito 1.0
//
//  Created by JJ Guo on 2/25/18.
//  Copyright © 2018 Benny Souriyadeth. All rights reserved.
//

import Foundation

struct FeedItem: Decodable {
    let strDate: String
    let photoSenderUrl: String
    let strMessage: String
    let strRecipientFName: String
    let strRecipientLName: String
    let strSenderFName: String
    let strSenderLName: String
    let intRecipientId: Int
    let intSenderId: Int
//    let strPhotoBytes: String?
    
    private enum CodingKeys: String, CodingKey {
        case strDate = "OrderDate"
        case photoSenderUrl = "SenderPhotoUrl"
        case strMessage = "OrderMessage"
        case strRecipientFName = "RecipientFirstName"
        case strRecipientLName = "RecipientLastName"
        case strSenderFName = "SenderFirstName"
        case strSenderLName = "SenderLastName"
        case intRecipientId = "RecipientId"
        case intSenderId = "SenderId"
//        case strPhotoBytes = "SenderProfileImage"
    }
}
