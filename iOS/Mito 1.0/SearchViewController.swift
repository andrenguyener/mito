//
//  ActivityViewController.swift
//  Mito 1.0
//
//  Created by JJ Guo on 2/24/18.
//  Copyright © 2018 Benny Souriyadeth. All rights reserved.
//

import UIKit
import UserNotifications
import Alamofire

var myIndex = 0
var mySection = 0
var intSegmentedIndex = 0

class SearchViewController: UIViewController {
    
//    var strSearchQuery = ""
//    @IBOutlet weak var navController: UINavigationItem!
//
//    @IBOutlet weak var peopleTableView: UITableView!
//    @IBOutlet weak var productTableView: UITableView!
//    @IBOutlet weak var productPeopleTab: UISegmentedControl!
//    @IBOutlet weak var productView: UIView!
//    @IBOutlet weak var peopleView: UIView!
//    @IBOutlet weak var searchBar: UISearchBar!
//    @IBOutlet weak var spinnerProductSearch: UIActivityIndicatorView!
//
//    @IBOutlet weak var productContainer: UIView!
//    @IBOutlet weak var peopleContainer: UIView!
//    var strProductResultsPageNumber = 1
//    var appdata = AppData.shared
//
//    @IBOutlet weak var swirlSearchImg: UIImageView!
//
//    // Clear searchBar.text and transition to the other view
//    @IBAction func switchTab(_ sender: UISegmentedControl) {
//        searchBar.text = ""
//        if productPeopleTab.selectedSegmentIndex == 0 {
//            searchBar.placeholder = "Search for products"
//            swirlSearchImg.isHidden = strSearchQuery != ""
//            UIView.transition(from: peopleView, to: productView, duration: 0, options: .showHideTransitionViews)
//        } else {
//            swirlSearchImg.isHidden = true
//            searchBar.placeholder = "Find more friends"
//            appdata.fnLoadFriendsAndAllUsers(tableview: peopleTableView)
//            swirlSearchImg.isHidden = true
//            UIView.transition(from: productView, to: peopleView, duration: 0, options: .showHideTransitionViews)
//        }
//        intSegmentedIndex = productPeopleTab.selectedSegmentIndex
//    }
//
    override func viewDidLoad() {
//        super.viewDidLoad()
//        peopleTableView.delegate = self
//        peopleTableView.dataSource = self
//        peopleTableView.rowHeight = 106
//
//        productTableView.delegate = self
//        productTableView.dataSource = self
//        productTableView.rowHeight = 106
//
//        self.navigationItem.backBarButtonItem?.title = "Poop"
//
//        peopleTableView.keyboardDismissMode = .onDrag //UIScrollViewKeyboardDismissMode.interactive
//
////        if peopleTableView == nil {
////            swirlSearchImg.isHidden = false
////        }
//        searchBar.delegate = self
//        searchBar.returnKeyType = UIReturnKeyType.done
//        searchBar.text = strSearchQuery
//        spinnerProductSearch.isHidden = true
//        strProductResultsPageNumber = 1
//        print("viewDidLoad Search query: \(strSearchQuery)")
//        if UserDefaults.standard.object(forKey: "ProductSearchResultsJSON") != nil  && strSearchQuery != "" {
//            productTableView.isHidden = false
//            swirlSearchImg.isHidden = true
//            fnLoadProductData(strCodedSearchQuery: strSearchQuery.replacingOccurrences(of: " ", with: "+"))
////            self.fnCheckLocalStorageProductSearchResults(filename: "ProductSearchResultsJSON")
//        } else {
//            swirlSearchImg.isHidden = false
//        }
////        fnLoadProductData()
    }
//
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//
//        // Hide the navigation bar on the this view controller
//        self.navigationController?.setNavigationBarHidden(true, animated: animated)
//    }
//
//    override func viewWillDisappear(_ animated: Bool) {
//        super.viewWillDisappear(animated)
//
//        // Show the navigation bar on other view controllers
//        self.navigationController?.setNavigationBarHidden(false, animated: animated)
//    }
//
//    @IBAction func cartButtonClicked(_ sender: Any) {
//        performSegue(withIdentifier: "searchToCart", sender: self)
//    }
//
//    // Once text changes, filter friends and all users, then merge into arrCurrFriendsAndAllMitoUsers
//    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
//        if productPeopleTab.selectedSegmentIndex == 1 {
//            if (searchBar.text?.isEmpty)! {
//                appdata.arrCurrFriendsAndAllMitoUsers = appdata.arrFriendsAndAllMitoUsers
//                appdata.arrCurrAllUsers = appdata.arrAllUsers
//                appdata.arrCurrFriends = appdata.arrFriends
//                peopleTableView.reloadData()
//                return
//            } else {
//                filterFriends(text: searchText)
//                filterAllUsers(text: searchText)
//                appdata.arrCurrFriendsAndAllMitoUsers.removeAll()
//                appdata.arrCurrFriendsAndAllMitoUsers.append(appdata.arrCurrFriends)
//                appdata.arrCurrFriendsAndAllMitoUsers.append(appdata.arrCurrAllUsers)
//                peopleTableView.reloadData()
//            }
//        }
//    }
//
//    func filterFriends(text: String) {
//        appdata.arrCurrFriends = appdata.arrFriends.filter({ person -> Bool in
//            return person.firstName.lowercased().contains(text.lowercased().trimmingCharacters(in: .whitespacesAndNewlines))
//        })
//    }
//
//    func filterAllUsers(text: String) {
//        appdata.arrCurrAllUsers = appdata.arrAllUsers.filter({ person -> Bool in
//            return person.firstName.lowercased().contains(text.lowercased().trimmingCharacters(in: .whitespacesAndNewlines))
//        })
//    }
//
//    // Pressed Enter (Only for product search at the moment)
//    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
//        if productPeopleTab.selectedSegmentIndex == 0 {
//            if (searchBar.text!.replacingOccurrences(of: " ", with: "").count > 0) { // tests for only spaces
//                spinnerProductSearch.isHidden = false
//                spinnerProductSearch.startAnimating()
//                swirlSearchImg.isHidden = true
//                strSearchQuery = ""
//                strSearchQuery = searchBar.text!
//                productPeopleTab.isEnabled = false
//                fnLoadProductData(strCodedSearchQuery: searchBar.text!.replacingOccurrences(of: " ", with: "+"))
//            } else {
//                strSearchQuery = searchBar.text!.replacingOccurrences(of: " ", with: "")
//                searchBar.text! = ""
//                //strSearchQuery = "Amazon"
//                //searchBar.text = "Amazon"
//            }
//            //productPeopleTab.isEnabled = false
//
//        }
//        searchBar.resignFirstResponder()
//    }
//
//    // Product Tab View
//    func fnLoadProductData(strCodedSearchQuery: String) {
//        let urlAmazonProductCall = URL(string: "https://api.projectmito.io/v1/amazonhashtest")
//        appdata.arrProductSearchResults.removeAll()
//        print("fnLoadProductData Search query: \(strSearchQuery)")
//        let parameters: Parameters = [
//            "keyword": strCodedSearchQuery,
//            "pageNumber": strProductResultsPageNumber
//        ]
//        let headers: HTTPHeaders = [
//            "Authorization": UserDefaults.standard.object(forKey: "Authorization") as! String
//        ]
//        Alamofire.request(urlAmazonProductCall!, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers).validate().responseJSON { response in
//            switch response.result {
//            case .success(let JSON):
////                print(JSON)
//                if let dictionary = response.result.value {
//                    print("JSON OBject")
////                    print(dictionary)
//                    print("Loaded search results successfully")
//                    let myJson = dictionary as! NSDictionary
////                    print(myJson)
//                    UserDefaults.standard.set(myJson, forKey: "ProductSearchResultsJSON")
//                    if UserDefaults.standard.object(forKey: "ProductSearchResultsJSON") != nil {
//                        print("ProductSearchResultsJSON is saved properly")
//                        let myJson = UserDefaults.standard.object(forKey: "ProductSearchResultsJSON") as! NSDictionary
////                        print(myJson)
//                        self.fnLoadLocalProductSearchResults(myJson: myJson)
//                    }
//                    DispatchQueue.main.async {
//                        self.productTableView.reloadData()
//                        self.productPeopleTab.isEnabled = true
//                        self.spinnerProductSearch.stopAnimating()
//                    }
//                }
//
//            case .failure(let error):
//                print("Get Amazon Product error")
//                print(error.localizedDescription)
//                let strSSLMessage = "An SSL error has occurred and a secure connection to the server cannot be made."
//                if error.localizedDescription == strSSLMessage {
//                    let alert = self.appdata.fnDisplayAlert(title: "Whoops!", message: "Servers are currently offline ☹️")
//                    self.present(alert, animated: true, completion: nil)
//                } else {
//                    let alert = self.appdata.fnDisplayAlert(title: "Whoops!", message: "Incorrect email or password")
//                    self.present(alert, animated: true, completion: nil)
//                }
//            }
//        }
//    }
//
//    func fnCheckLocalStorageProductSearchResults(filename: String) {
//        let myJson = UserDefaults.standard.object(forKey: "ProductSearchResultsJSON") as! NSDictionary
//        self.fnLoadLocalProductSearchResults(myJson: myJson)
////        if Bundle.main.path(forResource: "\(filename)", ofType: "json") != nil {
////            do {
////                let myJson = UserDefaults.standard.object(forKey: "ProductSearchResultsJSON") as! NSDictionary
////                self.fnLoadLocalProductSearchResults(myJson: myJson)
////            } catch let error {
////                print("parse error: \(error.localizedDescription)")
////            }
////        } else {
////            print("Invalid filename/path.")
////        }
//    }
//
//    func fnLoadLocalProductSearchResults(myJson: NSDictionary) {
//        let itemSearchResponse = myJson["ItemSearchResponse"] as! NSDictionary
////        print(myJson["ItemSearchResponse"] as! NSDictionary)
//        let objItems = self.fnAccessFirstDictionaryInArray(dictObj: itemSearchResponse, arrName: "Items")
//        if objItems["Item"] == nil {
//            print("Item doesn't show up")
//        } else {
//            let arrItem = objItems["Item"] as! NSArray
//            for itemObj in arrItem {
//                let item = itemObj as! NSDictionary
//                if item["ParentASIN"] != nil {
//                    print("ParentASIN: \(item["ParentASIN"])")
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
////                let product: Product = Product(image: strImageURL, ASIN: strASIN, title: title, publisher: publisher_brand, price: formattedPrice, description: itemFeature)
////                self.appdata.arrProductSearchResults.append(product)
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
//
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        if productPeopleTab.selectedSegmentIndex == 1 {
//            let data = UserDefaults.standard.object(forKey: "UserInfo") as! NSDictionary
//            let intNumFriends = data["NumFriends"] as? Int
//            if intNumFriends == 0 {
//                return min(self.appdata.arrCurrAllUsers.count, 10)
//            } else {
//                return min(self.appdata.arrCurrFriendsAndAllMitoUsers[section].count, 10)
//            }
//        } else {
//            print("Product count: \(appdata.arrProductSearchResults.count)")
//            return appdata.arrProductSearchResults.count
//        }
//    }
//
//    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
//        if productPeopleTab.selectedSegmentIndex == 1 {
//            let data = UserDefaults.standard.object(forKey: "UserInfo") as! NSDictionary
//            let intNumFriends = data["NumFriends"] as? Int
//            if intNumFriends == 0 {
//                return "Other people on Mito"
//            } else {
//                return self.appdata.arrSections[section]
//            }
//        } else {
//            return "Products"
//        }
//    }
//
//    func numberOfSections(in tableView: UITableView) -> Int {
//        if productPeopleTab.selectedSegmentIndex == 1 {
//            let data = UserDefaults.standard.object(forKey: "UserInfo") as! NSDictionary
//            let intNumFriends = data["NumFriends"] as? Int
//            if intNumFriends == 0 {
//                return 1
//            } else {
//                return self.appdata.arrCurrFriendsAndAllMitoUsers.count
//            }
//        } else {
//            return 1
//        }
//    }
//
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        myIndex = indexPath.row
//        if productPeopleTab.selectedSegmentIndex == 0 {
//            appdata.intCurrIndex = myIndex
//            performSegue(withIdentifier: "productDetail", sender: self)
//        } else {
//            mySection = indexPath.section
//            if appdata.arrCurrFriendsAndAllMitoUsers[mySection].count == 0 {
//                mySection = 1
//            }
//            appdata.personToView = appdata.arrCurrFriendsAndAllMitoUsers[mySection][myIndex]
//            performSegue(withIdentifier: "searchToMitoProfile", sender: self)
//        }
//        tableView.deselectRow(at: indexPath, animated: true)
//    }
//
//    // People tab will always show arrCurrFriendsAndAllMitoUsers
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        // Product
//        if productPeopleTab.selectedSegmentIndex == 0 {
//            print("Chose products")
//            print("Product indexPath.row: \(indexPath.row)")
//            let cell = tableView.dequeueReusableCell(withIdentifier: "productCell", for: indexPath) as! ProductTableViewCell
//            //            if (indexPath.row == appdata.arrProductSearchResults.count - 1) {
//            //                strProductResultsPageNumber += 1
//            //                fnLoadProductData()
//            //            }
//            let objProduct = appdata.arrProductSearchResults[indexPath.row]
//            appdata.fnDisplayImage(strImageURL: objProduct.image, img: cell.img, boolCircle: false)
//            cell.title.text = objProduct.title
//            cell.publisher.text = objProduct.publisher
//            cell.price.text = objProduct.price
//            return cell
//        } else { // People
//            print("Chose people")
//            print("People indexPath.row: \(indexPath.row)")
//            let cell = tableView.dequeueReusableCell(withIdentifier: "activityCell", for: indexPath) as! TableViewCell
//            let data = UserDefaults.standard.object(forKey: "UserInfo") as! NSDictionary
//            let intNumFriends = data["NumFriends"] as? Int
//            if intNumFriends == 0 {
//                let objPerson = self.appdata.arrCurrAllUsers[indexPath.row]
//                return fnLoadPersonCell(cell: cell, objPerson: objPerson)
//            } else {
//                let objPerson = self.appdata.arrCurrFriendsAndAllMitoUsers[indexPath.section][indexPath.row]
//                return fnLoadPersonCell(cell: cell, objPerson: objPerson)
//            }
//        }
//    }
//
//    func fnLoadPersonCell(cell: TableViewCell, objPerson: Person) -> TableViewCell {
//        appdata.fnDisplayImage(strImageURL: objPerson.avatar, img: cell.img, boolCircle: true)
//        cell.name.text = "\(objPerson.firstName) \(objPerson.lastName)"
//        cell.handle.text = "@\(objPerson.strUsername)"
//        return cell
//    }
//
//    // Access first dictionary object in the dictionary
//    func fnAccessFirstDictionaryInArray(dictObj: NSDictionary, arrName: String) -> NSDictionary {
//        let arrSmallImage = dictObj[arrName] as! NSArray
//        let objSmallImage = arrSmallImage[0] as! NSDictionary
//        return objSmallImage
//    }
//
//    // Access string in dictionary object containing an array
//    func fnAccesStringinObj(dictObj: NSDictionary, strAttribute: String) -> String {
//        let arrTemp = dictObj[strAttribute] as! NSArray
//        return arrTemp[0] as! String
//    }
}
