//
//  LineItem.swift
//  Mito 1.0
//
//  Created by JJ Guo on 3/22/18.
//  Copyright © 2018 Benny Souriyadeth. All rights reserved.
//

import Foundation

class LineItem {
    var objProduct: Product
    var intQuantity: Int
    
    init(objProduct: Product, intQty: Int) {
        self.objProduct = objProduct
        self.intQuantity = intQty
    }
    
    func description() -> String {
        return "\(objProduct.title): \(intQuantity)"
    }
}