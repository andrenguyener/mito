//
//  ViewController.swift
//  Mito 1.0
//
//  Created by Benny on 2/22/18.
//  Copyright © 2018 Benny Souriyadeth. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var img: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        img.image = UIImage(named: "Andre2.png")
    }

    @IBAction func backButton(_ sender: Any) {
        performSegue(withIdentifier: "prodDetailBack", sender: self)
    }
    
}
