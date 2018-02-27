//
//  CartViewController.swift
//  Mito 1.0
//
//  Created by Benny on 2/26/18.
//  Copyright © 2018 Benny Souriyadeth. All rights reserved.
//

import UIKit

class CartViewController: UIViewController {

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    
    //User's Cart

    @IBOutlet weak var cartTableView: UITableView!
    
    @IBAction func finishShopping(_ sender: Any) {
        performSegue(withIdentifier: "toCheckout", sender: self)
    }
    @IBAction func backButton(_ sender: Any) {
        performSegue(withIdentifier: "cartToHome", sender: self)
    }
    
    //Checkout Page
    
    @IBAction func checkoutToCart(_ sender: Any) {
        performSegue(withIdentifier: "checkoutToCart", sender: self)
    }
    
    @IBAction func finishCheckout(_ sender: Any) {
        performSegue(withIdentifier: "checkoutFinish", sender: self)
    }
    
    
    //CheckOutComplete Page
    
    @IBAction func returnHome(_ sender: Any) {
        performSegue(withIdentifier: "checkoutComplete", sender: self)
    }
    
}
