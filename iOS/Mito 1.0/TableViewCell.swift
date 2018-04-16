//
//  TableViewCell.swift
//  Mito 1.0
//
//  Created by JJ Guo on 2/24/18.
//  Copyright © 2018 Benny Souriyadeth. All rights reserved.
//

import UIKit

class TableViewCell: UITableViewCell {

    @IBOutlet weak var img: UIImageView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var handle: UILabel!
    @IBOutlet weak var friendshipType: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        // creates circular imageview (temporary, known to slow down table views) 
        img.layer.cornerRadius = self.img.frame.size.width / 2;
        img.layer.masksToBounds = true

    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    

}
