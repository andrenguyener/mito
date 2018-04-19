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
    var strProductResultsPageNumber = 1
    var strSearchQuery = ""
    var appdata = AppData.shared
    var urlPeopleCall = URL(string: "https://api.projectmito.io/v1/friend/")
    var urlAllUserCall = URL(string: "https://api.projectmito.io/v1/users/all")
    var urlAmazonProductCall = URL(string: "https://api.projectmito.io/v1/amazonhashtest" )
    
    // used to keep track of orginal url call for checks
    var ogAmazonProductCall = URL(string: "https://api.projectmito.io/v1/amazonhashtest" )
    
    @IBOutlet weak var swirlSearchImg: UIImageView!
    
    // Clear searchBar.text and transition to the other view
    @IBAction func switchTab(_ sender: UISegmentedControl) {
        searchBar.text = ""
        if productPeopleTab.selectedSegmentIndex == 0 {
            if peopleTableView == nil {
                swirlSearchImg.isHidden = false
            }
            UIView.transition(from: peopleView, to: productView, duration: 0, options: .showHideTransitionViews)
        } else {
            fnLoadFriendsAndAllUsers()
            swirlSearchImg.isHidden = true
            UIView.transition(from: productView, to: peopleView, duration: 0, options: .showHideTransitionViews)
        }
        intSegmentedIndex = productPeopleTab.selectedSegmentIndex
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        peopleTableView.delegate = self
        peopleTableView.dataSource = self
        peopleTableView.rowHeight = 106
    
        productTableView.delegate = self
        productTableView.dataSource = self
        productTableView.rowHeight = 106
        
        if peopleTableView == nil {
            swirlSearchImg.isHidden = false
        }
        
        searchBar.delegate = self
        searchBar.returnKeyType = UIReturnKeyType.done
        
        peopleTableView.reloadData()
        productTableView.reloadData()
        spinnerProductSearch.isHidden = true
//        productPeopleTab.selectedSegmentIndex = intSegmentedIndex
        strProductResultsPageNumber = 1
    }
    
