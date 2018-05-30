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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = true
        searchBar.text = ""
        searchBar.placeholder = "Search products"
        productTableView.delegate = self
        productTableView.dataSource = self
        productTableView.rowHeight = 106
        searchBar.delegate = self
        searchBar.returnKeyType = UIReturnKeyType.done
        searchBar.text = appdata.strProductQuery
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
    
    @IBOutlet weak var swirlSearchImg: UIImageView!
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if (searchBar.text!.replacingOccurrences(of: " ", with: "").count > 0) { // tests for only spaces
            intPageNumber = 1
            spinnerProductSearch.isHidden = false
            spinnerProductSearch.startAnimating()
            swirlSearchImg.isHidden = true
            appdata.strProductQuery = ""
            appdata.strProductQuery = searchBar.text!
            fnLoadEbayProductData(strCodedSearchQuery: searchBar.text!.replacingOccurrences(of: " ", with: "%20"))
            
        }
//        else {
//            appdata.strProductQuery = searchBar.text!.replacingOccurrences(of: " ", with: "")
//            searchBar.text! = ""
//            appdata.strProductQuery = "Amazon"
//            searchBar.text = "Amazon"
//        }
        searchBar.resignFirstResponder()
    }
    
    func fnLoadEbayProductData(strCodedSearchQuery: String) {
        let strFilter = "&filter=buyingOptions:{FIXED_PRICE},conditions:{NEW}"
        var str: NSString = NSString(string: "https://api.ebay.com/buy/browse/v1/item_summary/search?q=\(strCodedSearchQuery)\(strFilter)")
        str = str.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)! as NSString
        let goodStr = str as? String
        let urlLoadProductDetails = URL(string: goodStr!)
        appdata.arrEbaySearchResults.removeAll()
        print(UserDefaults.standard.object(forKey: "strEbayToken") as! String)
        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(UserDefaults.standard.object(forKey: "strEbayToken") as! String)"
        ]
        print("Header")
        print(headers["Authorization"])
        Alamofire.request(urlLoadProductDetails!, method: .get, encoding: JSONEncoding.default, headers: headers).validate().responseJSON { response in
            switch response.result {
            case .success:
                if let dictionary = response.result.value {
                    let dict = dictionary as! NSDictionary
                    let prettyDict = dictionary as! Dictionary<String, AnyObject>
                   // print(prettyDict.prettyPrint())
                    //print(dict)
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
                            let objEbay = EbayProduct(strItemId: strItemId, strTitle: strTitle, strImage: strImageUrl, strPrice: strPrice, strSeller: strSeller)
                            self.appdata.arrEbaySearchResults.append(objEbay)
                            index += 1
                        }
                        //print(self.appdata.arrEbaySearchResults[0].values())
                    }
                }
                DispatchQueue.main.async {
                    self.productTableView.reloadData()
                    self.spinnerProductSearch.stopAnimating()
                    self.spinnerProductSearch.isHidden = true
                    self.scrollToFirstRow()
                }
                
            case .failure(let error):
                print("Error getting Ebay products")
                print(error.localizedDescription)
                if error.localizedDescription == "The request timed out." {
                    let alert = self.appdata.fnDisplayAlert(title: "Error", message: "Amazon services are down blame Jeff Bezos")
                    self.present(alert, animated: true, completion: nil)
                } else if error.localizedDescription == "Response status code was unacceptable: 401." {
                    let alert = self.appdata.fnDisplayAlert(title: "Error", message: "You probably have an invalid access token")
                    self.present(alert, animated: true, completion: nil)
                }
                print(error)
                DispatchQueue.main.async {
                    self.spinnerProductSearch.stopAnimating()
                    self.spinnerProductSearch.isHidden = true
                }
            }
        }
    }
    
    func scrollToFirstRow() {
        let indexPath = NSIndexPath(row: 0, section: 0)
        self.productTableView.scrollToRow(at: indexPath as IndexPath, at: .top, animated: false)
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return appdata.arrEbaySearchResults.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        myIndex = indexPath.row
        appdata.intCurrIndex = myIndex
        performSegue(withIdentifier: "segSeeProductDetails", sender: self)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "productCell", for: indexPath) as! ProductTableViewCell
        let objProduct = appdata.arrEbaySearchResults[indexPath.row]
        appdata.fnDisplayImage(strImageURL: objProduct.strImage!, img: cell.img, boolCircle: false)
        cell.title.text = objProduct.strTitle
        cell.publisher.text = objProduct.strSeller
        cell.price.text = "$\(objProduct.strPrice!)"
        return cell
    }
    
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

ß
