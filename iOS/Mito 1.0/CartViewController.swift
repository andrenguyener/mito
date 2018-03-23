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
    @IBOutlet weak var cartNumber: UILabel!
    @IBOutlet weak var cartPrice: UILabel!
    
    @IBAction func finishShopping(_ sender: Any) {
        performSegue(withIdentifier: "toCheckout", sender: self)
    }
    @IBAction func backButton(_ sender: Any) {
        performSegue(withIdentifier: "cartToHome", sender: self)
    }
    
    //Checkout Page
    
    @IBOutlet weak var itemCountCheckout: UILabel!
    @IBOutlet weak var shippingCheckout: UILabel!
    @IBOutlet weak var itemTotalCheckout: UILabel!
    @IBOutlet weak var taxCheckout: UILabel!
    @IBOutlet weak var imgRecipient: UIImageView!
    @IBOutlet weak var recipientName: UILabel!
    
    let formatter = NumberFormatter()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        var priceSum: Decimal
        priceSum = 0.00
        formatter.numberStyle = .currency
        formatter.locale = Locale(identifier: "en_US")
        for element in appdata.cart {
            let itemPrice = element.objProduct.price // change later
            if let number = formatter.number(from: itemPrice) {
                let amount = number.decimalValue
                let totalAmt = amount * (Decimal)(element.intQty)
                priceSum += totalAmt
            }
        }
        var intNumItems = 0
        for objCartItem in appdata.cart {
            intNumItems += objCartItem.intQty
        }
        if cartTableView != nil {
            cartTableView.delegate = self
            cartTableView.dataSource = self
            cartTableView.rowHeight = 106
            var strItems = "items"
            if intNumItems == 1 {
                strItems = "item"
            }
            cartNumber.text = "Cart has \(intNumItems) \(strItems)"
            
            // rounds 2 decimal places for priceSum
            let tempSum = Double(truncating: priceSum as NSNumber)
            let temp2Sum = Double(round(100 * tempSum)/100)
            
            cartPrice.text = "$\(temp2Sum)"
        } else if itemCountCheckout != nil {
            itemCountCheckout.text = String(intNumItems)
            shippingCheckout.text = "FREE"
            let tax: Decimal = priceSum * 0.12
            
            // rounds double with 2 digits precision
            let tempTax = Double(truncating: tax as NSNumber)
            let temp2 = Double(round(100 * tempTax)/100)

            let tempTotal = Double(truncating: (priceSum + tax) as NSNumber)
            let temp2Total = Double(round(100 * tempTotal)/100)
            
            taxCheckout.text = "$\(String(describing: temp2))"
            itemTotalCheckout.text = "$\(String(describing: temp2Total))"
            let imageURL = URL(string: "https://scontent.fsea1-1.fna.fbcdn.net/v/t1.0-9/11822351_10203532431350051_1470782087578284319_n.jpg?oh=5d29573c2435a8b6f293e8dfc75d5215&oe=5B003A10")
            if let data = try? Data(contentsOf: imageURL!) {
                imgRecipient.image = UIImage(data: data)
                imgRecipient.contentMode = .scaleAspectFit
            }
            recipientName.text = "Sopheaky Neaky"
        } else {
            appdata.cart.removeAll()
        }
    }
    var appdata = AppData.shared
    
    @IBAction func checkoutToCart(_ sender: Any) {
        performSegue(withIdentifier: "checkoutToCart", sender: self)
    }
    
    @IBAction func finishCheckout(_ sender: Any) {
        performSegue(withIdentifier: "checkoutFinish", sender: self)
    }
    
    //CheckOutComplete Page
    @IBAction func returnHome(_ sender: Any) {
        appdata.products.removeAll()
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
        let url = URL(string: "\(cartObj.objProduct.image)")
        if let data = try? Data(contentsOf: url!) {
            cell.itemImage.image = UIImage(data: data)!
            cell.itemImage.contentMode = .scaleAspectFit
        }
        print("Title: \(cartObj.objProduct.title)")
        cell.itemName.text = cartObj.objProduct.title
        let strPrice = cartObj.objProduct.price
        formatter.numberStyle = .currency
        if let number = formatter.number(from: strPrice) {
            let dblPrice = number.decimalValue
            let intQty = (Double)(cartObj.intQty)
            cell.price.text = (String)(describing: dblPrice * (Decimal)(intQty))
        }
//        let dblPrice = (Double)(cartObj.objProduct.price)!
        cell.seller.text = cartObj.objProduct.publisher
        cell.quantity.setTitle((String)(cartObj.intQty), for: .normal)
        return cell
    }
    
}
