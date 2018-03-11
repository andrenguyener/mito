//
//  ProductTableViewCell.swift
//  Mito 1.0
//
//  Created by JJ Guo on 3/6/18.
//  Copyright © 2018 Benny Souriyadeth. All rights reserved.
//

import UIKit

class ProductTableViewCell: UITableViewCell {

    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var publisher: UILabel!
    @IBOutlet weak var price: UILabel!
    @IBOutlet weak var img: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
