//
//  RoundedButton.swift
//  Mito 1.0
//
//  Created by Benny on 4/15/18.
//  Copyright © 2018 Benny Souriyadeth. All rights reserved.
//

import UIKit


// Creates rounded corners on buttons. Does not show in storyboard
class RoundedButton: UIButton {
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = frame.height/7
    }
}
