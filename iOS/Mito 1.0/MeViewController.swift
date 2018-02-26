//
//  MeViewController.swift
//  Mito 1.0
//
//  Created by Benny on 2/25/18.
//  Copyright © 2018 Benny Souriyadeth. All rights reserved.
//

import UIKit

class MeViewController: UIViewController {


    @IBAction func meToSettings(_ sender: Any) {
        performSegue(withIdentifier: "meToSettings", sender: self)
    }

    
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}
