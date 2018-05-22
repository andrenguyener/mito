//
//  FeedCopyTableViewCell.swift
//  Mito 1.0
//
//  Created by JJ Guo on 5/21/18.
//  Copyright © 2018 Benny Souriyadeth. All rights reserved.
//

import UIKit

class FeedCopyTableViewCell: UITableViewCell {

    @IBOutlet weak var imgProfile: UIImageView!
    @IBOutlet weak var strWho: UILabel!
    @IBOutlet weak var strDate: UILabel!
    @IBOutlet weak var strDescr: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
