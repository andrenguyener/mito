//
//  HomeTableViewCell.swift
//  Mito 1.0
//
//  Created by JJ Guo on 2/25/18.
//  Copyright © 2018 Benny Souriyadeth. All rights reserved.
//

import UIKit

class HomeTableViewCell: UITableViewCell {

//    @IBOutlet weak var img: UIImageView!
//    @IBOutlet weak var whatHappened: UILabel!
//    @IBOutlet weak var time: UILabel!
//    @IBOutlet weak var descr: UILabel!
    @IBOutlet weak var img: UIImageView!
    @IBOutlet weak var whatHappened: UILabel!
    @IBOutlet weak var time: UILabel!
    @IBOutlet weak var descr: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
