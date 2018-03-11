//
//  CartViewController.swift
//  Mito 1.0
//
//  Created by Benny on 2/26/18.
//  Copyright © 2018 Benny Souriyadeth. All rights reserved.
//

import UIKit

class CartViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    //User's Cart
    @IBOutlet weak var cartTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if cartTableView != nil {
            cartTableView.delegate = self
            cartTableView.dataSource = self
            cartTableView.rowHeight = 106
        }
    }
    var appdata = AppData.shared
    
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
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return appdata.cart.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cartCell", for: indexPath) as! CartTableViewCell
        let cartObj = appdata.cart[indexPath.row]
        let url = URL(string: "\(cartObj.image)")
        if let data = try? Data(contentsOf: url!) {
            cell.itemImage.image = UIImage(data: data)!
        }
        cell.itemName.text = cartObj.title
        cell.price.text = cartObj.price
        cell.seller.text = cartObj.publisher
        return cell
    }
    
}
