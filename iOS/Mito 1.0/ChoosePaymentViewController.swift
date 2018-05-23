//
//  ChoosePaymentViewController.swift
//  Mito 1.0
//
//  Created by JJ Guo on 5/17/18.
//  Copyright © 2018 Benny Souriyadeth. All rights reserved.
//

import UIKit

class ChoosePaymentViewController: UIViewController {
    
    @IBOutlet weak var lblCreditCardNumber: UITextField!
    var appdata = AppData.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Payment"
    }
    
    @IBAction func btnPaymentMethodToEditCheckout(_ sender: Any) {
        appdata.strCardNumber = lblCreditCardNumber.text!
        performSegue(withIdentifier: "segAddNewPaymentToChooseAddress", sender: self)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
