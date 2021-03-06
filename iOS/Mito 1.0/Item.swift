//
//  Item.swift
//  Mito 1.0
//
//  Created by JJ Guo on 5/23/18.
//  Copyright © 2018 Benny Souriyadeth. All rights reserved.
//

import Foundation

struct Image {
    let images: [String]
}

struct Item {
    let strTitle: String
    let strASIN: String
    let strSize: String
    let arrImages: [String] // Image
    let strColor: String
}

//struct urlImage: Decodable {
//    let ImageSet: [ImageSet]
//}
//
//struct MediumImage: Decodable {
//    let URL: [String]
//}
//
//struct ImageSet: Decodable {
//    let MediumImage: [MediumImage]
//}
