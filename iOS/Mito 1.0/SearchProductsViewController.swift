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
        let strFilter = "&filter=buyingOptions:{FIXED_PRICE},conditions:{NEW}"
        var str: NSString = NSString(string: "https://api.ebay.com/buy/browse/v1/item_summary/search?q=\(strCodedSearchQuery)\(strFilter)")
        str = str.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)! as NSString
        let goodStr = str as? String
        let urlLoadProductDetails = URL(string: goodStr!)
        appdata.arrEbaySearchResults.removeAll()
        let strBearerToken = "Bearer v^1.1#i^1#p^1#I^3#r^0#f^0#t^H4sIAAAAAAAAAOVXD2wTVRhft26ysIkoAYLTlBsGRO/67vrn2nOt6Tomi2wrdAzB6PLu7nU71t7Ve6+MSjSzEhQR0RkDJgiLcVE0MRAyJGRmRsVoiImgMSQExagJiMY/CRqDCb67ldENwhibQGLTpLnvfe973+/3/b7v+kB3WfnCDYs3/FXpuKm4txt0Fzsc/FRQXlZ6z80lxXNKi0CBg6O3e163M1dysgbDVDItLUM4begYudamkjqWbGOIyZi6ZECsYUmHKYQlokjxSOMSSeCAlDYNYihGknE11IUYmed9ICgERUFAIuAVatXPx2wxQkwAid6AByCEPGIwgOgyxhnUoGMCdRJiBMAHWOBjhWAL8EoCkLwCF+R9qxhXKzKxZujUhQNM2M5WsveaBalePlOIMTIJDcKEGyL18eZIQ92ippYad0GscJ6GOIEkg0c+RQ0VuVphMoMufwy2vaV4RlEQxow7PHTCyKBS5HwyV5G+zXRChID3AkVVVNEjBiaFyXrDTEFy+TQsi6ayCdtVQjrRSHYsQikZ8mqkkPxTEw3RUOeyfpZmYFJLaMgMMYtqIysjsRgTjhvpDgQ7m9iYaVi7GtnYsjrWJyiKrFLhsN4g9AtI9uYPGoqWZ3nUSVFDVzWLM+xqMkgtolmj0dzwBdxQp2a92YwkiJVRoZ9/mENhlVXToSJmSIdulRWlKBEu+3HsCgzvJsTU5AxBwxFGL9gUhRiYTmsqM3rRlmJePWtxiOkgJC253V1dXVyXhzPMdrcAAO9+qHFJXOlAKcjYvlavW/7a2BtYzYai0C6l/hLJpmkua6lUaQJ6OxMWAl7eE8zzPjKt8GjrRYYCzO6RDTFZDSJ6ZEEOQl72BBJ+P4KT0SHhvEjdVh5Ihlk2Bc1ORNJJqCBWoTrLpJCpqZLHlxDouYhV/cEEVWwiwco+1c/yCYTo9JNlJRj4PzXKlUo9rhhpFDOSmpKdJMFPktg9phqDJsnGUTJJDVeq+kuCxBbIawDP6vVxQLRiYBoEpjXO0janGCm3AelQs0xtdtYTwq3R1+ENVVQKcAippg69yDgbLofXKJyJsJEx6Suca7bmeovRiXTaJcQ0kklktvITYmIyJ/p1meaXRKUkNUpj242GbJxj8iq1Dcl1Re3MOVZehJz3CaLPL/q9woSwRe26tmSvydAaR2EXG5gg9T/4A+IeeRkKF9kfPufoBznHHnqfAm5wF18N5paVLHeWVMzBGkGcBhMc1tp1+iffRFwnyqahZhaXOR6u2r2rreD61fsImD18ASsv4acW3MZA1YWVUn7arEo+AHxCEHgF+l0Fqi+sOvmZzhlvnvt6UHo88vsTT/+0oPWwduDI+pnfgsphJ4ejtIjqomjHvLIiJXuq56u5h6cvLN63Cz74afln7KyPyitW/zzt+KFXT6QGtx75tf7HQ7lnnzuDz/xdK37y9kGmWNJPb793wS2vt4ns/vUnsvK26v2bjyv7Bp1rxLfIjtnswPQnX6p+v44bQNKW3b210cq772zZU7NuxWt/zL89dXqgROl75Z0pf0Zr+/jQQccdvdsrXvhuZ+M/555pD69B26PCsdbA3j3gbH92fuvguvp12/au+KJ94225346g5x+YEd1Y1b8kdnb5o/uOPeY6et8bmxc0zU6t2NL+ZVNFz9IPfzlaw74Xvn/n1CmnBk46v6lyLa9s+z7Rs+mp+aW5H7y3Tnu5b87HL37w7la4aaDvwOczh8r3L0i7bh4YDwAA"
        let headers: HTTPHeaders = [
            "Authorization": strBearerToken
        ]
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
                }
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
        print("Product count: \(appdata.arrProductSearchResults.count)")
        return appdata.arrEbaySearchResults.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        myIndex = indexPath.row
        appdata.intCurrIndex = myIndex
        performSegue(withIdentifier: "segSeeProductDetails", sender: self)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        print("Chose products")
        print("Product indexPath.row: \(indexPath.row)")
        let cell = tableView.dequeueReusableCell(withIdentifier: "productCell", for: indexPath) as! ProductTableViewCell
        let objProduct = appdata.arrEbaySearchResults[indexPath.row]
        print(objProduct.strImage)
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

