//
//  Month.swift
//  Mito 1.0
//
//  Created by JJ Guo on 3/19/18.
//  Copyright © 2018 Benny Souriyadeth. All rights reserved.
//

import Foundation

class Month {
    var strName: String
    var strAbbrev: String
    var intNum: Int
    var intNumDays: Int
    
    init(strName: String, strAbbrev: String, intNum: Int, intNumDays: Int) {
        self.strName = strName
        self.strAbbrev = strAbbrev
        self.intNum = intNum
        self.intNumDays = intNumDays
    }
    
    func description() -> String {
        return self.strName
    }
}
