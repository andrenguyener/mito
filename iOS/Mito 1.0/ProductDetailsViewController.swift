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
    @IBOutlet weak var viewProductSizes: UICollectionView!
    
    var appdata = AppData.shared
    var urlAddToMitoCart = URL(string: "https://api.projectmito.io/v1/cart")
    var intImageIndex = 0
    var objProduct = EbayProduct(strItemId: "", strTitle: "", strImage: "", strPrice: "", strSeller: "")
    var intQuantity = 1

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let objEbay = appdata.arrEbaySearchResults[appdata.intCurrIndex]
        print(objEbay.values())
        fnLoadProductDetails(strItemId: objEbay.strItemId!)
        
        appdata.arrVariations.removeAll()
//        let objProduct = appdata.arrProductSearchResults[appdata.intCurrIndex]
//        fnSearchByASIN(strASIN: objProduct.strParentASIN)
        pickerviewQuantity.isHidden = true
        pickerviewQuantity.delegate = self
        pickerviewQuantity.dataSource = self
        self.navigationItem.title = "Product"
        self.navigationController?.isNavigationBarHidden = false
//        appdata.fnDisplayImage(strImageURL: objProduct.image, img: prodImage, boolCircle: false)
//        prodTitle.text = objProduct.title
//        prodPub.text = objProduct.publisher
//        prodPrice.text = objProduct.price
//        prodDetail.text = objProduct.description
        
        let nibAddNewAddress = UINib(nibName: "ProductImageCollectionViewCell", bundle: nil)
        viewProductImages.register(nibAddNewAddress, forCellWithReuseIdentifier: "ProductImageCell")
        viewProductImages.delegate = self
        viewProductImages.dataSource = self
        
        let nib = UINib(nibName: "SizeCollectionViewCell", bundle: nil)
        viewProductSizes.register(nib, forCellWithReuseIdentifier: "SizeCell")
        viewProductSizes.delegate = self
        viewProductSizes.dataSource = self
