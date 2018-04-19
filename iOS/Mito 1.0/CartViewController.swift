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
    var objCartItem = 0
    var urlAddToMitoCart = URL(string: "https://api.projectmito.io/v1/cart")
    var urlCheckoutMitoCart = URL(string: "https://api.projectmito.io/v1/cart/process")

    @IBAction func btnOrderSummaryToEditCheckout(_ sender: Any) {
        performSegue(withIdentifier: "orderSummaryToEditCheckoutt", sender: self)
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
        fnUpdateLineItemQuantity(objIndex: objCartItem, intNewQuantity: intNewQuantity)
    }
    
    func fnUpdateLineItemQuantity(objIndex: Int, intNewQuantity: Int) {
        let parameters: Parameters = [
            "amazonASIN": appdata.arrCartLineItems[objIndex].objProduct.ASIN,
            "amazonPrice": appdata.arrCartLineItems[objIndex].objProduct.price,
            "quantity": intNewQuantity
        ]
        let headers: HTTPHeaders = [
            "Authorization": UserDefaults.standard.object(forKey: "Authorization") as! String
        ]
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
        print("Number of items: \(intNumItems)")
        if cartTableView != nil {
            pickerviewEditQuantity.dataSource = self
            pickerviewEditQuantity.delegate = self
            pickerviewEditQuantity.isHidden = true
            cartTableView.delegate = self
            cartTableView.dataSource = self
            cartTableView.rowHeight = 106
            fnLoadMitoCart()
        } else if itemCountCheckout != nil {
            fnGetCartSubTotal()
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
            lblCreditCardNumber.text = appdata.strCardNumber
        } else {
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
            var decAmazonPrice: Decimal = 0.0
            if let number = formatter.number(from: itemPrice) {
                decAmazonPrice = number.decimalValue
                let totalAmt = decAmazonPrice * (Decimal)(element.intQuantity)
                self.priceSum += totalAmt
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
        let temp2Sum = Double(round(100 * tempSum)/100)
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
                        let objectItem = Product(image: dictCartItem["ProductImageUrl"] as! String, ASIN: dictCartItem["AmazonItemId"] as! String, title: dictCartItem["ProductName"] as! String, publisher: "publisher", price: String(dictCartItem["AmazonItemPrice"] as! Double), description: "description")
                        let intQuantity = dictCartItem["Quantity"] as! Int
                        let lineItem = LineItem(objProduct: objectItem, intQty: intQuantity)
                        print(objectItem.values())
                        self.appdata.arrCartLineItems.append(lineItem)
                    }
                    DispatchQueue.main.async {
                        print("Number of items: \(self.intNumItems)")
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
        performSegue(withIdentifier: "cartoEditCheckout", sender: self)
    }
    
    
    @IBAction func finishCheckout(_ sender: Any) {
        self.fnFinishCheckout()
        performSegue(withIdentifier: "checkoutFinish", sender: self)
    }
    
    func fnFinishCheckout() {
        let parameters: Parameters = [
            "cardId": 1,
            "senderAddressId": 7,
            "recipientId": 36,
            "message": "First Checkout",
            "giftOption": 1
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
            let dblPrice = number.decimalValue
            let intQty = (Double)(cartObj.intQuantity)
            cell.lblPrice.text = (String)(describing: dblPrice * (Decimal)(intQty))
        }
        cell.lblSellerName.text = String(cartObj.intQuantity) //cartObj.objProduct.publisher
        cell.btnDelete.tag = indexPath.row
        cell.btnDelete.addTarget(self, action: #selector(self.fnRemoveItem(_:)), for: .touchUpInside)
        cell.btnEditQuantity.tag = indexPath.row
        cell.btnEditQuantity.addTarget(self, action: #selector(self.fnEditQuantity(_:)), for: .touchUpInside)
        return cell
    }
    
    @objc func fnRemoveItem(_ button: UIButton) {
        print(button.tag)
        let intLineItemIndex = button.tag
        fnMakeCallToRemoveItem(intLineItemIndex: intLineItemIndex)
        appdata.arrCartLineItems.remove(at: intLineItemIndex)
    }
    
    @objc func fnEditQuantity(_ button: UIButton) {
        pickerviewEditQuantity.isHidden = false
        print("Button Tag: \(button.tag)")
        objCartItem = button.tag
    }
    
    func fnMakeCallToRemoveItem(intLineItemIndex: Int) {
        let objCurrentProduct = appdata.arrCartLineItems[intLineItemIndex].objProduct
        print(objCurrentProduct.values())
        var intAmazonPrice : Decimal = 0.00
        let itemPrice = objCurrentProduct.price // change later
        if let number = formatter.number(from: itemPrice) {
            intAmazonPrice = number.decimalValue
        }
        let parameters: Parameters = [
            "amazonASIN": objCurrentProduct.ASIN,
            "amazonPrice": intAmazonPrice,
            "quantity": 0
        ]
        let headers: HTTPHeaders = [
            "Authorization": UserDefaults.standard.object(forKey: "Authorization") as! String
        ]
        Alamofire.request(urlAlterMitoCart!, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers).validate().responseString { response in
            switch response.result {
            case .success:
                if let dictionary = response.result.value {
                    print(dictionary)
                    DispatchQueue.main.async {
                        self.cartTableView.reloadData()
                    }
                    // Any code for storing locally
                }
                
            case .failure(let error):
                print("Product could not be added to cart")
                print(error)
            }
        }
    }
    
    
}
