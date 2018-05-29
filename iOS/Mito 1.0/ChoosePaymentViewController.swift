//
//  ChoosePaymentViewController.swift
//  Mito 1.0
//
//  Created by JJ Guo on 5/17/18.
//  Copyright © 2018 Benny Souriyadeth. All rights reserved.
//

import UIKit

class ChoosePaymentViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var lblCreditCardNumber: UITextField!
    @IBOutlet weak var tblviewPaymentOptions: UITableView!
    var appdata = AppData.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tblviewPaymentOptions.delegate = self
        tblviewPaymentOptions.dataSource = self
        self.navigationItem.title = "Payment Method"
        let nib = UINib(nibName: "PaymentInfoTableViewCell", bundle: nil)
        tblviewPaymentOptions.register(nib, forCellReuseIdentifier: "PaymentInfoCell")
        let nib2 = UINib(nibName: "AddAddressTableViewCell", bundle: nil)
        tblviewPaymentOptions.register(nib2, forCellReuseIdentifier: "AddNewAddressCell")
        appdata.fnViewPaymentMethods(tblview: tblviewPaymentOptions)
    }
    
    // overrides next screen's back button title
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let backItem = UIBarButtonItem()
        backItem.title = "Back"
        navigationItem.backBarButtonItem = backItem // This will show in the next view controller being pushed
    }
    
    override func viewWillAppear(_ animated: Bool) {
        appdata.fnViewPaymentMethods(tblview: tblviewPaymentOptions)
    }
    
    @IBAction func btnPaymentMethodToEditCheckout(_ sender: Any) {
        appdata.strCardNumber = lblCreditCardNumber.text!
        performSegue(withIdentifier: "segAddNewPaymentToChooseAddress", sender: self)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row != appdata.arrPaymentMethods.count {
            return 90
        } else {
            return 60
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == appdata.arrPaymentMethods.count {
            performSegue(withIdentifier: "segAddNewPaymentMethod", sender: self)
        } else {
            let objPayment = appdata.arrPaymentMethods[indexPath.row]
            appdata.strCardNumber = objPayment.strCardNumber
            performSegue(withIdentifier: "segCard", sender: self)
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return appdata.arrPaymentMethods.count + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == appdata.arrPaymentMethods.count {
            let cell = tableView.dequeueReusableCell(withIdentifier: "AddNewAddressCell", for: indexPath) as! AddAddressTableViewCell
            cell.lblAddNewAddress.text = "Add a new payment method"
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "PaymentInfoCell", for: indexPath) as! PaymentInfoTableViewCell
            let objPaymentMethod = appdata.arrPaymentMethods[indexPath.row]
            let last4 = String(objPaymentMethod.strCardNumber.suffix(4))
            cell.lblTitle.text = "Credit ****\(last4)"
            cell.lblSubtitle.text = "Expires \(objPaymentMethod.intExpMonth)/\(objPaymentMethod.intExpYear)"
            return cell
        }
    }

}