//        self.automaticallyAdjustsScrollViewInsets = false;
        
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
        intQuantity = (Int)(strQuantity)!
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
    
    func fnLoadProductDetails(strItemId: String){
        var str: NSString = NSString(string: "https://api.ebay.com/buy/browse/v1/item/\(strItemId)")
        str = str.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)! as NSString
        let goodStr = str as String
        let urlLoadProductDetails = URL(string: goodStr)
        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(UserDefaults.standard.object(forKey: "strEbayToken") as! String)"
        ]
        Alamofire.request(urlLoadProductDetails!, method: .get, encoding: JSONEncoding.default, headers: headers).validate().responseJSON { response in
            switch response.result {
            case .success:
                if let dictionary = response.value {
                    let dict = dictionary as! NSDictionary
                    print(dict)
                    let strItemId = dict["itemId"] as! String
                    let strTitle = dict["title"] as! String
                    let objPrice = dict["price"] as! NSDictionary
                    let strPrice = objPrice["value"] as! String
                    var strImageUrl = ""
                    if dict["image"] != nil {
                        let objImage = dict["image"] as! NSDictionary
                        if objImage["imageUrl"] != nil {
                            strImageUrl = objImage["imageUrl"] as! String
                        } else {
                            strImageUrl = objImage["image"] as! String
                        }
                    } else {
                        strImageUrl = "http://www.searshometownstores.com/c.3721178/hometown/img/no_image_available.jpeg?hei=50&wid=100&sharpen=1"
                    }
//                    let objRating = dict["primaryProductReviewRating"] as! NSDictionary
//                    let strRating = objRating["averageRating"] as! String
                    let objSeller = dict["seller"] as! NSDictionary
                    let strSeller = objSeller["username"] as! String
                    var strDescription = "N/A"
                    if dict["shortDescription"] != nil {
                        strDescription = dict["shortDescription"] as! String
                    }
                    self.objProduct = EbayProduct(strItemId: strItemId, strTitle: strTitle, strImage: strImageUrl, strPrice: strPrice, strSeller: strSeller)
                    self.prodPrice.text = "$\(strPrice)"
                    self.prodPub.text = strSeller
                    self.appdata.fnDisplayImage(strImageURL: strImageUrl, img: self.prodImage, boolCircle: false)
                    self.prodTitle.text = strTitle
                    self.prodDetail.text = strDescription
                }
            case .failure(let error):
                print("Error getting product information")
                print(error)
            }
        }
    }
    
    func fnSearchByASIN(strASIN: String) {
//        dispatchGroup.enter()
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
                    print(objColorsKeys)
                    var intIndex = 0
                    var boolNewIndex = true
                    for color in objColorsKeys {
                        let strColor = color as! String
                        let arrSizes = objColors[strColor] as! NSArray
                        for size in arrSizes {
                            let objSize = size as! NSDictionary
                            let dictSize = objSize as! Dictionary<String, AnyObject>
                            print(dictSize.prettyPrint())
                            let arrASIN = objSize["ASIN"] as! NSArray
                            let strASIN = "\(arrASIN[0])"
                            
//                            if objSize["ImageSets"] != nil {
//                                let arrImageSets = objSize["ImageSets"] as! NSArray
//                                let objImageSets = arrImageSets[0] as! NSDictionary
//                                let arrImageSet = objImageSets["ImageSet"] as! NSArray
//                                var arrImages: [String] = []
//                                for image in arrImageSet {
//                                    let objImage = image as! NSDictionary
//                                    let arrMedImage = objImage["MediumImage"] as! NSArray
//                                    let objMedImage = arrMedImage[0] as! NSDictionary
//                                    let arrURL = objMedImage["URL"] as! NSArray
//                                    let strURL = arrURL[0] as! String
//                                    arrImages.append(strURL)
//                                }
//                                let arrAttributes = objSize["ItemAttributes"] as! NSArray
//                                let objAttributes = arrAttributes[0] as! NSDictionary
//                                let arrTitle = objAttributes["Title"] as! NSArray
//                                let strTitle = arrTitle[0] as! String
//                                let arrSize = objAttributes["Size"] as! NSArray
//                                let strSize = arrSize[0] as! String
//                                
//                                let item: Item = Item(strTitle: strTitle, strASIN: strASIN, strSize: strSize, arrImages: arrImages, strColor: strColor)
//                                if boolNewIndex {
//                                    print("New Index: \(intIndex)")
//                                    self.appdata.arrVariations.insert([item], at: intIndex)
//                                    boolNewIndex = false
//                                } else {
//                                    self.appdata.arrVariations[intIndex].append(item)
//                                }
//                            }
                        }
                        intIndex += 1
                        boolNewIndex = true
                    }
                    DispatchQueue.main.async {
                        self.viewProductImages.reloadData()
                        self.viewProductSizes.reloadData()
                    }
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
    
    @IBAction func btnAddToCartPressed(_ sender: Any) {
        let objCurrentProduct = self.objProduct
        print(objProduct.values())
        var decAmazonPrice : Decimal = 0.00
        let itemPrice = "$\(objCurrentProduct.strPrice)" // change later
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = Locale(identifier: "en_US")
        print(itemPrice)
        if let number = formatter.number(from: itemPrice) {
            decAmazonPrice = number.decimalValue
        }
        print("decAmazonPrice: \(decAmazonPrice)")
        let parameters: Parameters = [
            "amazonASIN": objCurrentProduct.strItemId!,
            "amazonPrice": Decimal(string: objCurrentProduct.strPrice!),
            "quantity": intQuantity,
            "productImageUrl": objCurrentProduct.strImage!,
            "productName": objCurrentProduct.strTitle!
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
        if collectionView == viewProductImages {
            return appdata.arrVariations.count
        } else {
            if appdata.arrVariations.count > 0 {
                print("Number of sizes: \(appdata.arrVariations[intImageIndex].count)")
                return appdata.arrVariations[intImageIndex].count
            } else {
                return 0
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == viewProductImages {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ProductImageCell", for: indexPath) as! ProductImageCollectionViewCell
            print("IndexPath.row: \(indexPath.row)")
            print("First Index arrVariations length: \(appdata.arrVariations[indexPath.row].count)")
            let objProduct = appdata.arrVariations[indexPath.row][0].arrImages
            let primaryImage = objProduct[objProduct.count - 1]
            appdata.fnDisplayImage(strImageURL: primaryImage, img: cell.imgProduct, boolCircle: false)
//            if indexPath.row == intImageIndex {
//                cell.imgProduct.layer.borderColor = UIColor.red.cgColor
//                cell.imgProduct.layer.borderWidth = 1
//            } else {
//                cell.imgProduct.layer.borderColor = UIColor.white.cgColor
//                cell.imgProduct.layer.borderWidth = 0
//            }
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SizeCell", for: indexPath) as! SizeCollectionViewCell
            let arrModelsForOneColor = appdata.arrVariations[0]
            let strSize = arrModelsForOneColor[indexPath.row].strSize
            cell.lblSize.text = strSize
            return cell

        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        let item = collectionView[indexPath.row]
        intImageIndex = indexPath.row
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ProductImageCell", for: indexPath) as! ProductImageCollectionViewCell
        cell.imgProduct.layer.borderColor = UIColor.red.cgColor
        cell.imgProduct.layer.borderWidth = 1
//        if indexPath.row == intImageIndex {
//            cell.imgProduct.layer.borderColor = UIColor.red.cgColor
//            cell.imgProduct.layer.borderWidth = 1
//        } else {
//            cell.imgProduct.layer.borderColor = UIColor.white.cgColor
//            cell.imgProduct.layer.borderWidth = 0
//        }
        viewProductSizes.reloadData()
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
            tabBarController.selectedIndex = 2
        }
    }
    
}
