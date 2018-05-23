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
        appdata.fnViewPaymentMethods(tblview: tblviewPaymentMethods)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return appdata.arrPaymentMethods.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PaymentInfoCell", for: indexPath) as! PaymentInfoTableViewCell
        let objPaymentMethod = appdata.arrPaymentMethods[indexPath.row]
        cell.lblTitle.text = String(objPaymentMethod.strCardNumber)
        cell.lblSubtitle.text = "Expires \(objPaymentMethod.intExpMonth)/\(objPaymentMethod.intExpYear)"
        return cell
    }

}
