//
//  ActivityViewController.swift
//  Mito 1.0
//
//  Created by JJ Guo on 2/24/18.
//  Copyright © 2018 Benny Souriyadeth. All rights reserved.
//

import UIKit
import UserNotifications

class SearchViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {

    
    @IBOutlet weak var peopleTableView: UITableView!
    @IBOutlet weak var productTableView: UITableView!
    @IBOutlet weak var productPeopleTab: UISegmentedControl!
    @IBOutlet weak var productView: UIView!
    @IBOutlet weak var peopleView: UIView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    @IBOutlet weak var productContainer: UIView!
    @IBOutlet weak var peopleContainer: UIView!
    var tabFlag = false
    var pageNum = 1
    var myIndex = 0
    var searchText = ""
    var searchActive: Bool = false

    @IBAction func switchTab(_ sender: UISegmentedControl) {
        if productPeopleTab.selectedSegmentIndex == 0 {
            //appdata.friends.removeAll()
            let userURL = appdata.userID
//            peopleURL = URL(string: )
            //loadProductData()
            UIView.transition(from: peopleView, to: productView, duration: 0, options: .showHideTransitionViews)
//            if (tabFlag == false) {
            
//                self.tabFlag = true
                DispatchQueue.main.async(execute: {
                    self.productPeopleTab.isEnabled = false
                })
                productTableView.reloadData()
                DispatchQueue.main.async(execute: {
                    self.productPeopleTab.isEnabled = true
                })
//            }
        } else {
            //appdata.products.removeAll()
            //loadPeopleData()
            
            UIView.transition(from: productView, to: peopleView, duration: 0, options: .showHideTransitionViews)
            DispatchQueue.main.async(execute: {
                self.productPeopleTab.isEnabled = false
            })
            
            peopleTableView.reloadData()
            DispatchQueue.main.async(execute: {
                self.productPeopleTab.isEnabled = true
            })
        }
    }
    
    var appdata = AppData.shared
    var peopleUrl = URL(string: "https://api.projectmito.io/v1/friend/")
    var prodUrl = URL(string: "https://api.projectmito.io/v1/amazonhashtest/" )
    var prodOriginalUrl = URL(string: "https://api.projectmito.io/v1/amazonhashtest/" )
    
    override func viewDidLoad() {
        super.viewDidLoad()
        peopleTableView.delegate = self
        peopleTableView.dataSource = self
        peopleTableView.rowHeight = 106
//        productView.isHidden = true
        productTableView.delegate = self
        productTableView.dataSource = self
        productTableView.rowHeight = 106
        searchBar.delegate = self
        searchBar.returnKeyType = UIReturnKeyType.done
        print("userid: \(appdata.userID)")
        let userURL = "https://api.projectmito.io/v1/friend/\(appdata.userID)"
        print("userURL: \(userURL)")
        peopleUrl = URL(string: userURL)
        print(peopleUrl)

//        loadPeopleData()
//        loadProductData()
//        peopleTableView.reloadData()
//        productTableView.reloadData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        //appdata.friends.removeAll()
        appdata.products.removeAll()
//        loadPeopleData()
        loadProductData()
        peopleTableView.reloadData()
        productTableView.reloadData()
        
    }
    
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        if segue.identifier == "searchToProduct" {
//            let talkView = segue.destination as? ProductViewController
//            talkView?.searchText = searchText
//        }
//    }
    
    // Clicked Enter
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if (productPeopleTab.selectedSegmentIndex == 1) {
            UIView.transition(from: peopleView, to: productView, duration: 0, options: .showHideTransitionViews)
        }
        productPeopleTab.selectedSegmentIndex = 0

        print(searchBar.text)
        print("final text: \(searchBar.text)")
        searchText = ""
        searchText = searchBar.text!.replacingOccurrences(of: " ", with: "+")
        print("searchText: \(searchText)")
        searchBar.resignFirstResponder()
        appdata.products.removeAll()
        var urlString = prodOriginalUrl?.absoluteString
        urlString = urlString! + searchText
        prodUrl = URL(string: urlString!)
        productPeopleTab.isEnabled = false
        loadProductData()
        print(productTableView.hasUncommittedUpdates)

        productTableView.reloadData()

        

        
    }
    
