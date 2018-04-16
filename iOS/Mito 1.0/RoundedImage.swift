//
//  RoundedImage.swift
//  Mito 1.0
//
//  Created by Benny on 4/15/18.
//  Copyright © 2018 Benny Souriyadeth. All rights reserved.
//

import UIKit

class RoundedImage: UIImageView {
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // creates circular imageview (temporary, known to slow down table views)
        layer.cornerRadius = self.layer.frame.size.width / 2;
        layer.masksToBounds = true
    }
}
