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
        let strBearerToken = "Bearer v^1.1#i^1#f^0#p^1#r^0#I^3#t^H4sIAAAAAAAAAOVXXWwUVRTutN2SBot/iARIWAcQEWb2zszO7szIbrK0EAq0XdhKoEia+blDh52dGWdmaTdK2FTFhCjWggZCiMRgCoYIJPBgwJjwgGKUiAQpGvHBIIKGWBENGtE7s0vZVsJvERL3ZXPPPffc833nO/fOBfmq6idXz179ew02rHxLHuTLMYwaDqqrAlNHVJSPCZSBEgdsS35ivrKz4ofpjpjRLWEBdCzTcGCwI6MbjuAbY3jWNgRTdDRHMMQMdARXFlKJhnkCTQLBsk3XlE0dD9bXxXCVi0gqgDKIRiWGp8LIalyO2WzGcFmO8pBnWY6noyKUIJp3nCysNxxXNNwYTgOKIwBL0FwzzQgACCxPsjTdggcXQtvRTAO5kACP++kK/lq7JNdrpyo6DrRdFASP1ydmpZoS9XUzG5unh0pixYs8pFzRzToDR7WmAoMLRT0Lr72N43sLqawsQ8fBQ/HCDgODConLydxC+j7VLEfBcIRhJImGnBQGQ0LlLNPOiO618/AsmkKovqsADVdzc9djFLEhLYeyWxw1ohD1dUHvb35W1DVVg3YMnzkjsTiRTOLxlGm1QTHdSCRt01vVQCQX1BEsLcuSAiEkwrwYoaEULm5UiFakedBOtaahaB5pTrDRdGdAlDUcyA0tsCXcIKcmo8lOqK6XUb8f3wyoyxxS0RavqIUqZt02w6srzCAigv7w+hXoX+26tiZlXdgfYfCET1EMFy1LU/DBk74Wi/LpcGJ4m+taQijU3t5OtjOkaS8L0QBQoUUN81JyG8yIOPL1er3gr11/AaH5UGTUpshfcHMWyqUDaRUlYCzD4zQXphi+yPvAtOKDrf8ylGAODeyIoeoQXmVAlI9EAa2wQI5yQ9Eh8aJIQ14eUBJzREa009C1dFGGhIx0ls1AW1MEhlVphlMhoUR4FSlWVQmJVSIEpUIIIJQkmef+T41yo1JPyaYFk6auybkhEfyQiZ2xlaRou7kU1HVkuFHVXxWk44G84/C8Xr8piF4MBwURLY30tE3KZiZkiuhQ80ytfta3hVtD9+E9VVQEsIBUUwoXGenDJZ0VMmlDx8za6A4nm7xzvdlMQwN1iWubug7thdRtMTF0J/pdOs2vikrWNURj672G7CaPyVvUtujeRdSVndiSqyCnWDrKhrkwe3t1rfXr2pz7Dw6tmyrsbNNxoXIHPkBCA59D8TL/R3Vie0Enthu9qEAITKImgMeqKp6urLhvjKO5kNRElXS0ZQb6yrchmYY5S9Ts8ipsybhd21tLHmBbloLR/U+w6gpqeMl7DIy7MhOg7n+0huIAS3M0AwDLt4AJV2YrqVGVI0Nn4+9nDlazWxeM2LC4e9rK77HHo6Cm3wnDAmVIGWWVcF1aZLjM/KVvnhw7ZdW3pzv22D+fPfbQA2+p9Dlres0H547JLS+f6hp14O1pOeLzzjPPfXF0bVlw5KK+hj/7DtG/ffjlwUMjZj5z/tSauY2/HObemNR2eva+URsu7uzayFz69cjxz/o2RVq7Jq4s+7Rv3aLD2xcr+dc3v3j8xwmb50bzn6TLx34U7Gna2Tp+Y0P3oa1H1j71XWBfz7BHVmwbZ7zHB2v0hvHztLZAetfUP/ZWj665dAFLrtn76l89O6bs+ebS4Xd2dJ94do5xYs7XpzYdX99tNT48+bX8gXBv78kTzx9dvu3B2uU7V6+qf+EJ9auJ5dsD8d0fv3JhMpnq/endi3VnMKHl7/P71+9/qVC+fwDfz4XjGg8AAA=="
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
                            let objImage = item["image"] as! NSDictionary
                            var strImageUrl = ""
                            if objImage["imageUrl"] != nil {
                                strImageUrl = objImage["imageUrl"] as! String
                            } else {
                                strImageUrl = objImage["image"] as! String
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
                print("Get Amazon Product error")
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
