//
//  CartViewController.swift
//  Mito 1.0
//
//  Created by Benny on 2/26/18.
//  Copyright © 2018 Benny Souriyadeth. All rights reserved.
//

import UIKit
import Alamofire

class CartViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIPickerViewDelegate, UIPickerViewDataSource {
    
    var appdata = AppData.shared
    var intLineItemIndex = 0

    @IBAction func btnOrderSummaryToEditCheckout(_ sender: Any) {
        performSegue(withIdentifier: "orderSummaryToEditCheckout", sender: self)
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return appdata.arrQuantity.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return appdata.arrQuantity[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        pickerviewEditQuantity.isHidden = true
        let intNewQuantity = Int(appdata.arrQuantity[row])!
        fnUpdateLineItemQuantity(intCartItemIndex: intLineItemIndex, intNewQuantity: intNewQuantity)
    }
    
    func fnUpdateLineItemQuantity(intCartItemIndex: Int, intNewQuantity: Int) {
        let objCartLineItem = appdata.arrCartLineItems[intCartItemIndex]
        let parameters: Parameters = [
            "amazonASIN": objCartLineItem.objProduct.ASIN,
            "amazonPrice": objCartLineItem.objProduct.price,
            "quantity": intNewQuantity,
            "productImageUrl": objCartLineItem.objProduct.image,
            "productName": objCartLineItem.objProduct.title
        ]
        let headers: HTTPHeaders = [
            "Authorization": UserDefaults.standard.object(forKey: "Authorization") as! String
        ]
        let urlAddToMitoCart = URL(string: "https://api.projectmito.io/v1/cart")
        Alamofire.request(urlAddToMitoCart!, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers).validate().responseString { response in
            switch response.result {
            case .success:
                if let dictionary = response.result.value {
                    print(dictionary)
                    // Any code for storing locally
                }
                DispatchQueue.main.async {
                    self.fnLoadMitoCart()
                    self.cartTableView.reloadData()
                }
                
            case .failure(let error):
                print("Line item quantity could not updated")
                print(error)
            }
        }
    }

    //User's Cart
    @IBOutlet weak var cartTableView: UITableView!
    @IBOutlet weak var cartNumber: UILabel!
    @IBOutlet weak var cartPrice: UILabel!
    @IBOutlet weak var pickerviewEditQuantity: UIPickerView!
    
    var urlGetMitoCartCall = URL(string: "https://api.projectmito.io/v1/cart/retrieve")
    var urlAlterMitoCart = URL(string: "https://api.projectmito.io/v1/cart")
    
    @IBAction func btnEditCheckout(_ sender: Any) {
        performSegue(withIdentifier: "checkoutToEditCheckout", sender: self)
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
    @IBOutlet weak var lblCreditCardNumber: UILabel!
    
    let formatter = NumberFormatter()
    var intNumItems = 0
    var priceSum : Decimal = 0.00
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if cartTableView != nil {
            pickerviewEditQuantity.dataSource = self
            pickerviewEditQuantity.delegate = self
            pickerviewEditQuantity.isHidden = true
            cartTableView.delegate = self
            cartTableView.dataSource = self
            cartTableView.rowHeight = 106
            self.navigationController?.isNavigationBarHidden = false
            fnLoadMitoCart()
        } else if itemCountCheckout != nil {
            fnGetCartSubTotal()
        } else if lblNotifyYouMessage != nil {
            lblNotifyYouMessage.text = "We will notify you when \(appdata.personRecipient.firstName) accepts!"
        }
        else {
            appdata.arrCartLineItems.removeAll()
        }
    }
    
    func fnGetCartSubTotal() {
        self.intNumItems = 0
        self.priceSum = 0.0
        for element in self.appdata.arrCartLineItems {
            let itemPrice = "$" + element.objProduct.price // change later
            formatter.numberStyle = .currency
            formatter.locale = Locale(identifier: "en_US")
            var decAmazonPrice: Double = 0.00
            if let number = formatter.number(from: itemPrice) {
                decAmazonPrice = number.doubleValue
                let totalAmt: Double = decAmazonPrice * (Double)(element.intQuantity)
                self.priceSum += Decimal(totalAmt)
            }
            print("Total Price: \(self.priceSum)")
        }
        for objCartItem in self.appdata.arrCartLineItems {
            self.intNumItems += objCartItem.intQuantity
        }
    }
    
    func fnSetCartLabels() {
        var strItems = "items"
        if self.intNumItems == 1 {
            strItems = "item"
        }
        self.cartNumber.text = "Cart has \(self.intNumItems) \(strItems)"
        
        // rounds 2 decimal places for priceSum
        let tempSum = Double(truncating: self.priceSum as NSNumber)
        let temp2Sum = Double(round(100 * tempSum)/100).roundTo2f()
        print("Number of items: \(self.intNumItems)")
        print("Total Price: \(temp2Sum)")
        self.cartPrice.text = "$\(temp2Sum)"
    }
    
    func fnLoadMitoCart() {
        appdata.arrCartLineItems.removeAll()
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
                        print(dictCartItem)
                        let objectItem = Product(image: dictCartItem["ProductImageUrl"] as! String, ASIN: dictCartItem["AmazonItemId"] as! String, title: dictCartItem["ProductName"] as! String, publisher: "publisher", price: dictCartItem["AmazonItemPrice"] as! String, description: "description")
                        let intQuantity = dictCartItem["Quantity"] as! Int
                        let lineItem = LineItem(objProduct: objectItem, intQty: intQuantity)
                        self.appdata.arrCartLineItems.append(lineItem)
                    }
                    DispatchQueue.main.async {
                        print("Number of items: \(self.appdata.arrCartLineItems.count)")
                        self.fnGetCartSubTotal()
                        self.fnSetCartLabels()
                        self.cartTableView.reloadData()
                    }
                }
                
