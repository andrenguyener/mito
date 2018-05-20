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
    @IBOutlet weak var lblCreditCardNumber: UILabel!
    @IBOutlet weak var tblviewPaymentInfo: UITableView!
    
    @IBOutlet weak var btnTest: UIButton!
    
    var appdata = AppData.shared
    
    let formatter = NumberFormatter()
    
    override func viewDidLayoutSubviews() {
        tblviewPaymentInfo.frame.size = tblviewPaymentInfo.contentSize
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tblviewPaymentInfo.delegate = self
        tblviewPaymentInfo.dataSource = self
        let nibAddNewAddress = UINib(nibName: "PaymentInfoTableViewCell", bundle: nil)
        tblviewPaymentInfo.register(nibAddNewAddress, forCellReuseIdentifier: "PaymentInfoCell")
        tblviewPaymentInfo.isScrollEnabled = false
        fnGetCartSubTotal()
        itemCountCheckout.text = String(appdata.intNumItems)
        shippingCheckout.text = "FREE"
        let tax: Decimal = appdata.priceSum * 0.12
        
        // rounds double with 2 digits precision
        let tempTax = Double(truncating: tax as NSNumber)
        let temp2 = Double(round(100 * tempTax)/100)
        
        let tempTotal = Double(truncating: (appdata.priceSum + tax) as NSNumber)
        let temp2Total = Double(round(100 * tempTotal)/100)
        
        taxCheckout.text = "$\(String(describing: temp2))"
        itemTotalCheckout.text = "$\(String(describing: temp2Total))"
        let imageURL = URL(string: "https://scontent.fsea1-1.fna.fbcdn.net/v/t1.0-9/11822351_10203532431350051_1470782087578284319_n.jpg?oh=5d29573c2435a8b6f293e8dfc75d5215&oe=5B003A10")
        if let data = try? Data(contentsOf: imageURL!) {
            imgRecipient.image = UIImage(data: data)
            imgRecipient.contentMode = .scaleAspectFit
        }
        recipientName.text = "\(appdata.personRecipient.firstName) \(appdata.personRecipient.lastName)"
        
        // hide first 8 numbers of card information
        let stars = String(repeating:"*", count:12)
        let last4 = String(appdata.strCardNumber.suffix(4))
        lblCreditCardNumber.text = "\(stars)\(last4)"
        appdata.fnDisplayImage(strImageURL: appdata.personRecipient.avatar, img: imgRecipient, boolCircle: true)
    }
    
    func fnGetCartSubTotal() {
        appdata.intNumItems = 0
        appdata.priceSum = 0.0
        for element in self.appdata.arrCartLineItems {
            let itemPrice = "$" + element.objProduct.price // change later
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
            "cardId": 1,
            "senderAddressId": appdata.address.intAddressID,
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

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        if tableView == tblviewPaymentInfo {
            return 2
//        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == tblviewPaymentInfo {
            var cell:PaymentInfoTableViewCell! = tblviewPaymentInfo.dequeueReusableCell(withIdentifier: "PaymentInfoCell", for:indexPath)as! PaymentInfoTableViewCell
            // This function actually loads the xib
            cell.lblTitle.text = appdata.arrPaymentInfoTitles[indexPath.row]
            let last4 = String(appdata.strCardNumber.suffix(4))
            if indexPath.row == 0 {
                cell.lblSubtitle.text = "Visa ending in \(last4)"
            } else {
                cell.lblSubtitle.text = "Same as shipping address"
            }
            if cell == nil {
                let cellnib = Bundle.main.loadNibNamed("PaymentInfoCell", owner:self, options: nil)?.first as! PaymentInfoTableViewCell
                cell = cellnib
                cell.lblTitle.text = appdata.arrPaymentInfoTitles[indexPath.row]
                let last4 = String(appdata.strCardNumber.suffix(4))
                if indexPath.row == 0 {
                    cell.lblSubtitle.text = "Visa ending in \(last4)"
                } else {
                    cell.lblSubtitle.text = "Same as shipping address"
                }
            }
            return cell
        }
        var cell:PaymentInfoTableViewCell! = tblviewPaymentInfo.dequeueReusableCell(withIdentifier: "PaymentInfoCell", for:indexPath)as! PaymentInfoTableViewCell
        // This function actually loads the xib
        if cell == nil{
            let cellnib = Bundle.main.loadNibNamed("PaymentInfoCell", owner:self, options: nil)?.first as! PaymentInfoTableViewCell
            cell = cellnib
        }
        cell.lblTitle.text = "Title"
        cell.lblSubtitle.text = "Subtitle"
        return cell
    }
}
