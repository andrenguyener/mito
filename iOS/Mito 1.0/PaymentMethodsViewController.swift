//
//  PaymentMethodsViewController.swift
//  Mito 1.0
//
//  Created by JJ Guo on 5/23/18.
//  Copyright © 2018 Benny Souriyadeth. All rights reserved.
//

import UIKit

class PaymentMethodsViewController: UITableViewController {

    @IBOutlet var tblviewPaymentMethods: UITableView!
    var appdata = AppData.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let nib = UINib(nibName: "PaymentInfoTableViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "PaymentInfoCell")
        let nib2 = UINib(nibName: "AddAddressTableViewCell", bundle: nil)
        tableView.register(nib2, forCellReuseIdentifier: "AddNewAddressCell")
        appdata.fnViewPaymentMethods(tblview: tblviewPaymentMethods)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return appdata.arrPaymentMethods.count + 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == appdata.arrPaymentMethods.count {
            let cell = tableView.dequeueReusableCell(withIdentifier: "AddNewAddressCell", for: indexPath) as! AddAddressTableViewCell
            cell.lblAddNewAddress.text = "Add a new payment method"
            return cell
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: "PaymentInfoCell", for: indexPath) as! PaymentInfoTableViewCell
        let objPaymentMethod = appdata.arrPaymentMethods[indexPath.row]
        let last4 = String(objPaymentMethod.strCardNumber.suffix(4))
        cell.lblTitle.text = "Credit ****\(last4)"
        cell.lblSubtitle.text = "Expires \(objPaymentMethod.intExpMonth)/\(objPaymentMethod.intExpYear)"
        return cell
    }

}
