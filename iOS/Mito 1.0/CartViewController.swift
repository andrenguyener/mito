//
//  CartViewController.swift
//  Mito 1.0
//
//  Created by Benny on 2/26/18.
//  Copyright © 2018 Benny Souriyadeth. All rights reserved.
//

import UIKit

class CartViewController: UIViewController {

    
    @IBAction func backButton(_ sender: Any) {
        performSegue(withIdentifier: "cartToHome", sender: self)
    }
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}
