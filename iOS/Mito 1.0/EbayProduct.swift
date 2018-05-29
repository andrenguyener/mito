//
//  EbayProduct.swift
//  Mito 1.0
//
//  Created by JJ Guo on 5/28/18.
//  Copyright © 2018 Benny Souriyadeth. All rights reserved.
//

import Foundation

struct EbayProduct {
    var strItemId: String?
    var strTitle: String?
    var strImage: String?
    var strPrice: String?
    var strSeller: String?
    var strUsername: String?
    var strRating: String?
    
    init(strItemId: String, strTitle: String, strImage: String, strPrice: String, strSeller: String) {
        self.strItemId = strItemId
        self.strTitle = strTitle
        self.strImage = strImage
        self.strPrice = strPrice
        self.strSeller = strSeller
    }
    
    init(strItemId: String, strTitle: String, strImage: String, strPrice: String, strSeller: String, strRating: String) {
        self.strItemId = strItemId
        self.strTitle = strTitle
        self.strImage = strImage
        self.strPrice = strPrice
        self.strSeller = strSeller
        self.strRating = strRating
    }
    
    func values() {
        print("\(self.strItemId)")
        print("\(self.strTitle)")
        print("\(self.strImage)")
        print("\(self.strPrice)")
        print("\(self.strSeller)")
        print("\(self.strUsername)")
    }
}
