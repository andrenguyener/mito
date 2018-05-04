//
//  AddressTableViewCell.swift
//  Mito 1.0
//
//  Created by JJ Guo on 5/1/18.
//  Copyright © 2018 Benny Souriyadeth. All rights reserved.
//

import UIKit

class AddressTableViewCell: UITableViewCell {

    @IBOutlet weak var strAddressNickname: UILabel!
    @IBOutlet weak var strAddressStreet: UILabel!
    @IBOutlet weak var strCityStateZIP: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
