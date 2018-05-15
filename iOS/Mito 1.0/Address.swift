//
//  Address.swift
//  Mito 1.0
//
//  Created by JJ Guo on 4/18/18.
//  Copyright © 2018 Benny Souriyadeth. All rights reserved.
//

import Foundation

struct Address: Decodable {
    let intAddressID: Int?
    let strAddressAlias: String?
    let strCityName: String?
    let strStateName: String?
    let strStreetAddress1: String?
    let strStreetAddress2: String?
    let strZipCode: String?
    
    
//    let objAddressObject = Address(intAddressID: objAddress["AddressId"] as! Int, strAddressAlias: objAddress["Alias"] as! String, strCityName: objAddress["CityName"] as! String, strStateName: objAddress["StateName"] as! String, strStreetAddress1: objAddress["StreetAddress"] as! String, strStreetAddress2: strAddress2, strZipCode: objAddress["ZipCode"] as! String)
//    print("\(objAddress["Alias"] as! String) \(String(describing: objAddress["AddressId"]))")
    
    private enum CodingKeys: String, CodingKey {
        case intAddressID = "AddressId"
        case strAddressAlias = "Alias"
        case strCityName = "CityName"
        case strStateName = "StateName"
        case strStreetAddress1 = "StreetAddress"
        case strStreetAddress2 = "StreetAddress2"
        case strZipCode = "ZipCode"
    }
}
