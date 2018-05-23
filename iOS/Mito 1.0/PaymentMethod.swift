//
//  PaymentMethod.swift
//  Mito 1.0
//
//  Created by JJ Guo on 5/23/18.
//  Copyright © 2018 Benny Souriyadeth. All rights reserved.
//

import Foundation

struct PaymentMethod: Decodable {
    let intCardID: Int
    let intCVV: Int
    let strCardNumber: String
    let strCardType: String
    let intExpMonth: Int
    let intExpYear: Int
    let intDefault: Bool
    
    private enum CodingKeys: String, CodingKey {
        case intCardID = "CreditCardId"
        case intCVV = "CardCVV"
        case strCardNumber = "CardNumber"
        case strCardType = "CardType"
        case intExpMonth = "ExpMonth"
        case intExpYear = "ExpYear"
        case intDefault = "IsDefault"
    }
}