            case .failure(let error):
                print("Get Amazon Product error")
                print(error)
            }
        }
    }
    
    @IBAction func btnGoToEditCheckout(_ sender: Any) {
        boolSender = true
        performSegue(withIdentifier: "segCartToChooseRecipient", sender: self)
    }
    
    @IBOutlet weak var lblNotifyYouMessage: UILabel!
    
    @IBAction func finishCheckout(_ sender: Any) {
        self.fnFinishCheckout()
        performSegue(withIdentifier: "checkoutFinish", sender: self)
    }
    
    func fnFinishCheckout() {
        let urlCheckoutMitoCart = URL(string: "https://api.projectmito.io/v1/cart/process")
        let parameters: Parameters = [
            "cardId": 1,
            "senderAddressId": appdata.address.intAddressID!,
            "recipientId": appdata.personRecipient.intUserID,
            "message": appdata.strOrderMessage,
            "giftOption": 0
        ]
        let headers: HTTPHeaders = [
            "Authorization": UserDefaults.standard.object(forKey: "Authorization") as! String
        ]
        Alamofire.request(urlCheckoutMitoCart!, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers).validate().responseString { response in
            switch response.result {
            case .success:
                if let dictionary = response.result.value {
                    print(dictionary)
                    // Any code for storing locally
                }
                
            case .failure(let error):
                print("Checkout could not be processed")
                print(error)
            }
        }
        
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
        let strPrice = "$" + cartObj.objProduct.price
        formatter.numberStyle = .currency
        if let number = formatter.number(from: strPrice) {
            let intQty = (Double)(cartObj.intQuantity)
            let dblPrice = number.doubleValue * (Double)(intQty)
            cell.lblPrice.text = "$ \(dblPrice.roundTo2f())"
        }
        cell.btnEditQuantity.setTitle("Quantity: (\(cartObj.intQuantity))", for: .normal)
//        cell.lblSellerName.text = String(cartObj.intQuantity) //cartObj.objProduct.publisher
        cell.btnDelete.tag = indexPath.row
        cell.btnDelete.addTarget(self, action: #selector(self.fnRemoveItem(_:)), for: .touchUpInside)
        cell.btnEditQuantity.tag = indexPath.row
        cell.btnEditQuantity.addTarget(self, action: #selector(self.fnEditQuantity(_:)), for: .touchUpInside)
        return cell
    }
    
    @objc func fnRemoveItem(_ button: UIButton) {
        let intLineItemIndex = button.tag
        fnUpdateLineItemQuantity(intCartItemIndex: intLineItemIndex, intNewQuantity: 0)
        appdata.arrCartLineItems.remove(at: intLineItemIndex)
    }
    
    @objc func fnEditQuantity(_ button: UIButton) {
        pickerviewEditQuantity.isHidden = false
        intLineItemIndex = button.tag
    }
}

extension Double {
    func roundTo0f() -> NSString {
        return NSString(format: "%.0f", self)
    }
    
    func roundTo1f() -> NSString {
        return NSString(format: "%.1f", self)
    }
    
    func roundTo2f() -> NSString {
        return NSString(format: "%.2f", self)
    }
}