//    func viewWillAppear() {
//        productPeopleTab.selectedSegmentIndex = intSegmentedIndex
//    }
    
    func fnLoadFriendsAndAllUsers() {
        self.appdata.arrFriendsAndAllMitoUsers.removeAll()
        self.appdata.arrFriends.removeAll()
        self.appdata.arrAllUsers.removeAll()
        self.fnLoadFriendData()
        self.fnLoadAllUsers()
        
        // Use arrFriendsAndAllMitoUsers and display filtered results in arrCurrFriendsAndAllMitoUsers
        self.appdata.arrCurrFriendsAndAllMitoUsers = self.appdata.arrFriendsAndAllMitoUsers
        self.appdata.arrCurrFriends = self.appdata.arrFriends
        self.appdata.arrCurrAllUsers = self.appdata.arrAllUsers
    }
    
    // Loading Friends (people tab)
    // POST: inserting (attach object) / GET request: put key word in the URL
    func fnLoadFriendData() {
        let urlGetFriends = URL(string: (urlPeopleCall?.absoluteString)! + "1")
        let headers: HTTPHeaders = [
            "Authorization": UserDefaults.standard.object(forKey: "Authorization") as! String
        ]
        Alamofire.request(urlGetFriends!, method: .get, encoding: JSONEncoding.default, headers: headers).validate().responseJSON { response in
            switch response.result {
            case .success:
                if let dictionary = response.result.value {
                    let dict2 = dictionary as! NSArray
                    for obj in dict2 {
                        let object = obj as! NSDictionary
                        let p: Person = Person(firstName: (object["UserFname"] as? String)!,
                                               lastName: (object["UserLname"] as? String)!,
                                               email: (object["UserEmail"] as? String?)!!,
                                               avatar: (object["PhotoUrl"] as? String?)!!,
                                               intUserID: (object["UserId"] as? Int)!,
                                               strUsername: (object["Username"] as? String)!,
                                               intNumFriends: (object["NumFriends"] as? Int)!)
                        self.appdata.arrFriends.append(p)
                    }
                    self.appdata.arrFriendsAndAllMitoUsers.append(self.appdata.arrFriends)
                    DispatchQueue.main.async {
                        self.appdata.arrCurrFriendsAndAllMitoUsers = self.appdata.arrFriendsAndAllMitoUsers
                        self.peopleTableView.reloadData()
                    }
                }
                
            case .failure(let error):
                print("Get all users error")
                print(error)
            }
        }
    }
    
    func fnLoadAllUsers() {
        let headers: HTTPHeaders = [
            "Authorization": UserDefaults.standard.object(forKey: "Authorization") as! String
        ]
        Alamofire.request(urlAllUserCall!, method: .get, encoding: JSONEncoding.default, headers: headers).validate().responseJSON { response in
            switch response.result {
            case .success:
                if let dictionary = response.result.value {
                    let objUsers = dictionary as! NSArray
                    for objUser in objUsers {
                        let objPerson2 = objUser as! NSDictionary
                        let objPerson = Person(firstName: objPerson2["userFname"] as! String, lastName: objPerson2["userLname"] as! String, email: objPerson2["userEmail"] as! String, avatar: objPerson2["photoURL"] as! String, intUserID: objPerson2["userId"] as! Int, strUsername: objPerson2["username"] as! String, intNumFriends: objPerson2["NumFriends"] as! Int)
                        self.appdata.arrAllUsers.append(objPerson)
                    }
                    self.appdata.arrFriendsAndAllMitoUsers.append(self.appdata.arrAllUsers)
                    self.appdata.arrCurrFriendsAndAllMitoUsers = self.appdata.arrFriendsAndAllMitoUsers
                }
                
            case .failure(let error):
                print("Get all users error")
                print(error)
            }
        }
    }
    
    @IBAction func cartButtonClicked(_ sender: Any) {
        performSegue(withIdentifier: "searchToCart", sender: self)
    }
    
//    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
//        if (productPeopleTab.selectedSegmentIndex == 1) {
//            UIView.transition(from: peopleView, to: productView, duration: 0, options: .showHideTransitionViews)
//        }
//        productPeopleTab.selectedSegmentIndex = 0
//        return true
//    }
    
    // Once text changes, filter friends and all users, then merge into arrCurrFriendsAndAllMitoUsers
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if productPeopleTab.selectedSegmentIndex == 1 {
            if (searchBar.text?.isEmpty)! {
                appdata.arrCurrFriendsAndAllMitoUsers = appdata.arrFriendsAndAllMitoUsers
                appdata.arrCurrAllUsers = appdata.arrAllUsers
                appdata.arrCurrFriends = appdata.arrFriends
                peopleTableView.reloadData()
                return
            } else {
                filterFriends(text: searchText)
                filterAllUsers(text: searchText)
                appdata.arrCurrFriendsAndAllMitoUsers.removeAll()
                appdata.arrCurrFriendsAndAllMitoUsers.append(appdata.arrCurrFriends)
                appdata.arrCurrFriendsAndAllMitoUsers.append(appdata.arrCurrAllUsers)
                peopleTableView.reloadData()
            }
        }
    }
    
    func filterFriends(text: String) {
        appdata.arrCurrFriends = appdata.arrFriends.filter({ person -> Bool in
            return person.firstName.lowercased().contains(text.lowercased())
        })
    }
    
    func filterAllUsers(text: String) {
        appdata.arrCurrAllUsers = appdata.arrAllUsers.filter({ person -> Bool in
            return person.firstName.lowercased().contains(text.lowercased())
        })
    }
    
