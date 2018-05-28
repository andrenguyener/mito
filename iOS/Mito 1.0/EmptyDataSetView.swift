//
//  EmptyDataSetView.swift
//  Mito 1.0
//
//  Created by JJ Guo on 5/27/18.
//  Copyright © 2018 Benny Souriyadeth. All rights reserved.
//

import UIKit

class EmptyDataSetView: UIView {

    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblSubtitle: UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
//        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
//        commonInit()
    }
    
    private func commonInit() {
//        let view = UINib(nibName: "EmptyDataSetView", bundle: Bundle(forClass: type(of: self))).instantiate(withOwner: self, options: nil)[0] as! UIView
//        Bundle.main.loadNibNamed("EmptyDataSetView", owner: self, options: nil)
//        view.frame = bounds
//        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
//        self.addSubview(view)
    }
    
}
