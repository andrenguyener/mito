//
//  SearchProductsViewController.swift
//  Mito 1.0
//
//  Created by JJ Guo on 5/24/18.
//  Copyright © 2018 Benny Souriyadeth. All rights reserved.
//

import UIKit
import Alamofire

class SearchProductsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {
    
    @IBOutlet weak var productTableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var spinnerProductSearch: UIActivityIndicatorView!
    
    @IBOutlet weak var imgCurrentRecipient: UIImageView!
    
    var appdata = AppData.shared
    var intPageNumber = 1
    var strProductQuery = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = true
        //        self.navigationController?.setNavigationBarHidden(true, animated: animated)
        searchBar.text = ""
        searchBar.placeholder = "Search products"
        productTableView.delegate = self
        productTableView.dataSource = self
        productTableView.rowHeight = 106
        searchBar.delegate = self
        searchBar.returnKeyType = UIReturnKeyType.done
        searchBar.text = strProductQuery
        spinnerProductSearch.isHidden = true
        let data = UserDefaults.standard.object(forKey: "UserInfo") as! NSDictionary
        var strPhotoUrl = data["profileImageString"] as! String
        if strPhotoUrl.count < 100 {
            strPhotoUrl = data["photoURL"] as! String
        }
        appdata.fnDisplayImage(strImageURL: strPhotoUrl, img: imgCurrentRecipient, boolCircle: true)
        imgCurrentRecipient.isUserInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.fnGoToSettings))
        imgCurrentRecipient.addGestureRecognizer(tapGesture)
        // Do any additional setup after loading the view.
    }
    
    @objc func fnGoToSettings() {
        performSegue(withIdentifier: "segProductsToSettings", sender: self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func btnCartPressed(_ sender: Any) {
        performSegue(withIdentifier: "segSearchProductToCart", sender: self)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if (searchBar.text!.replacingOccurrences(of: " ", with: "").count > 0) { // tests for only spaces
            intPageNumber = 1
            spinnerProductSearch.isHidden = false
            spinnerProductSearch.startAnimating()
            //            swirlSearchImg.isHidden = true
            strProductQuery = ""
            strProductQuery = searchBar.text!
            //            fnLoadEbayProductData(strCodedSearchQuery: )
            fnLoadEbayProductData(strCodedSearchQuery: searchBar.text!.replacingOccurrences(of: " ", with: "%20"))
        } else {
            strProductQuery = searchBar.text!.replacingOccurrences(of: " ", with: "")
            searchBar.text! = ""
            strProductQuery = "Amazon"
            searchBar.text = "Amazon"
        }
        searchBar.resignFirstResponder()
    }
    
    func fnLoadEbayProductData(strCodedSearchQuery: String) {
        let urlEbayProductCall = URL(string: "https://api.ebay.com/buy/browse/v1/item_summary/search?q=\(strCodedSearchQuery)")
        appdata.arrEbaySearchResults.removeAll()
        let strBearerToken = "Bearer v^1.1#i^1#p^1#r^0#I^3#f^0#t^H4sIAAAAAAAAAOVXXWwUVRTubtuFisWYgBCsyTJASCkze2dmZ7szdjdZWqDlp13Y2mBR6/zc6V67OzOZO0u7iSalRqKi/NgHiRjFoAbkQRCJxAetYkIkPBDFhEjhwfiAotEoBNSg3pldyrYQfouQuC+bOffcc8/3ne+cmQv6A1Xz1jWvO1ftm+Df1g/6/T4fOwlUBSrrJpf7Z1SWgRIH37b+2f0VA+WnGrCczVjSSogt08Aw2JfNGFjyjDEqZxuSKWOEJUPOQiw5qpRKLF8mcQyQLNt0TNXMUMGWphglhlkAo3xUF+uFcD3UidW4GLPdjFGsEuHUsBCOagpxgCxZxzgHWwzsyIYTozjARmkg0JzYDlgJ8FI4woiA76SCHdDGyDSICwOouJeu5O21S3K9eqoyxtB2SBAq3pJYlGpLtDQtbG1vCJXEihd5SDmyk8OjnxpNDQY75EwOXv0Y7HlLqZyqQoypULxwwuigUuJiMjeRfoHqCFQEJarLYV4Ro5FxYXKRaWdl5+ppuBak0brnKkHDQU7+WoQSMpSnoOoUn1pJiJamoPu3IidnkI6gHaMWLkg8mkgmqXjKtNJQ7mmlk7bp7lpOJ1c20QKnqooGIaTDohzhoBIuHlSIVmR5zEmNpqEhlzMcbDWdBZBkDUdzAyShhBvi1Ga02QndcTMq9eOLHEbFaKdb00IRc07acMsKs4SIoPd47QqM7HYcGyk5B45EGLvgURSjZMtCGjV20ZNiUT19OEalHceSQqHe3l6ml2dMuzvEAcCGVi1fllLTMCtTrq/b654/uvYGGnlQVEh2YiQ5eYvk0kekShIwuqk4Fw2zvFjkfXRa8bHWywwlmEOjG2K8GoTXoKIJQOQ5Tmej9fx4dEi8KNKQmwdU5Dydle0e6FgZWYW0SnSWy0IbaRIv6BwZg5DWIqJOFKvrtCJoEZrVIQQQKooqRv9PjXK9Uk+ppgWTZgap+fER/HiJnbe1pGw7+RTMZIjhelV/RZDYBXn74bm9fiMQ3RiYBJEtxLjaZlQzGzJlMtRcU5eX9S3hRuR1eFcVlQAsIEVa4UXGeHAZvEZlbIjNnE1e4UybO9fbzR5okC5xbDOTgXYHe0tMjONEvzPT/Iqo1AwiNHbdbchucEzepLZl506irhjwdV6OnBW4ekEQolzklrA1enVtz/8XQ+tGCttsYgdqt+EDJDT6NhQv837sgG8fGPDtIRcqEAJz2FlgZqD8kYrye2dg5EAGyTqDUbdBPvJtyPTAvCUj2x/wra7ZvbOr5P617XEwfeQGVlXOTiq5joGaSyuV7H3TqtkoEDgRsIAPRzrBrEurFewDFVO+e7ViymtLa7ccPLb72c/ef6xq8QZ0AlSPOPl8lWVEGGVHFp4KTB7O1Qzu/2vThT+PVv+4bONQ44Vhe6llTTs5AX35/JuZ+MT1q/atb31pA7M3uX9j+a63areuFjf1nql7uebB3McTH/r8TMfU5uO/5n/wHTs/hOZ2n07+je85Mf/QkVjb17XzPpid/uidhmY0NOl3/zfTugLDbd/+3FPdZW08nEYBoaFd+SO7Vh9a8t79R6cvMfd+RR8+8MI/m89WS+vXWnWvH39x/tqpxoq3f7sAl4Z34yfWbK7t5E++4quZ4F98fo+p7Jh3+qeelZXSUNw6cHZw+2B65/FAzbk9W57bcmj7J9/PX+x8+OnTO/oCb3yx/8k5/oOVfQ11tb/EHp777qz8puGts5+Zuau1UL5/ATyMVm0ZDwAA"
        let headers: HTTPHeaders = [
            "Authorization": strBearerToken
        ]
        Alamofire.request(urlEbayProductCall!, method: .get, encoding: JSONEncoding.default, headers: headers).validate().responseJSON { response in
            switch response.result {
            case .success:
                if let dictionary = response.result.value {
                    let dict = dictionary as! NSDictionary
                    let prettyDict = dictionary as! Dictionary<String, AnyObject>
                    print(prettyDict.prettyPrint())
                    print(dict)
                    if dict["total"] as! Int != 0 {
                        let arrItemSummaries = dict["itemSummaries"] as! NSArray
                        var index = 0
                        for objItem in arrItemSummaries {
                            print(index)
                            let item = objItem as! NSDictionary
                            let strItemId = item["itemId"] as! String
                            let strTitle = item["title"] as! String
                            if index == 22 {
                                print(item)
                            }
                            var strImageUrl = ""
                            if item["image"] != nil {
                                let objImage = item["image"] as! NSDictionary
                                if objImage["imageUrl"] != nil {
                                    strImageUrl = objImage["imageUrl"] as! String
                                } else {
                                    strImageUrl = objImage["image"] as! String
                                }
                            } else {
                                strImageUrl = "http://www.searshometownstores.com/c.3721178/hometown/img/no_image_available.jpeg?hei=50&wid=100&sharpen=1"
                            }
                            let objPrice = item["price"] as! NSDictionary
                            let strPrice = objPrice["value"] as! String
                            let objSeller = item["seller"] as! NSDictionary
                            let strSeller = objSeller["username"] as! String
                            let objEbay = EbayProduct(strItemId: strItemId, strTitle: strTitle, strImage: strImageUrl, strPrice: strPrice, strSeller: strSeller, strUsername: strImageUrl)
                            self.appdata.arrEbaySearchResults.append(objEbay)
                            index += 1
                        }
                        print(self.appdata.arrEbaySearchResults[0].values())
                    }
                }
                DispatchQueue.main.async {
                    self.productTableView.reloadData()
                    self.spinnerProductSearch.stopAnimating()
                    self.spinnerProductSearch.isHidden = true
                }
                
            case .failure(let error):
                print("Error getting Ebay products")
                print(error.localizedDescription)
                if error.localizedDescription == "The request timed out." {
                    let alert = self.appdata.fnDisplayAlert(title: "Error", message: "Amazon services are down blame Jeff Bezos")
                    self.present(alert, animated: true, completion: nil)
                }
                DispatchQueue.main.async {
                    self.spinnerProductSearch.stopAnimating()
                    self.spinnerProductSearch.isHidden = true
                }
            }
        }
    }
    
    //    func fnLoadProductData(strCodedSearchQuery: String, intProductResultsPageNumber: Int) {
    //        let urlAmazonProductCall = URL(string: "https://api.projectmito.io/v1/amazonhashtest")
    //        appdata.arrProductSearchResults.removeAll()
    //        print("fnLoadProductData Search query: \(strProductQuery)")
    //        let parameters: Parameters = [
    //            "keyword": strCodedSearchQuery,
    //            "pageNumber": intProductResultsPageNumber
    //        ]
    //        let headers: HTTPHeaders = [
    //            "Authorization": UserDefaults.standard.object(forKey: "Authorization") as! String
    //        ]
    //        Alamofire.request(urlAmazonProductCall!, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers).validate().responseJSON { response in
    //            switch response.result {
    //            case .success:
    //                if let dictionary = response.result.value {
    //                    let dict = dictionary as! Dictionary<String, AnyObject>
    //                    print(dict.prettyPrint())
    //                    print("JSON OBject")
    //                    //                    print(dictionary)
    //                    print("Loaded search results successfully")
    //                    let myJson = dictionary as! NSDictionary
    //                    //                    print(myJson)
    //                    UserDefaults.standard.set(myJson, forKey: "ProductSearchResultsJSON")
    //                    if UserDefaults.standard.object(forKey: "ProductSearchResultsJSON") != nil {
    //                        print("ProductSearchResultsJSON is saved properly")
    //                        let myJson = UserDefaults.standard.object(forKey: "ProductSearchResultsJSON") as! NSDictionary
    //                        //                        print(myJson)
    //                        self.fnLoadLocalProductSearchResults(myJson: myJson)
    //                    }
    //                    DispatchQueue.main.async {
    //                        self.productTableView.reloadData()
    //                        self.spinnerProductSearch.stopAnimating()
    //                        self.spinnerProductSearch.isHidden = true
    //                    }
    //                }
    //
    //            case .failure(let error):
    //                print("Get Amazon Product error")
    //                print(error.localizedDescription)
    //                if error.localizedDescription == "The request timed out." {
    //                    let alert = self.appdata.fnDisplayAlert(title: "Error", message: "Amazon services are down blame Jeff Bezos")
    //                    self.present(alert, animated: true, completion: nil)
    //                }
    //                DispatchQueue.main.async {
    //                    self.spinnerProductSearch.stopAnimating()
    //                    self.spinnerProductSearch.isHidden = true
    //                }
    //            }
    //        }
    //    }
    
    //    func fnLoadLocalProductSearchResults(myJson: NSDictionary) {
    //        let itemSearchResponse = myJson["ItemSearchResponse"] as! NSDictionary
    //        //        print(myJson["ItemSearchResponse"] as! NSDictionary)
    //        let objItems = self.fnAccessFirstDictionaryInArray(dictObj: itemSearchResponse, arrName: "Items")
    //        if objItems["Item"] == nil {
    //            print("Item doesn't show up")
    //        } else {
    //            let arrItem = objItems["Item"] as! NSArray
    //            for itemObj in arrItem {
    //                let item = itemObj as! NSDictionary
    //                var strParentASIN = ""
    //                if item["ParentASIN"] != nil {
    //                    strParentASIN = self.fnAccesStringinObj(dictObj: item, strAttribute: "ParentASIN")
    //                }
    //
    //                let strASIN = self.fnAccesStringinObj(dictObj: item, strAttribute: "ASIN")
    //                var strImageURL = ""
    //                if item["LargeImage"] != nil {
    //                    let objLargeImage = self.fnAccessFirstDictionaryInArray(dictObj: item, arrName: "LargeImage")
    //                    strImageURL = self.fnAccesStringinObj(dictObj: objLargeImage, strAttribute: "URL")
    //                } else if item["ImageSets"] != nil {
    //                    let objImageSets = self.fnAccessFirstDictionaryInArray(dictObj: item, arrName: "ImageSets")
    //                    let objImageSet = self.fnAccessFirstDictionaryInArray(dictObj: objImageSets, arrName: "ImageSet")
    //                    let objLargeImage = self.fnAccessFirstDictionaryInArray(dictObj: objImageSet, arrName: "LargeImage")
    //                    strImageURL = self.fnAccesStringinObj(dictObj: objLargeImage, strAttribute: "URL")
    //                } else {
    //                    strImageURL = "https://www.yankee-division.com/uploads/1/7/6/5/17659643/notavailable_2_orig.jpg?210b"
    //                }
    //                let objItemAttribute = self.fnAccessFirstDictionaryInArray(dictObj: item, arrName: "ItemAttributes")
    //
    //                var itemFeature = ""
    //                if objItemAttribute["Feature"] != nil {
    //                    itemFeature = self.fnAccesStringinObj(dictObj: objItemAttribute, strAttribute: "Feature")
    //                } else {
    //                    itemFeature = "N/A"
    //                }
    //
    //                let title = self.fnAccesStringinObj(dictObj: objItemAttribute, strAttribute: "Title")
    //
    //                var formattedPrice = ""
    //                if objItemAttribute["ListPrice"] != nil {
    //                    let objListPrice = self.fnAccessFirstDictionaryInArray(dictObj: objItemAttribute, arrName: "ListPrice")
    //                    formattedPrice = self.fnAccesStringinObj(dictObj: objListPrice, strAttribute: "FormattedPrice")
    //                } else {
    //                    formattedPrice = "N/A"
    //                }
    //                var type = ""
    //                if objItemAttribute["Binding"] != nil {
    //                    type = self.fnAccesStringinObj(dictObj: objItemAttribute, strAttribute: "Binding")
    //                } else {
    //                    type = self.fnAccesStringinObj(dictObj: objItemAttribute, strAttribute: "ProductGroup")
    //                }
    //                var publisher_brand = ""
    //                if type != "Amazon Video" {
    //                    if objItemAttribute["Brand"] != nil {
    //                        publisher_brand = self.fnAccesStringinObj(dictObj: objItemAttribute, strAttribute: "Brand")
    //                    } else if objItemAttribute["Publisher"] != nil {
    //                        publisher_brand = self.fnAccesStringinObj(dictObj: objItemAttribute, strAttribute: "Publisher")
    //                    } else {
    //                        publisher_brand = self.fnAccesStringinObj(dictObj: objItemAttribute, strAttribute: "Binding")
    //                    }
    //                } else {
    //                    publisher_brand = "Brand"
    //                }
    //                let product: Product = Product(image: strImageURL, ASIN: strASIN, title: title, publisher: publisher_brand, price: formattedPrice, description: itemFeature, strParentASIN: strParentASIN)
    //                self.appdata.arrProductSearchResults.append(product)
    //                //                self.swirlSearchImg.isHidden = true
    //            }
    //            DispatchQueue.main.async {
    //                self.productTableView.isHidden = false
    //                self.productTableView.reloadData()
    //            }
    //        }
    //        //        DispatchQueue.main.async {
    //        //            self.productTableView.reloadData()
    //        //            self.productPeopleTab.isEnabled = true
    //        //            self.spinnerProductSearch.stopAnimating()
    //        //        }
    //    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("Product count: \(appdata.arrProductSearchResults.count)")
        return appdata.arrEbaySearchResults.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        myIndex = indexPath.row
        appdata.intCurrIndex = myIndex
        //        performSegue(withIdentifier: "segSeeProductDetails", sender: self)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        print("Chose products")
        print("Product indexPath.row: \(indexPath.row)")
        let cell = tableView.dequeueReusableCell(withIdentifier: "productCell", for: indexPath) as! ProductTableViewCell
        let objProduct = appdata.arrEbaySearchResults[indexPath.row]
        appdata.fnDisplayImage(strImageURL: objProduct.strImage!, img: cell.img, boolCircle: false)
        cell.title.text = objProduct.strTitle
        cell.publisher.text = objProduct.strSeller
        cell.price.text = "$\(objProduct.strPrice!)"
        return cell
    }
    
    //    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
    //        if indexPath.row == appdata.arrProductSearchResults.count - 1 {
    //            intPageNumber += 1
    //            fnLoadProductData(strCodedSearchQuery: strProductQuery, intProductResultsPageNumber: intPageNumber)
    //        }
    //    }
    
    // Access first dictionary object in the dictionary
    func fnAccessFirstDictionaryInArray(dictObj: NSDictionary, arrName: String) -> NSDictionary {
        let arrSmallImage = dictObj[arrName] as! NSArray
        let objSmallImage = arrSmallImage[0] as! NSDictionary
        return objSmallImage
    }
    
    // Access string in dictionary object containing an array
    func fnAccesStringinObj(dictObj: NSDictionary, strAttribute: String) -> String {
        let arrTemp = dictObj[strAttribute] as! NSArray
        return arrTemp[0] as! String
    }
}
