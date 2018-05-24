//
//  ProductDetailsViewController.swift
//  Mito 1.0
//
//  Created by JJ Guo on 2/25/18.
//  Copyright © 2018 Benny Souriyadeth. All rights reserved.
//

import UIKit
import Alamofire

class ProductDetailsViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UICollectionViewDataSource, UICollectionViewDelegate {
    
    @IBOutlet weak var viewProductImages: UICollectionView!
    
    var appdata = AppData.shared
    var urlAddToMitoCart = URL(string: "https://api.projectmito.io/v1/cart")
    let formatter = NumberFormatter()
    let intImageIndex = 0
    let dispatchGroup = DispatchGroup()
//    let intMaxImages = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        let objProduct = appdata.arrProductSearchResults[appdata.intCurrIndex]
        fnSearchByASIN(strASIN: objProduct.strParentASIN)
        pickerviewQuantity.isHidden = true
        pickerviewQuantity.delegate = self
        pickerviewQuantity.dataSource = self
        self.navigationItem.title = "Product"
        appdata.fnDisplayImage(strImageURL: objProduct.image, img: prodImage, boolCircle: false)
        prodTitle.text = objProduct.title
        prodPub.text = objProduct.publisher
        prodPrice.text = objProduct.price
        prodDetail.text = objProduct.description
        let nibAddNewAddress = UINib(nibName: "ProductImageCollectionViewCell", bundle: nil)
        viewProductImages.register(nibAddNewAddress, forCellWithReuseIdentifier: "ProductImageCell")
        viewProductImages.delegate = self
        viewProductImages.dataSource = self
        
//        var swipeRight = UISwipeGestureRecognizer(target: self, action: "swiped:") // put : at the end of method name
//        swipeRight.direction = UISwipeGestureRecognizerDirection.right
//        self.view.addGestureRecognizer(swipeRight)
//        
//        var swipeLeft = UISwipeGestureRecognizer(target: self, action: "swiped:") // put : at the end of method name
//        swipeLeft.direction = UISwipeGestureRecognizerDirection.left
//        self.view.addGestureRecognizer(swipeLeft)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.fnChooseQuantity))
        lblQuantity.addGestureRecognizer(tapGesture)
    }
    
