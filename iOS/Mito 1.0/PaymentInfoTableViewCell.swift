//
//  PaymentInfoTableViewCell.swift
//  Mito 1.0
//
//  Created by JJ Guo on 5/19/18.
//  Copyright © 2018 Benny Souriyadeth. All rights reserved.
//

import UIKit

class PaymentInfoTableViewCell: UITableViewCell {

    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblSubtitle: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
