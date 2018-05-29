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
    
//    func scrollToFirstRow() {
//        let indexPath = NSIndexPath(row: 0, section: 0)
//        self.productTableView.scrollToRow(at: indexPath as IndexPath, at: .top, animated: true)
//    }
    

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
        let urlEbayProductCall = URL(string: "https://api.ebay.com/buy/browse/v1/item_summary/search?q=\(strCodedSearchQuery)")
        appdata.arrEbaySearchResults.removeAll()
        let strBearerToken = "Bearer v^1.1#i^1#f^0#r^0#p^1#I^3#t^H4sIAAAAAAAAAOVXa2wUVRTubh9SS7USA6ZCWKaCj2Zm78zuDDsTdmGhVDah7dottVZIncfdduzszHbuXdqNEZtqeZgGNcbEGKNNjG+oVovhoTFRovgI0hiD0cQgMUpQfEQTTAzgnelStoXwLELi/tnMueeee77vfOc+QG9J6R3rV6w/Wu65xjvYC3q9Hg9bBkpLiquvK/RWFheAPAfPYO8tvUV9hYcWITllpKVGiNKWiaCvJ2WYSHKNYSpjm5IlIx1JppyCSMKqlIjWrZQ4Bkhp28KWahmUL1YTprRgQGBFQWVZwItcUiRW82TMJitMyUEAeIUVFCEQ4FlRJeMIZWDMRFg2cZjiABuiAU9zYhPgJMBKLMuEOKGV8jVDG+mWSVwYQEXcdCV3rp2X69lTlRGCNiZBqEgsWptoiMZqltc3LfLnxYrkeEhgGWfQxK9llgZ9zbKRgWdfBrneUiKjqhAhyh8ZW2FiUCl6MpmLSN+lOhCSoRZYKATEEB/ixClhstayUzI+exqORdfopOsqQRPrOHsuQgkZyv1QxbmvehIiVuNz/u7KyIae1KEdppYvjd4TjcepSMJKd0C5s56O25Yzq46ON9bQPKeqigYhpIOiLHBQCeYWGouWY3nSSsssU9MdzpCv3sJLIckaTuSGlfg8bohTg9lgR5PYySjfLzjOIWh1ajpWxAzuMJ2ywhQhwud+nrsC47MxtnUlg+F4hMkDLkWka9JpXaMmD7pSzKmnB4WpDozTkt/f3d3NdAcYy273cwCw/pa6lQm1A6ZkyvF1et311889gdZdKCokM5Eu4Wya5NJDpEoSMNupCBcKsgExx/vEtCKTracZ8jD7JzbEVDWICjQBKIIAg0FV4Fk4FR0SyYnU7+QBFTlLp2S7E+K0IauQVonOMilo65oU4JNcIJSEtCaISaLYZJJWeE2g2SSEAEJFUcXQ/6lRzlfqCdVKw7hl6Gp2agQ/VWIP2FpctnE2AQ2DGM5X9WcEiRyQlx+e0+sXAtGJgUgQOa0zjrYZ1Ur5LZlsao6pzc36knDr5Di8qopKAI4h1bWxg4xx4TJorcrYEFkZmxzhTIOzrzdZndAkXYJtyzCg3cxeEhNTuKNfmd38jKhUQyc0tl1tyC5wm7xIbcv4SqIu6vO0no6c5bmFPLmIL7w0tS5z69qU/S82rQsp7AoLYahdhguIf+JrKFLg/tg+zzbQ5xkmDyrgB/PZKjCvpHBVUeH0SqRjyOhykkF6u0ku+TZkOmE2Leu2t8Rz7+w3X23Le38NrgE3jb/ASgvZsrznGJh9aqSYvX5WORsCPCcCcsCybCuoOjVaxM4suvHA8eqIZzhy4rb75le0PtR4+527E6+D8nEnj6e4gAijoKzj4eq3vVvann+jSF2z1h7KvDNv/1PPfh3cqRe/UnZQqIoll+75pmXXJzM+rJ2zpWxk8QO/3rBjH/PbLzePhku+ekuhn3xttZFIdLR837Wr/+nhW19sTqwaGaiuWFQaPDKq/ryj6znKeOH4yrlCtqr/yO4vu09Q2w+q5oIlx+Yc8srm1vLHd69dvW60Ij6nAjwRC287Pmt0Q+O+zZ0fLHn5M/jogc6emfUl/dPuNlJ/TB/8fMPejwZG5m7uX127t1TcOnL0sXWVlUp3y7VmxcfhPT9s2vdghfndez+1b/xrSHimRvl72qft24sHFvye3Vn3T9fiw96hL94vf+nPeTM2Mu/WdH27af/hH4/RLY+Mle9fsFEU0hkPAAA="
        let headers: HTTPHeaders = [
            "Authorization": strBearerToken
        ]
        Alamofire.request(urlEbayProductCall!, method: .get, encoding: JSONEncoding.default, headers: headers).validate().responseJSON { response in
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
                            let objEbay = EbayProduct(strItemId: strItemId, strTitle: strTitle, strImage: strImageUrl, strPrice: strPrice, strSeller: strSeller, strUsername: strImageUrl)
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

