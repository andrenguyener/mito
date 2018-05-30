//
//  ReviewOrderViewController.swift
//  Mito 1.0
//
//  Created by JJ Guo on 5/17/18.
//  Copyright © 2018 Benny Souriyadeth. All rights reserved.
//

import UIKit
import Alamofire

class ReviewOrderViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var itemCountCheckout: UILabel!
    @IBOutlet weak var shippingCheckout: UILabel!
    @IBOutlet weak var taxCheckout: UILabel!
    @IBOutlet weak var itemTotalCheckout: UILabel!
    
    @IBOutlet weak var imgRecipient: UIImageView!
    @IBOutlet weak var recipientName: UILabel!
    
    @IBOutlet weak var lblCreditCardNumber: UILabel! //
    
    @IBOutlet weak var tblviewPaymentInfo: UITableView!
    @IBOutlet weak var tblviewOrderSummary: UITableView!
    @IBOutlet weak var lblMessage: UILabel!
    
    // new View Controller
    @IBOutlet weak var o_imgRecipient: UIImageView!
    @IBOutlet weak var o_recipientName: UILabel!
    @IBOutlet weak var o_tblviewPaymentInfo: UITableView!
    @IBOutlet weak var o_tblviewOrderSummary: UITableView!
    @IBOutlet weak var o_lblMessage: UILabel!
    
    var appdata = AppData.shared
    
    let formatter = NumberFormatter()
    
    override func viewDidLayoutSubviews() {
        //tblviewPaymentInfo.frame.size = tblviewPaymentInfo.contentSize
        //tblviewOrderSummary.frame.size = tblviewOrderSummary.contentSize
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        o_tblviewPaymentInfo.delegate = self
        o_tblviewPaymentInfo.dataSource = self
        let nibAddNewAddress = UINib(nibName: "PaymentInfoTableViewCell", bundle: nil)
        o_tblviewPaymentInfo.register(nibAddNewAddress, forCellReuseIdentifier: "PaymentInfoCell")
        o_tblviewPaymentInfo.isScrollEnabled = false
        
        o_tblviewOrderSummary.delegate = self
        o_tblviewOrderSummary.dataSource = self
        let nib2AddNewAddress = UINib(nibName: "OrderSummaryTableViewCell", bundle: nil)
        o_tblviewOrderSummary.register(nib2AddNewAddress, forCellReuseIdentifier: "OrderSummaryCell")
        o_tblviewOrderSummary.isScrollEnabled = false
        
        o_lblMessage.text = appdata.strOrderMessage
        
        o_lblMessage.isUserInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.fnSegGoBackAndChangeMessage))
        o_lblMessage.addGestureRecognizer(tapGesture)
        
        o_imgRecipient.isUserInteractionEnabled = true
        let tapGesture2 = UITapGestureRecognizer(target: self, action: #selector(self.fnSegGoBackAndChangeRecipient))
        o_imgRecipient.addGestureRecognizer(tapGesture2)
        o_recipientName.isUserInteractionEnabled = true
        let tapGesture3 = UITapGestureRecognizer(target: self, action: #selector(self.fnSegGoBackAndChangeRecipient))
        o_recipientName.addGestureRecognizer(tapGesture3)
        
        
        fnGetCartSubTotal()
        //itemCountCheckout.text = String(appdata.intNumItems)
        //shippingCheckout.text = "FREE"
        let tax: Decimal = appdata.priceSum * 0.12
        
        // rounds double with 2 digits precision
        let tempTax = Double(truncating: tax as NSNumber)
        let temp2 = Double(round(100 * tempTax)/100)
        
        let tempTotal = Double(truncating: (appdata.priceSum + tax) as NSNumber)
        let temp2Total = Double(round(100 * tempTotal)/100)
        
       // taxCheckout.text = "$\(String(describing: temp2))"
       // itemTotalCheckout.text = "$\(String(describing: temp2Total))"
        appdata.fnDisplayImage(strImageURL: appdata.personRecipient.avatar, img: o_imgRecipient, boolCircle: true)
        o_recipientName.text = "\(appdata.personRecipient.firstName) \(appdata.personRecipient.lastName)"
        
        // hide first 8 numbers of card information
        let last4 = String(appdata.strCardNumber.suffix(4))
        //lblCreditCardNumber.text = "Credit ****\(last4)"
        //        let stars = String(repeating:"*", count:12)
        //        let last4 = String(appdata.strCardNumber.suffix(4))
        //        lblCreditCardNumber.text = "\(stars)\(last4)"
        appdata.fnDisplayImage(strImageURL: appdata.personRecipient.avatar, img: o_imgRecipient, boolCircle: true)
    }
    
    @objc func fnSegGoBackAndChangeRecipient() {
        performSegue(withIdentifier: "segGoBackChooseRecipient", sender: self)
    }
    
    @objc func fnSegGoBackAndChangeMessage() {
        performSegue(withIdentifier: "segOrderToChoosePerson", sender: self)
    }
    
    // overrides next screen's back button title
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let backItem = UIBarButtonItem()
        backItem.title = "Back"
        navigationItem.backBarButtonItem = backItem // This will show in the next view controller being pushed
    }
    
    func fnGetCartSubTotal() {
        appdata.intNumItems = 0
        appdata.priceSum = 0.0
        for element in self.appdata.arrCartLineItems {
            let itemPrice = "$" + element.objProduct.strPrice! // change later
            formatter.numberStyle = .currency
            formatter.locale = Locale(identifier: "en_US")
            var decAmazonPrice: Double = 0.00
            if let number = formatter.number(from: itemPrice) {
                decAmazonPrice = number.doubleValue
                let totalAmt: Double = decAmazonPrice * (Double)(element.intQuantity)
                appdata.priceSum += Decimal(totalAmt)
            }
            print("Total Price: \(appdata.priceSum)")
        }
        for objCartItem in self.appdata.arrCartLineItems {
            appdata.intNumItems += objCartItem.intQuantity
        }
    }
    
    @IBAction func finishCheckout(_ sender: Any) {
        self.fnFinishCheckout()
        performSegue(withIdentifier: "checkoutFinish", sender: self)
    }

    func fnFinishCheckout() {
        let urlCheckoutMitoCart = URL(string: "https://api.projectmito.io/v1/cart/process")
        let parameters: Parameters = [
            "cardId": appdata.arrPaymentMethods[0].intCardID,
            "senderAddressId": appdata.arrCurrUserAddresses[0].intAddressID,
            "recipientId": appdata.personRecipient.intUserID,
            "message": o_lblMessage.text,
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
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == o_tblviewPaymentInfo {
            return 2
        } else {
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.row == 0 {
            performSegue(withIdentifier: "segGoBackAndChoosePayment", sender: self)
        } else {
            performSegue(withIdentifier: "segGoBackChangeAddress", sender: self)
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if tableView == o_tblviewPaymentInfo {
            return "Payment Information"
        } else {
            return "Order Summary"
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == o_tblviewPaymentInfo {
            let cell:PaymentInfoTableViewCell! = o_tblviewPaymentInfo.dequeueReusableCell(withIdentifier: "PaymentInfoCell", for:indexPath)as! PaymentInfoTableViewCell
            // This function actually loads the xib
            cell.lblTitle.text = appdata.arrPaymentInfoTitles[indexPath.row]
            let last4 = String(appdata.strCardNumber.suffix(4))
            if indexPath.row == 0 {
                cell.lblSubtitle.text = "Visa ending in \(last4)"
            } else if appdata.arrCurrUserAddresses.count > 0 && appdata.arrCurrUserAddresses[appdata.intAddressIdx].strStreetAddress2 != nil && (appdata.arrCurrUserAddresses[appdata.intAddressIdx].strStreetAddress2?.count)! > 0 {
                let address = appdata.arrCurrUserAddresses[appdata.intAddressIdx]
                cell.lblSubtitle.text = "\(address.strAddressAlias) \(address.strStreetAddress1!) \(address.strStreetAddress2!), \(address.strCityName!), \(address.strStateName!) \(address.strZipCode!)"
            } else if appdata.arrCurrUserAddresses.count > 0 {
                let address = appdata.arrCurrUserAddresses[appdata.intAddressIdx]
                cell.lblSubtitle.text = "\(address.strStreetAddress1!), \(address.strCityName!), \(address.strStateName!) \(address.strZipCode!)"
            } else {
                cell.lblSubtitle.text = "4555 Roosevelt Way NE, Seattle, WA 98105"
            }
            return cell
        } else {
            let cell: OrderSummaryTableViewCell = o_tblviewOrderSummary.dequeueReusableCell(withIdentifier: "OrderSummaryCell", for: indexPath) as! OrderSummaryTableViewCell
            cell.lblNumItems.text = "Items (\(String(appdata.intNumItems)))"
            let dblSubtotal = Double(truncating: appdata.priceSum as NSNumber)
            let dblTax = round(100 * dblSubtotal * 0.12)/100
            let dblFinal = dblSubtotal + dblTax
            
            let strSubtotal = dblSubtotal.roundTo2f()
            let strTax = ((round(100 * dblSubtotal * 0.12))/100).roundTo2f()
            let strFinal = dblFinal.roundTo2f()
            
            cell.lblTax.text = "$\(String(describing: strTax))"
            cell.lblSubtotal.text = "$\(String(describing: strSubtotal))"
            cell.lblFinalTotal.text = "$\(String(describing: strFinal))"
            return cell
        }
    }
    
}
