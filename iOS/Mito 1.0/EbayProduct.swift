//
//  EbayProduct.swift
//  Mito 1.0
//
//  Created by JJ Guo on 5/28/18.
//  Copyright © 2018 Benny Souriyadeth. All rights reserved.
//

import Foundation

struct EbayProduct {
    let strItemId: String?
    let strTitle: String?
    let strImage: String?
    let strPrice: String?
    let strSeller: String?
    let strUsername: String?
    
    init(strItemId: String, strTitle: String, strImage: String, strPrice: String, strSeller: String, strUsername: String) {
        self.strItemId = strItemId
        self.strTitle = strTitle
        self.strImage = strImage
        self.strPrice = strPrice
        self.strSeller = strSeller
        self.strUsername = strUsername
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
