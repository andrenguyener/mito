//
//  ActivityViewController.swift
//  Mito 1.0
//
//  Created by JJ Guo on 2/24/18.
//  Copyright © 2018 Benny Souriyadeth. All rights reserved.
//

import UIKit
import UserNotifications

var myIndex = 0

class SearchViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {

    
    @IBOutlet weak var peopleTableView: UITableView!
    @IBOutlet weak var productTableView: UITableView!
    @IBOutlet weak var productPeopleTab: UISegmentedControl!
    @IBOutlet weak var productView: UIView!
    @IBOutlet weak var peopleView: UIView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var spinnerProductSearch: UIActivityIndicatorView!
    
    @IBOutlet weak var productContainer: UIView!
    @IBOutlet weak var peopleContainer: UIView!
    var pageNum = 1
    var strSearchQuery = ""
    var appdata = AppData.shared
    var urlPeopleCall = URL(string: "https://api.projectmito.io/v1/friend/")
    var urlAllUserCall = URL(string: "https://api.projectmito.io/v1/users/all")
    var urlAmazonProductCall = URL(string: "https://api.projectmito.io/v1/amazonhashtest/" )
    let urlAmazonOriginal = URL(string: "https://api.projectmito.io/v1/amazonhashtest/" )

    @IBAction func switchTab(_ sender: UISegmentedControl) {
        if productPeopleTab.selectedSegmentIndex == 0 {
//            appdata.friends.removeAll()
//            let userURL = appdata.userID
//            loadProductData()
            UIView.transition(from: peopleView, to: productView, duration: 0, options: .showHideTransitionViews)
//            productTableView.reloadData()
        } else {
//            appdata.arrFriends.removeAll()
//            fnLoadPeopleData()
            UIView.transition(from: productView, to: peopleView, duration: 0, options: .showHideTransitionViews)
            peopleTableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        peopleTableView.delegate = self
        peopleTableView.dataSource = self
        peopleTableView.rowHeight = 106
        
        productTableView.delegate = self
        productTableView.dataSource = self
        productTableView.rowHeight = 106
        
        searchBar.delegate = self
        searchBar.returnKeyType = UIReturnKeyType.done

        urlPeopleCall = URL(string: "https://api.projectmito.io/v1/friend/\(appdata.intCurrentUserID)")
        fnLoadFriendData()
        print("FriendsCount \(appdata.arrFriends.count)")
        fnLoadProductData()
        peopleTableView.reloadData()
        productTableView.reloadData()
        spinnerProductSearch.isHidden = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
//        appdata.friends.removeAll()
//        appdata.products.removeAll()
//        fnLoadPeopleData()
//        loadProductData()
//        peopleTableView.reloadData()
//        productTableView.reloadData()
    }
    
    @IBAction func cartButtonClicked(_ sender: Any) {
        performSegue(withIdentifier: "searchToCart", sender: self)
    }
    
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        if (productPeopleTab.selectedSegmentIndex == 1) {
            UIView.transition(from: peopleView, to: productView, duration: 0, options: .showHideTransitionViews)
        }
        productPeopleTab.selectedSegmentIndex = 0
        return true
    }
    
