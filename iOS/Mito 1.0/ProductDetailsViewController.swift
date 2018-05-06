//
//  ProductDetailsViewController.swift
//  Mito 1.0
//
//  Created by JJ Guo on 2/25/18.
//  Copyright © 2018 Benny Souriyadeth. All rights reserved.
//

import UIKit
import Alamofire

class ProductDetailsViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    var appdata = AppData.shared
    var urlAddToMitoCart = URL(string: "https://api.projectmito.io/v1/cart")
    let formatter = NumberFormatter()

    override func viewDidLoad() {
        super.viewDidLoad()
        pickerviewQuantity.isHidden = true
        pickerviewQuantity.delegate = self
        pickerviewQuantity.dataSource = self
        appdata.fnDisplaySimpleImage(strImageURL: appdata.arrProductSearchResults[appdata.intCurrIndex].image, img: prodImage)
        prodTitle.text = appdata.arrProductSearchResults[appdata.intCurrIndex].title
        prodPub.text = appdata.arrProductSearchResults[appdata.intCurrIndex].publisher
        prodPrice.text = appdata.arrProductSearchResults[appdata.intCurrIndex].price
        prodDetail.text = appdata.arrProductSearchResults[appdata.intCurrIndex].description
        //img.image = UIImage(named: "Andre2.png")
        // Do any additional setup after loading the view.
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // PRODUCT DETAIL SEGUE
    @IBOutlet weak var prodImage: UIImageView!
    @IBOutlet weak var prodTitle: UILabel!
    @IBOutlet weak var prodPub: UILabel!
    @IBOutlet weak var prodPrice: UILabel!
    @IBOutlet weak var prodDetail: UILabel!
    @IBOutlet weak var lblQuantity: UILabel!
    @IBOutlet weak var pickerviewQuantity: UIPickerView!
    @IBOutlet weak var btnQuantity: UIButton!
    @IBOutlet weak var btnAddToCart: UIButton!
    
    @IBAction func btnQuantityPressed(_ sender: Any) {
        if pickerviewQuantity.isHidden {
            pickerviewQuantity.isHidden = false
            btnQuantity.isHidden = true
            lblQuantity.isHidden = true
            btnAddToCart.isHidden = true
        }
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
        lblQuantity.text = appdata.arrQuantity[row]
        btnQuantity.setTitle("Quantity: \(appdata.arrQuantity[row])", for: .normal)
        pickerviewQuantity.isHidden = true
        btnQuantity.isHidden = false
        lblQuantity.isHidden = false
        btnAddToCart.isHidden = false
    }
    
    
    @IBAction func btnAddToCartPressed(_ sender: Any) {
        let objCurrentProduct = appdata.arrProductSearchResults[appdata.intCurrIndex]
        var decAmazonPrice : Decimal = 0.00
        let itemPrice = objCurrentProduct.price // change later
        formatter.numberStyle = .currency
        formatter.locale = Locale(identifier: "en_US")
        print(objCurrentProduct.price)
        if let number = formatter.number(from: itemPrice) {
            decAmazonPrice = number.decimalValue
        }
        print("decAmazonPrice: \(decAmazonPrice)")
        let intQuantity = (Int)(lblQuantity.text!)!
        let parameters: Parameters = [
            "amazonASIN": objCurrentProduct.ASIN,
            "amazonPrice": decAmazonPrice,
            "quantity": intQuantity,
            "productImageUrl": objCurrentProduct.image,
            "productName": objCurrentProduct.title
        ]
        let headers: HTTPHeaders = [
            "Authorization": UserDefaults.standard.object(forKey: "Authorization") as! String
        ]
        Alamofire.request(urlAddToMitoCart!, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers).validate().responseString { response in
            switch response.result {
            case .success:
                if let dictionary = response.result.value {
                    print(dictionary)
//                    DispatchQueue.main.async {
//                        let alert = self.appdata.fnDisplayAlert(title: "Done!", message: "Added to cart!")
//                        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
//                            self.performSegue(withIdentifier: "backToTabController", sender: self)
//                        }))
//                        self.present(alert, animated: true, completion: nil)
//                    }
                }
                DispatchQueue.main.async {
                    let alertController = UIAlertController(title: "Done!", message: "Added to cart!", preferredStyle: .alert)
                    alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
                        self.performSegue(withIdentifier: "backToTabController", sender: self)
                    }))
                    self.present(alertController, animated: true, completion: nil)
                }
                
            case .failure(let error):
                print("Product could not be added to cart")
                print(error)
            }
        }
    }
    
//    @IBAction func backSearch(_ sender: Any) {
//        fnProductDetailsToSearch()
//    }
//
//    func fnProductDetailsToSearch() {
//        appdata.arrProductSearchResults.removeAll()
//        print("Pressed back")
//        self.performSegue(withIdentifier: "backToTabController", sender: self)
//    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "backToTabController" {
            let tabBarController = segue.destination as! UITabBarController
            tabBarController.selectedIndex = 1
        }
    }
    
}