//    func swiped(gesture: UIGestureRecognizer) {
//        if let swipeGesture = gesture as? UISwipeGestureRecognizer {
//            switch swipeGesture.direction {
//            case UISwipeGestureRecognizerDirection.Right :
//                println("User swiped right")
//                intImageIndex--
//                if imageIndex < 0 {
//
//                    imageIndex = maxImages
//
//                }
//
//                image.image = UIImage(named: imageList[imageIndex])
//
//            case UISwipeGestureRecognizerDirection.Left:
//                println("User swiped Left")
//
//                // increase index first
//
//                imageIndex++
//
//                // check if index is in range
//
//                if imageIndex > maxImages {
//
//                    imageIndex = 0
//
//                }
//
//                image.image = UIImage(named: imageList[imageIndex])
//
//
//
//
//            default:
//                break //stops the code/codes nothing.
//
//
//            }
//
//        }
//
//
//    }
    
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
    
    @IBOutlet weak var confirmPicker: UIStackView!
    
    @objc func fnChooseQuantity() {
        if pickerviewQuantity.isHidden {
            pickerviewQuantity.isHidden = false
            confirmPicker.isHidden = false
            btnQuantity.isHidden = true
            lblQuantity.isHidden = true
            btnAddToCart.isHidden = true
        }
    }
    
    @IBAction func btnQuantityPressed(_ sender: Any) {
        if pickerviewQuantity.isHidden {
            pickerviewQuantity.isHidden = false
            confirmPicker.isHidden = false
            btnQuantity.isHidden = true
            lblQuantity.isHidden = true
            btnAddToCart.isHidden = true
        }
    }
    
    @IBAction func btnDoneSelectingQuantity(_ sender: Any) {
        let strQuantity = String(appdata.arrQuantity[pickerviewQuantity.selectedRow(inComponent: 0)])
        lblQuantity.text = strQuantity
        btnQuantity.setTitle("Quantity: \(strQuantity)", for: .normal)
        pickerviewQuantity.isHidden = true
        confirmPicker.isHidden = true
        btnQuantity.isHidden = false
        lblQuantity.isHidden = false
        btnAddToCart.isHidden = false
    }
    
    @IBAction func btnCancel(_ sender: Any) {
        pickerviewQuantity.isHidden = true
        confirmPicker.isHidden = true
        btnQuantity.isHidden = false
        lblQuantity.isHidden = false
        btnAddToCart.isHidden = false
    }
    
    func fnSearchByASIN(strASIN: String) {
        dispatchGroup.enter()
        let urlGetMyAddresses = URL(string: "https://api.projectmito.io/v1/amazonproductvariety/")
        let parameters: Parameters = [
            "parentASIN": strASIN
        ]
        let headers: HTTPHeaders = [
            "Authorization": UserDefaults.standard.object(forKey: "Authorization") as! String
        ]
        Alamofire.request(urlGetMyAddresses!, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers).validate().responseJSON { response in
            switch response.result {
            case .success:
                if let dictionary = response.value {
                    let objColors = dictionary as! NSDictionary
                    let objColorsKeys = objColors.allKeys as NSArray
                    var intIndex = 0
                    var boolNewIndex = true
                    for color in objColorsKeys {
                        let strColor = color as! String
                        let arrSizes = objColors[strColor] as! NSArray
                        for size in arrSizes {
                            let objSize = size as! NSDictionary
                            let arrASIN = objSize["ASIN"] as! NSArray
                            let strASIN = "\(arrASIN[0])"
                            
                            let arrImageSets = objSize["ImageSets"] as! NSArray
                            let objImageSets = arrImageSets[0] as! NSDictionary
                            let arrImageSet = objImageSets["ImageSet"] as! NSArray
                            var arrImages: [String] = []
                            for image in arrImageSet {
                                let objImage = image as! NSDictionary
                                let arrMedImage = objImage["MediumImage"] as! NSArray
                                let objMedImage = arrMedImage[0] as! NSDictionary
                                let arrURL = objMedImage["URL"] as! NSArray
                                let strURL = arrURL[0] as! String
                                arrImages.append(strURL)
                            }
                            let arrAttributes = objSize["ItemAttributes"] as! NSArray
                            let objAttributes = arrAttributes[0] as! NSDictionary
                            let arrTitle = objAttributes["Title"] as! NSArray
                            let strTitle = arrTitle[0] as! String
                            let arrSize = objAttributes["Size"] as! NSArray
                            let strSize = arrSize[0] as! String
                            
                            let item: Item = Item(strTitle: strTitle, strASIN: strASIN, strSize: strSize, arrImages: arrImages, strColor: strColor)
                            if boolNewIndex {
                                print("New Index: \(intIndex)")
                                self.appdata.arrVariations.insert([item], at: intIndex)
                                boolNewIndex = false
                            } else {
                                self.appdata.arrVariations[intIndex].append(item)
                            }
                        }
                        intIndex += 1
                        boolNewIndex = true
                    }
                    self.dispatchGroup.leave()
                    self.dispatchGroup.notify(queue: .main, execute: {
                        self.viewProductImages.reloadData()
                    })
//                    DispatchGroup.notify(dispatchGroup, DispatchQueue.main, {
//                        self.viewProductImages.reloadData()
//                    })
//                    DispatchQueue.main.asyncAfter(deadline: .now() + 15.0) {
//                        self.viewProductImages.reloadData()
//                    }
//                    DispatchQueue.main.asyncAfter(deadline: .now() + 5.0, execute: nil) {
//                        self.viewProductImages.reloadData()
//                    }
//                    DispatchQueue.main.async {
//                        print(self.appdata.arrVariations.count)
//                        self.viewProductImages.reloadData()
//                    }
                }
            case .failure(let error):
                print("Get products error")
                print(error.localizedDescription)
            }
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
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        print("arrVariations count: \(appdata.arrVariations.count)")
        return 0
//        return appdata.arrVariations.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ProductImageCell", for: indexPath) as! ProductImageCollectionViewCell
        print("IndexPath.row: \(indexPath.row)")
        print("First Index arrVariations length: \(appdata.arrVariations[indexPath.row].count)")
        let objProduct = appdata.arrVariations[indexPath.row][0].arrImages
        let primaryImage = objProduct[objProduct.count - 1]
        appdata.fnDisplayImage(strImageURL: primaryImage, img: cell.imgProduct, boolCircle: false)
        return cell
    }
    
    @IBAction func backSearch(_ sender: Any) {
        fnProductDetailsToSearch()
    }

    func fnProductDetailsToSearch() {
        appdata.arrProductSearchResults.removeAll()
        print("Pressed back")
        self.performSegue(withIdentifier: "backToTabController", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "backToTabController" {
            let tabBarController = segue.destination as! UITabBarController
            tabBarController.selectedIndex = 1
        }
    }
    
}
