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
    let formatter = NumberFormatter()
    var intImageIndex = 0

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
    
    func fnLoadProductDetails(strItemId: String){
        var str: NSString = NSString(string: "https://api.ebay.com/buy/browse/v1/item/\(strItemId)")
//        let newStrItemId = strItemId.replacingOccurrences(of: "|", with: "%")
//        var str = NSString(string: strItemId)
        str = str.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)! as NSString
        let goodStr = str as! String
        let urlLoadProductDetails = URL(string: goodStr)
//        let safeURL =  urlLoadProductDetails.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!
        print(urlLoadProductDetails?.absoluteString)
        let headers: HTTPHeaders = [
            "Authorization": "Bearer v^1.1#i^1#f^0#r^0#p^1#I^3#t^H4sIAAAAAAAAAOVXa2wUVRTubh9SS7USA6ZCWKaCj2Zm78zuDDsTdmGhVDah7dottVZIncfdduzszHbuXdqNEZtqeZgGNcbEGKNNjG+oVovhoTFRovgI0hiD0cQgMUpQfEQTTAzgnelStoXwLELi/tnMueeee77vfOc+QG9J6R3rV6w/Wu65xjvYC3q9Hg9bBkpLiquvK/RWFheAPAfPYO8tvUV9hYcWITllpKVGiNKWiaCvJ2WYSHKNYSpjm5IlIx1JppyCSMKqlIjWrZQ4Bkhp28KWahmUL1YTprRgQGBFQWVZwItcUiRW82TMJitMyUEAeIUVFCEQ4FlRJeMIZWDMRFg2cZjiABuiAU9zYhPgJMBKLMuEOKGV8jVDG+mWSVwYQEXcdCV3rp2X69lTlRGCNiZBqEgsWptoiMZqltc3LfLnxYrkeEhgGWfQxK9llgZ9zbKRgWdfBrneUiKjqhAhyh8ZW2FiUCl6MpmLSN+lOhCSoRZYKATEEB/ixClhstayUzI+exqORdfopOsqQRPrOHsuQgkZyv1QxbmvehIiVuNz/u7KyIae1KEdppYvjd4TjcepSMJKd0C5s56O25Yzq46ON9bQPKeqigYhpIOiLHBQCeYWGouWY3nSSsssU9MdzpCv3sJLIckaTuSGlfg8bohTg9lgR5PYySjfLzjOIWh1ajpWxAzuMJ2ywhQhwud+nrsC47MxtnUlg+F4hMkDLkWka9JpXaMmD7pSzKmnB4WpDozTkt/f3d3NdAcYy273cwCw/pa6lQm1A6ZkyvF1et311889gdZdKCokM5Eu4Wya5NJDpEoSMNupCBcKsgExx/vEtCKTracZ8jD7JzbEVDWICjQBKIIAg0FV4Fk4FR0SyYnU7+QBFTlLp2S7E+K0IauQVonOMilo65oU4JNcIJSEtCaISaLYZJJWeE2g2SSEAEJFUcXQ/6lRzlfqCdVKw7hl6Gp2agQ/VWIP2FpctnE2AQ2DGM5X9WcEiRyQlx+e0+sXAtGJgUgQOa0zjrYZ1Ur5LZlsao6pzc36knDr5Di8qopKAI4h1bWxg4xx4TJorcrYEFkZmxzhTIOzrzdZndAkXYJtyzCg3cxeEhNTuKNfmd38jKhUQyc0tl1tyC5wm7xIbcv4SqIu6vO0no6c5bmFPLmIL7w0tS5z69qU/S82rQsp7AoLYahdhguIf+JrKFLg/tg+zzbQ5xkmDyrgB/PZKjCvpHBVUeH0SqRjyOhykkF6u0ku+TZkOmE2Leu2t8Rz7+w3X23Le38NrgE3jb/ASgvZsrznGJh9aqSYvX5WORsCPCcCcsCybCuoOjVaxM4suvHA8eqIZzhy4rb75le0PtR4+527E6+D8nEnj6e4gAijoKzj4eq3vVvann+jSF2z1h7KvDNv/1PPfh3cqRe/UnZQqIoll+75pmXXJzM+rJ2zpWxk8QO/3rBjH/PbLzePhku+ekuhn3xttZFIdLR837Wr/+nhW19sTqwaGaiuWFQaPDKq/ryj6znKeOH4yrlCtqr/yO4vu09Q2w+q5oIlx+Yc8srm1vLHd69dvW60Ij6nAjwRC287Pmt0Q+O+zZ0fLHn5M/jogc6emfUl/dPuNlJ/TB/8fMPejwZG5m7uX127t1TcOnL0sXWVlUp3y7VmxcfhPT9s2vdghfndez+1b/xrSHimRvl72qft24sHFvye3Vn3T9fiw96hL94vf+nPeTM2Mu/WdH27af/hH4/RLY+Mle9fsFEU0hkPAAA="
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
//                    let objProduct = EbayProduct(strItemId: strItemId, strTitle: strTitle, strImage: strImageUrl, strPrice: strPrice, strSeller: strSeller, strRating: strRating)
                    self.prodPrice.text = strPrice
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
