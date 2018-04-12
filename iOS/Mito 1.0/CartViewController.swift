//
//  CartViewController.swift
//  Mito 1.0
//
//  Created by Benny on 2/26/18.
//  Copyright © 2018 Benny Souriyadeth. All rights reserved.
//

import UIKit
import Alamofire

class CartViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    //User's Cart
    @IBOutlet weak var cartTableView: UITableView!
    @IBOutlet weak var cartNumber: UILabel!
    @IBOutlet weak var cartPrice: UILabel!
    
    var urlGetMitoCartCall = URL(string: "https://api.projectmito.io/v1/cart/retrieve")
    
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
    var intNumItems = 0
    var priceSum : Decimal = 0.00
    
    override func viewDidLoad() {
        super.viewDidLoad()
        appdata.arrCartLineItems.removeAll()
        fnLoadMitoCart()
        formatter.numberStyle = .currency
        formatter.locale = Locale(identifier: "en_US")
        for element in appdata.arrCartLineItems {
            let itemPrice = element.objProduct.price // change later
            if let number = formatter.number(from: itemPrice) {
                let amount = number.decimalValue
                let totalAmt = amount * (Decimal)(element.intQuantity)
                priceSum += totalAmt
            }
        }
        for objCartItem in appdata.arrCartLineItems {
            intNumItems += objCartItem.intQuantity
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
            appdata.arrCartLineItems.removeAll()
        }
    }
    
    func fnLoadMitoCart() {
        let headers: HTTPHeaders = [
            "Authorization": UserDefaults.standard.object(forKey: "Authorization") as! String
        ]
        Alamofire.request(urlGetMitoCartCall!, method: .get, encoding: JSONEncoding.default, headers: headers).validate().responseJSON { response in
            switch response.result {
            case .success:
                if let dictionary = response.result.value {
                    let arrCartItems = dictionary as! NSArray
                    for objCartItem in arrCartItems {
                        let dictCartItem = objCartItem as! NSDictionary
                        let amazonPrice = dictCartItem["AmazonItemPrice"] as! Int
                        let pprice = String(amazonPrice)
                        print(dictCartItem)
                        let objectItem = Product(image: "123", ASIN: dictCartItem["AmazonItemId"] as! String, title: dictCartItem["AmazonItemId"] as! String, publisher: "publisher", price: pprice, description: "description")
                        let intQuantity = dictCartItem["Quantity"] as! Int
                        let lineItem = LineItem(objProduct: objectItem, intQty: intQuantity)
                        self.appdata.arrCartLineItems.append(lineItem)
                    }
                    var strItems = "items"
                    if self.intNumItems == 1 {
                        strItems = "item"
                    }
                    self.cartNumber.text = "Cart has \(self.intNumItems) \(strItems)"
                    
                    // rounds 2 decimal places for priceSum
                    let tempSum = Double(truncating: self.priceSum as NSNumber)
                    let temp2Sum = Double(round(100 * tempSum)/100)
                    
                    self.cartPrice.text = "$\(temp2Sum)"
                    DispatchQueue.main.async {
                        self.cartTableView.reloadData()
                    }
                }
                
            case .failure(let error):
                print("Get Amazon Product error")
                print(error)
            }
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
        appdata.arrProductSearchResults.removeAll()
        performSegue(withIdentifier: "checkoutComplete", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "cartToHome" {
            let tabBarController = segue.destination as! UITabBarController
            tabBarController.selectedIndex = 1
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return appdata.arrCartLineItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cartCell", for: indexPath) as! CartTableViewCell
        let cartObj = appdata.arrCartLineItems[indexPath.row]
        let url = URL(string: "\(cartObj.objProduct.image)")
        if let data = try? Data(contentsOf: url!) {
            cell.imgItemImage.image = UIImage(data: data)!
            cell.imgItemImage.contentMode = .scaleAspectFit
        }
        cell.lblItemName.text = cartObj.objProduct.title
        let strPrice = cartObj.objProduct.price
        formatter.numberStyle = .currency
        if let number = formatter.number(from: strPrice) {
            let dblPrice = number.decimalValue
            let intQty = (Double)(cartObj.intQuantity)
            cell.lblPrice.text = (String)(describing: dblPrice * (Decimal)(intQty))
        }
        cell.lblSellerName.text = cartObj.objProduct.publisher
        cell.btnQuantity.setTitle((String)(cartObj.intQuantity), for: .normal)
        return cell
    }
    
}
