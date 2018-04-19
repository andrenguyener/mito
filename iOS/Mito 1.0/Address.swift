//
//  Address.swift
//  Mito 1.0
//
//  Created by JJ Guo on 4/18/18.
//  Copyright © 2018 Benny Souriyadeth. All rights reserved.
//

import Foundation

class Address {
    var intAddressID: Int = 0
    var strAddressAlias = ""
    var strCityName = ""
    var strStateName = ""
    var strStreetAddress1 = ""
    var strStreetAddress2 = ""
    var strZipCode = ""
    
    init(intAddressID: Int, strAddressAlias: String, strCityName: String, strStateName: String, strStreetAddress1: String,
         strStreetAddress2: String, strZipCode: String) {
        self.intAddressID = intAddressID
        self.strAddressAlias = strAddressAlias
        self.strCityName = strCityName
        self.strStateName = strStateName
        self.strStreetAddress1 = strStreetAddress1
        self.strStreetAddress2 = strStreetAddress2
        self.strZipCode = strZipCode
    }
}
