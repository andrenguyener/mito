//
//  Product.swift
//  Mito 1.0
//
//  Created by Benny on 2/25/18.
//  Copyright © 2018 Benny Souriyadeth. All rights reserved.
//

import Foundation

struct Product {
    var image: String = ""
    var ASIN: String = ""
    var title: String = ""
    var publisher: String = ""
    var price: String = ""
    var description: String = ""
    var strParentASIN: String = ""
    
    init(image: String, ASIN: String, title: String, publisher: String, price: String, description: String, strParentASIN: String) {
        self.image = image
        self.ASIN = ASIN
        self.title = title
        self.publisher = publisher
        self.price = price
        self.description = description
        self.strParentASIN = strParentASIN
    }
    
    init(image: String, ASIN: String, title: String, publisher: String, price: String, description: String) {
        self.image = image
        self.ASIN = ASIN
        self.title = title
        self.publisher = publisher
        self.price = price
        self.description = description
    }
    init(image: String, ASIN: String, title: String) {
        self.image = image
        self.ASIN = ASIN
        self.title = title
    }
    
    func values() -> String {
        return "\(self.image) \(self.ASIN) \(self.title) \(self.publisher) \(self.price) \(self.description)"
    }
}