    @IBAction func cartButtonClicked(_ sender: Any) {
        performSegue(withIdentifier: "searchToCart", sender: self)
    }
    
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        if (productPeopleTab.selectedSegmentIndex == 1) {
            UIView.transition(from: peopleView, to: productView, duration: 0, options: .showHideTransitionViews)
        }
        productPeopleTab.selectedSegmentIndex = 0
        searchActive = true
        print("Start typing")
        return true
    }
    
    // Loading Friends (people tab)
    // POST: inserting (attach object) / GET request: put key word in the URL
    func loadPeopleData() {
        let task = URLSession.shared.dataTask(with: peopleUrl!) { (data, response, error) in
            if error != nil {
                print("ERROR")
            } else {
                if let content = data {
                    do {
//                        self.productPeopleTab.isEnabled = false
                        let myJson = try JSONSerialization.jsonObject(with: content, options: JSONSerialization.ReadingOptions.mutableContainers) as! NSArray
                        for obj in myJson {
                            let object = obj as! NSDictionary
                            let p: Person = Person(firstName: (object["UserFname"] as? String)!, lastName: (object["UserLname"] as? String)!, email: (object["UserEmail"] as? String!)!, avatar: (object["PhotoUrl"] as? String!)!)
                            self.appdata.friends.append(p)
                        }
                        DispatchQueue.main.async {
                            self.peopleTableView.reloadData()
                            self.productPeopleTab.isEnabled = true
                            
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
      
//        self.productPeopleTab.isEnabled = true
    }
    
    // Product Tab View
    
    func loadProductData() {
        let task = URLSession.shared.dataTask(with: prodUrl!) { (data, response, error) in
            if error != nil {
                print("ERROR")
            } else {
                if let content = data {
                    do {
//                        self.productPeopleTab.isEnabled = false
                        let myJson = try JSONSerialization.jsonObject(with: content, options: JSONSerialization.ReadingOptions.mutableContainers) as! NSDictionary
//                        print(myJson)
                        let itemSearchResponse = myJson["ItemSearchResponse"] as! NSDictionary
                        let ItemsArr = itemSearchResponse["Items"] as! NSArray
                        let ItemsObj = ItemsArr[0] as! NSDictionary
                        if ItemsObj["Item"] == nil {
                            print("Error")
                        } else {
                            let ItemArr = ItemsObj["Item"] as! NSArray
                            for itemObj in ItemArr {
                                // some things will throw errors depending on what they search...
                                let item = itemObj as! NSDictionary
                                let ASINArr = item["ASIN"] as! NSArray
                                let ASIN = ASINArr[0] as! String
    //                            print("\(idx): \(ASINArray[0] as! String)")
                                var imgURL = ""
                                if item["LargeImage"] != nil {
                                    let SmallImageArr = item["LargeImage"] as! NSArray
                                    let SmallImageObj = SmallImageArr[0] as! NSDictionary
                                    let URLArr = SmallImageObj["URL"] as! NSArray
                                    imgURL = URLArr[0] as! String
                                } else if item["ImageSets"] != nil {
                                    let ImageSetsArr = item["ImageSets"] as! NSArray // error
                                    let ImageSetsObj = ImageSetsArr[0] as! NSDictionary
                                    let ImageSetArr = ImageSetsObj["ImageSet"] as! NSArray
                                    let ImageSetObj = ImageSetArr[0] as! NSDictionary
                                    let SmallImageObjArr = ImageSetObj["LargeImage"] as! NSArray
                                    let SmallImageObj = SmallImageObjArr[0] as! NSDictionary
                                    let URLArr = SmallImageObj["URL"] as! NSArray
                                    imgURL = URLArr[0] as! String
                                } else {
                                    imgURL = "https://scontent.fsea1-1.fna.fbcdn.net/v/t31.0-8/17621927_1373277742718305_6317412440813490485_o.jpg?oh=4689a54bc23bc4969eacad74b6126fea&oe=5B460897"
                                }

                                var formattedPrice = ""
                                let ItemAttributesArr = item["ItemAttributes"] as! NSArray
                                let ItemAttributeObj = ItemAttributesArr[0] as! NSDictionary
//                                print(ItemAttributeObj.description)
                                
                                var itemFeature = ""
                                if ItemAttributeObj["Feature"] != nil {
                                    let itemFeatureArray = ItemAttributeObj["Feature"] as! NSArray
                                    itemFeature = itemFeatureArray[0] as! String
                                } else {
                                    itemFeature = "NA"
                                }
                                
                                let TitleArr = ItemAttributeObj["Title"] as! NSArray
                                let title = TitleArr[0] as! String
//                                print(title)
                                if ItemAttributeObj["ListPrice"] != nil {
                                    let ListPriceArr = ItemAttributeObj["ListPrice"] as! NSArray
                                    let ListPriceObj = ListPriceArr[0] as! NSDictionary
                                    //                            print(ListPriceObj.description)
                                    let formattedPriceArr = ListPriceObj["FormattedPrice"] as! NSArray
                                    formattedPrice = formattedPriceArr[0] as! String
                                    //                            print(formattedPrice)
                                } else {
                                    formattedPrice = "N/A"
                                }
//                                print("title: \(title)")
//                                print(ItemAttributeObj.description)
                                var type = ""
                                if ItemAttributeObj["Binding"] != nil {
                                    let binding = ItemAttributeObj["Binding"] as! NSArray
                                    type = binding[0] as! String
                                } else {
                                    let productGroup = ItemAttributeObj["ProductGroup"] as! NSArray
                                    type = productGroup[0] as! String
                                }
                                var publisher_brand = ""
                                if type != "Amazon Video" {
                                    if ItemAttributeObj["Brand"] != nil {
                                        let BrandArr = ItemAttributeObj["Brand"] as! NSArray
                                        publisher_brand = BrandArr[0] as! String
                                    } else if ItemAttributeObj["Publisher"] != nil {
                                        let PublisherArr = ItemAttributeObj["Publisher"] as! NSArray
                                        publisher_brand = PublisherArr[0] as! String
                                    } else {
                                        let BindingArr = ItemAttributeObj["Binding"] as! NSArray
                                        publisher_brand = BindingArr[0] as! String
                                    }
                                    // print(publisher_brand)
                                } else {
//                                    let ProductGroupArr = ItemAttributeObj["ProductGroup"] as! NSArray
                                    publisher_brand = "Brand"
                                }
                                let product: Product = Product(image: imgURL, ASIN: ASIN, title: title, publisher: publisher_brand, price: formattedPrice, description: itemFeature)
                                self.appdata.products.append(product)
                            }
                            print("NumProducts: \(self.appdata.products.count)")
                            print("NumPeople: \(self.appdata.friends.count)")
                        }
                        DispatchQueue.main.async {
                            self.productTableView.reloadData()
                            self.productPeopleTab.isEnabled = true
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
//        self.productPeopleTab.isEnabled = true
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if productPeopleTab.selectedSegmentIndex == 1 {
            return appdata.friends.count
        } else {
            return appdata.products.count
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        myIndex = indexPath.row
        print(myIndex)
        if productPeopleTab.selectedSegmentIndex == 0 {

            appdata.currentIndex = myIndex
            
            performSegue(withIdentifier: "productDetail", sender: self)
//            appdata.cart.append(appdata.products[myIndex])
//            print(appdata.cart[appdata.cart.count - 1].title)
//            print("Cart count: \(appdata.cart.count)")
        }
//        performSegue(withIdentifier: "segue", sender: self)
    }
    
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if productPeopleTab.selectedSegmentIndex == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "productCell", for: indexPath) as! ProductTableViewCell
            let productObj = appdata.products[indexPath.row]
            let url = URL(string: "\(productObj.image)")
            if let data = try? Data(contentsOf: url!) {
                cell.img.image = UIImage(data: data)!
            }
            cell.title.text = productObj.title
            cell.publisher.text = productObj.publisher
            cell.price.text = productObj.price
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "activityCell", for: indexPath) as! TableViewCell
            let personObj = appdata.friends[indexPath.row]
            cell.name.text = "\(personObj.firstName) \(personObj.lastName)"
            cell.handle.text = "\(personObj.email)"
            let url = URL(string:"\(personObj.avatar)")
            let defaultURL = URL(string: "https://scontent.fsea1-1.fna.fbcdn.net/v/t31.0-8/17621927_1373277742718305_6317412440813490485_o.jpg?oh=4689a54bc23bc4969eacad74b6126fea&oe=5B460897")
            if let data = try? Data(contentsOf: url!) {
                cell.img.image = UIImage(data: data)!
            } else if let data = try? Data(contentsOf: defaultURL!){
                cell.img.image = UIImage(data: data)
            }
            cell.friendshipType.text = "\(personObj.avatar)"
            return cell
        }
    }
}
