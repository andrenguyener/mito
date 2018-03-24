//
//  ProductDetailsViewController.swift
//  Mito 1.0
//
//  Created by JJ Guo on 2/25/18.
//  Copyright © 2018 Benny Souriyadeth. All rights reserved.
//

import UIKit

class ProductDetailsViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    var arrQuantity = ["1", "2", "3", "4", "5", "6", "7", "8", "9", "10+"]

    override func viewDidLoad() {
        super.viewDidLoad()
        print("i added item to cart")
        pickerviewQuantity.isHidden = true
        pickerviewQuantity.delegate = self
        pickerviewQuantity.dataSource = self
        let url = URL(string: "\(appdata.arrProductSearchResults[appdata.intCurrIndex].image)")
        if let data = try? Data(contentsOf: url!) {
            prodImage.image = UIImage(data: data)!
        }
        prodTitle.text = appdata.arrProductSearchResults[appdata.intCurrIndex].title
        prodPub.text = appdata.arrProductSearchResults[appdata.intCurrIndex].publisher
        prodPrice.text = appdata.arrProductSearchResults[appdata.intCurrIndex].price
        
        prodDetail.text = appdata.arrProductSearchResults[appdata.intCurrIndex].description
        print(appdata.arrProductSearchResults[appdata.intCurrIndex].title)
        //img.image = UIImage(named: "Andre2.png")
        // Do any additional setup after loading the view.
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    var appdata = AppData.shared
    //PEOPLE DETAIL SEGUE

    
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
        return arrQuantity.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return arrQuantity[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        lblQuantity.text = arrQuantity[row]
        pickerviewQuantity.isHidden = true
        btnQuantity.isHidden = false
        lblQuantity.isHidden = false
        btnAddToCart.isHidden = false
    }
    
    
    @IBAction func btnAddToCartPressed(_ sender: Any) {
        let objCurrentProduct = appdata.arrProductSearchResults[appdata.intCurrIndex]
        if (appdata.arrCartLineItems.count > 0) {
            for objLineItem in appdata.arrCartLineItems {
                if objLineItem.objProduct.ASIN == objCurrentProduct.ASIN {
                    objLineItem.intQuantity += (Int)(lblQuantity.text!)!
                } else {
                    appdata.arrCartLineItems.append(LineItem(objProduct: objCurrentProduct, intQty: (Int)(lblQuantity.text!)!))
                }
            }
        } else {
            appdata.arrCartLineItems.append(LineItem(objProduct: objCurrentProduct, intQty: (Int)(lblQuantity.text!)!))
        }
        self.fnAlertAddedToCart()
    }
    
    func fnAlertAddedToCart() {
        let alertController = UIAlertController(title: "Done", message: "Added to cart!", preferredStyle: .alert)
        let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(defaultAction)
        present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func backSearch(_ sender: Any) {
        appdata.arrProductSearchResults.removeAll()
        self.performSegue(withIdentifier: "backToTabController", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "backToTabController" {
            let tabBarController = segue.destination as! UITabBarController
            tabBarController.selectedIndex = 1
        }
    }
    
}
