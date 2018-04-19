//
//  CheckoutSelectUserViewController.swift
//  Mito 1.0
//
//  Created by Benny on 4/18/18.
//  Copyright © 2018 Benny Souriyadeth. All rights reserved.
//

import UIKit

class CheckoutSelectUserViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    @IBAction func btnEditCheckoutToCart(_ sender: Any) {
        performSegue(withIdentifier: "editCheckoutToCart", sender: self)
    }
    
    @IBAction func btnEditCheckoutToChooseFriend(_ sender: Any) {
        performSegue(withIdentifier: "checkoutToChooseFriend", sender: self)
    }
    @IBAction func btnPaymentMethodToEditCheckout(_ sender: Any) {
        performSegue(withIdentifier: "paymentMethodToEditCheckout", sender: self)
    }
    
    
    @IBAction func btnCancelAddPaymentMethod (_ sender: Any) {
        performSegue(withIdentifier: "paymentMethodToEditCheckout", sender: self)
    }
    
    
    @IBAction func btnContinueToOrderSummary(_ sender: Any) {
        performSegue(withIdentifier: "editCheckoutToOrderSummary", sender: self)
    }
    
    @IBAction func btnAddNewPaymentMethod(_ sender: Any) {
        performSegue(withIdentifier: "editCheckoutToPaymentMethod", sender: self)
    }
    
    
    @IBAction func btnChoosePersonToEditCheckout(_ sender: Any) {
        performSegue(withIdentifier: "choosePersonToEditCheckout", sender: self)
    }
}
