//
//  RoundedWithBorder.swift
//  Mito 1.0
//
//  Created by Benny on 4/15/18.
//  Copyright © 2018 Benny Souriyadeth. All rights reserved.
//

import UIKit

// creates rounded border based on tint color, size = 2px 
class RoundedWithBorder: UIButton {
    override func awakeFromNib() {
        super.awakeFromNib()
        
        layer.borderWidth = 2/UIScreen.main.nativeScale
//        contentEdgeInsets = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
//        titleLabel?.adjustsFontForContentSizeCategory = true
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = frame.height/6
        layer.borderColor = isEnabled ? tintColor.cgColor : UIColor.lightGray.cgColor
    }
}