    // Pressed Enter
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        spinnerProductSearch.isHidden = false
        spinnerProductSearch.startAnimating()
        if (productPeopleTab.selectedSegmentIndex == 1) {
            UIView.transition(from: peopleView, to: productView, duration: 0, options: .showHideTransitionViews)
            productPeopleTab.selectedSegmentIndex = 0
        }
        if (searchBar.text!.count > 0) {
            strSearchQuery = ""
            strSearchQuery = searchBar.text!.replacingOccurrences(of: " ", with: "+")
        } else {
            strSearchQuery = "Amazon"
            searchBar.text = "Amazon"
        }
        searchBar.resignFirstResponder()
        appdata.arrProductSearchResults.removeAll()
        let urlString = (urlAmazonOriginal?.absoluteString)! + strSearchQuery
        urlAmazonProductCall = URL(string: urlString)
        productPeopleTab.isEnabled = false
        fnLoadProductData()
        productTableView.reloadData()
    }
    
    // Loading Friends (people tab)
    // POST: inserting (attach object) / GET request: put key word in the URL
    func fnLoadFriendData() {
        let urlGetFriends = URL(string: (urlPeopleCall?.absoluteString)! + "/1")
        print(urlGetFriends?.absoluteString)
        let task = URLSession.shared.dataTask(with: urlGetFriends!) { (data, response, error) in
            if error != nil {
                print("ERROR")
            } else {
                if let content = data {
                    do {
                        let objPeopleData = try JSONSerialization.jsonObject(with: content, options: JSONSerialization.ReadingOptions.mutableContainers) as! NSArray
                        for obj in objPeopleData {
                            let object = obj as! NSDictionary
                            print(object)
                            let p: Person = Person(firstName: (object["UserFname"] as? String)!,
                                                   lastName: (object["UserLname"] as? String)!,
                                                   email: (object["UserEmail"] as? String?)!!,
                                                   avatar: (object["PhotoUrl"] as? String?)!!,
                                                   intUserID: (object["UserId"] as? Int)!,
                                                   strUsername: (object["Username"] as? String)!)
                            self.appdata.arrFriends.append(p)
                        }
                        DispatchQueue.main.async {
                            self.peopleTableView.reloadData()
                            self.productPeopleTab.isEnabled = true
                            print("Finished loading people")
                        }
                    } catch {
                        print("Loading People (Catch)")
                    }
                } else {
                    print("Error")
                }
            }
        }
        task.resume()
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
    
    // Product Tab View
    func fnLoadProductData() {
        let task = URLSession.shared.dataTask(with: urlAmazonProductCall!) { (data, response, error) in
            if error != nil {
                print("ERROR")
            } else {
                if let content = data {
                    do {
                        let myJson = try JSONSerialization.jsonObject(with: content, options: JSONSerialization.ReadingOptions.mutableContainers) as! NSDictionary
                        let itemSearchResponse = myJson["ItemSearchResponse"] as! NSDictionary
                        let objItems = self.fnAccessFirstDictionaryInArray(dictObj: itemSearchResponse, arrName: "Items")
                        if objItems["Item"] == nil {
                            print("Error")
                        } else {
                            let arrItem = objItems["Item"] as! NSArray
                            for itemObj in arrItem {
                                let item = itemObj as! NSDictionary
                                let strASIN = self.fnAccesStringinObj(dictObj: item, strAttribute: "ASIN")
                                var strImageURL = ""
                                if item["LargeImage"] != nil {
                                    let objLargeImage = self.fnAccessFirstDictionaryInArray(dictObj: item, arrName: "LargeImage")
                                    strImageURL = self.fnAccesStringinObj(dictObj: objLargeImage, strAttribute: "URL")
                                } else if item["ImageSets"] != nil {
                                    let objImageSets = self.fnAccessFirstDictionaryInArray(dictObj: item, arrName: "ImageSets")
                                    let objImageSet = self.fnAccessFirstDictionaryInArray(dictObj: objImageSets, arrName: "ImageSet")
                                    let objLargeImage = self.fnAccessFirstDictionaryInArray(dictObj: objImageSet, arrName: "LargeImage")
                                    strImageURL = self.fnAccesStringinObj(dictObj: objLargeImage, strAttribute: "URL")
                                } else {
                                    strImageURL = "https://scontent.fsea1-1.fna.fbcdn.net/v/t31.0-8/17621927_1373277742718305_6317412440813490485_o.jpg?oh=4689a54bc23bc4969eacad74b6126fea&oe=5B460897"
                                }
                                let objItemAttribute = self.fnAccessFirstDictionaryInArray(dictObj: item, arrName: "ItemAttributes")
                                
                                var itemFeature = ""
                                if objItemAttribute["Feature"] != nil {
                                    itemFeature = self.fnAccesStringinObj(dictObj: objItemAttribute, strAttribute: "Feature")
                                } else {
                                    itemFeature = "NA"
                                }
                                
                                let title = self.fnAccesStringinObj(dictObj: objItemAttribute, strAttribute: "Title")
                                
                                var formattedPrice = ""
                                if objItemAttribute["ListPrice"] != nil {
                                    let objListPrice = self.fnAccessFirstDictionaryInArray(dictObj: objItemAttribute, arrName: "ListPrice")
                                    formattedPrice = self.fnAccesStringinObj(dictObj: objListPrice, strAttribute: "FormattedPrice")
                                } else {
                                    formattedPrice = "N/A"
                                }
                                var type = ""
                                if objItemAttribute["Binding"] != nil {
                                    type = self.fnAccesStringinObj(dictObj: objItemAttribute, strAttribute: "Binding")
                                } else {
                                    type = self.fnAccesStringinObj(dictObj: objItemAttribute, strAttribute: "ProductGroup")
                                }
                                var publisher_brand = ""
                                if type != "Amazon Video" {
                                    if objItemAttribute["Brand"] != nil {
                                        publisher_brand = self.fnAccesStringinObj(dictObj: objItemAttribute, strAttribute: "Brand")
                                    } else if objItemAttribute["Publisher"] != nil {
                                        publisher_brand = self.fnAccesStringinObj(dictObj: objItemAttribute, strAttribute: "Publisher")
                                    } else {
                                        publisher_brand = self.fnAccesStringinObj(dictObj: objItemAttribute, strAttribute: "Binding")
                                    }
                                } else {
                                    publisher_brand = "Brand"
                                }
                                let product: Product = Product(image: strImageURL, ASIN: strASIN, title: title, publisher: publisher_brand, price: formattedPrice, description: itemFeature)
                                self.appdata.arrProductSearchResults.append(product)
                            }
                        }
                        DispatchQueue.main.async {
                            self.productTableView.reloadData()
                            self.productPeopleTab.isEnabled = true
                            self.spinnerProductSearch.stopAnimating()
                        }
                    } catch {
                        print("Catch")
                    }
                } else {
                    print("Error")
                }
            }
        }
        task.resume()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if productPeopleTab.selectedSegmentIndex == 1 {
            return appdata.arrFriends.count
        } else {
            return appdata.arrProductSearchResults.count
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if productPeopleTab.selectedSegmentIndex == 0 {
            myIndex = indexPath.row
            appdata.intCurrIndex = myIndex
            performSegue(withIdentifier: "productDetail", sender: self)
//            appdata.cart.append(appdata.products[myIndex])
//            print(appdata.cart[appdata.cart.count - 1].title)
//            print("Cart count: \(appdata.cart.count)")
        } else {
            myIndex = indexPath.row
            print("didSelectRowAt Index: \(myIndex)")
            performSegue(withIdentifier: "searchToMitoProfile", sender: self)
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if productPeopleTab.selectedSegmentIndex == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "productCell", for: indexPath) as! ProductTableViewCell
            let objProduct = appdata.arrProductSearchResults[indexPath.row]
            let urlProductImage = URL(string: "\(objProduct.image)")
            if let data = try? Data(contentsOf: urlProductImage!) {
                cell.img.image = UIImage(data: data)!
            }
            cell.title.text = objProduct.title
            cell.publisher.text = objProduct.publisher
            cell.price.text = objProduct.price
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "activityCell", for: indexPath) as! TableViewCell
            let objPerson = appdata.arrFriends[indexPath.row]
            let urlPeopleImage = URL(string:"\(objPerson.avatar)")
            let defaultURL = URL(string: "https://scontent.fsea1-1.fna.fbcdn.net/v/t31.0-8/17621927_1373277742718305_6317412440813490485_o.jpg?oh=4689a54bc23bc4969eacad74b6126fea&oe=5B460897")
            if let data = try? Data(contentsOf: urlPeopleImage!) {
                cell.img.image = UIImage(data: data)!
            } else if let data = try? Data(contentsOf: defaultURL!){
                cell.img.image = UIImage(data: data)
            }
            cell.name.text = "\(objPerson.firstName) \(objPerson.lastName)"
            cell.handle.text = "\(objPerson.email)"
            cell.friendshipType.text = "\(objPerson.avatar)"
            return cell
        }
    }
}