//    func filterFriendsAndUsers(text: String) {
//        appdata.arrFriendsAndAllMitoUsers = appdata.arrFriendsAndAllMitoUsers.filter({ objPersonGroup -> Bool in
//            return objPersonGroup.contains(where: { (person) -> Bool in
//                person.firstName.contains(text.lowercased())
//            })
//        })
//        productTableView.reloadData()
//    }
    
    // Pressed Enter (Only for product search at the moment)
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        spinnerProductSearch.isHidden = false
        spinnerProductSearch.startAnimating()
//        if (productPeopleTab.selectedSegmentIndex == 1) {
//            UIView.transition(from: peopleView, to: productView, duration: 0, options: .showHideTransitionViews)
//            productPeopleTab.selectedSegmentIndex = 0
//        }
        if (searchBar.text!.count > 0) {
            strSearchQuery = ""
            strSearchQuery = searchBar.text!.replacingOccurrences(of: " ", with: "+")
        } else {
            strSearchQuery = "Amazon"
            searchBar.text = "Amazon"
        }
        searchBar.resignFirstResponder()
        productPeopleTab.isEnabled = false
        fnLoadProductData()
//        productTableView.reloadData()
    }
    
    // Product Tab View
    func fnLoadProductData() {
        appdata.arrProductSearchResults.removeAll()
        let parameters: Parameters = [
            "keyword": strSearchQuery,
            "pageNumber": strProductResultsPageNumber
        ]
        let headers: HTTPHeaders = [
            "Authorization": UserDefaults.standard.object(forKey: "Authorization") as! String
        ]
        Alamofire.request(urlAmazonProductCall!, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers).validate().responseJSON { response in
            switch response.result {
            case .success:
                if let dictionary = response.result.value {
                    let myJson = dictionary as! NSDictionary
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
                            print(product.title)
                            self.appdata.arrProductSearchResults.append(product)
                            self.swirlSearchImg.isHidden = true
                        }
                    }
                    DispatchQueue.main.async {
                        self.productTableView.reloadData()
                        self.productPeopleTab.isEnabled = true
                        self.spinnerProductSearch.stopAnimating()
                    }
                }
                
            case .failure(let error):
                print("Get Amazon Product error")
                print(error)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if productPeopleTab.selectedSegmentIndex == 1 {
            return self.appdata.arrCurrFriendsAndAllMitoUsers[section].count // 10
        } else {
            return appdata.arrProductSearchResults.count
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if productPeopleTab.selectedSegmentIndex == 1 {
            return self.appdata.arrSections[section]
        } else {
            return "Products"
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if productPeopleTab.selectedSegmentIndex == 1 {
            return self.appdata.arrCurrFriendsAndAllMitoUsers.count
        } else {
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if productPeopleTab.selectedSegmentIndex == 0 {
            myIndex = indexPath.row
            appdata.intCurrIndex = myIndex
            performSegue(withIdentifier: "productDetail", sender: self)
        } else {
            myIndex = indexPath.row
            mySection = indexPath.section
            performSegue(withIdentifier: "searchToMitoProfile", sender: self)
        }
    }
    
    // People tab will always show arrCurrFriendsAndAllMitoUsers
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Product
        if productPeopleTab.selectedSegmentIndex == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "productCell", for: indexPath) as! ProductTableViewCell
//            if (indexPath.row == appdata.arrProductSearchResults.count - 1) {
//                strProductResultsPageNumber += 1
//                fnLoadProductData()
//            }
            let objProduct = appdata.arrProductSearchResults[indexPath.row]
            let urlProductImage = URL(string: "\(objProduct.image)")
            if let data = try? Data(contentsOf: urlProductImage!) {
                cell.img.image = UIImage(data: data)!
            }
            cell.title.text = objProduct.title
            cell.publisher.text = objProduct.publisher
            cell.price.text = objProduct.price
            return cell
        } else { // People
            let cell = tableView.dequeueReusableCell(withIdentifier: "activityCell", for: indexPath) as! TableViewCell
            let objPerson = self.appdata.arrCurrFriendsAndAllMitoUsers[indexPath.section][indexPath.row]
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
