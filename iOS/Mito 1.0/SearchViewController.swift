//
//  ActivityViewController.swift
//  Mito 1.0
//
//  Created by JJ Guo on 2/24/18.
//  Copyright © 2018 Benny Souriyadeth. All rights reserved.
//

import UIKit

class ActivityViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    
    @IBOutlet weak var peopleTableView: UITableView!
    @IBOutlet weak var productTableView: UITableView!
    @IBOutlet weak var productPeopleTab: UISegmentedControl!
    var pageNum = 1

    @IBAction func switchTab(_ sender: UISegmentedControl) {
        if productPeopleTab.selectedSegmentIndex == 0 {
            UIView.transition(from: peopleTableView, to: productTableView, duration: 0, options: .showHideTransitionViews)
            print("\(productPeopleTab.selectedSegmentIndex)")
            pageNum = 0
        } else {
            UIView.transition(from: productTableView, to: peopleTableView, duration: 0, options: .showHideTransitionViews)
            print("\(productPeopleTab.selectedSegmentIndex)")
            pageNum = 1
        }
    }
    
    var appdata = AppData.shared
    var peopleUrl = URL(string: "https://api.projectmito.io/v1/friend/34")
    var prodUrl = URL(string: "https://api.projectmito.io/v1/amazonhashtest/harden" )
    
    override func viewDidLoad() {
        super.viewDidLoad()
        peopleTableView.delegate = self
        peopleTableView.dataSource = self
        peopleTableView.rowHeight = 106
        
        productTableView.delegate = self
        productTableView.dataSource = self
        productTableView.rowHeight = 106
        
        loadPeopleData()
        loadProductData()
//        peopleTableView.reloadData()
//        productTableView.reloadData()
//        print(appdata.products.count)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        appdata.friends.removeAll()
        appdata.products.removeAll()
//        loadPeopleData()
//        peopleTableView.reloadData()
//        loadProductData()
//        productTableView.reloadData()
        
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
                        let myJson = try JSONSerialization.jsonObject(with: content, options: JSONSerialization.ReadingOptions.mutableContainers) as! NSArray
                        for obj in myJson {
                            let object = obj as! NSDictionary
                            let p: Person = Person(firstName: (object["UserFname"] as? String)!, lastName: (object["UserLname"] as? String)!, email: (object["UserEmail"] as? String!)!, avatar: (object["PhotoUrl"] as? String!)!)
//                            print(p.description())
                            self.appdata.friends.append(p)
                        }
                        DispatchQueue.main.async {
                            self.peopleTableView.reloadData()
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
    
    // Product Tab View
    
    func loadProductData() {
        let task = URLSession.shared.dataTask(with: prodUrl!) { (data, response, error) in
            if error != nil {
                print("ERROR")
            } else {
                if let content = data {
                    do {
                        let myJson = try JSONSerialization.jsonObject(with: content, options: JSONSerialization.ReadingOptions.mutableContainers) as! NSDictionary
                        let itemSearchResponse = myJson["ItemSearchResponse"] as! NSDictionary
                        let ItemsArr = itemSearchResponse["Items"] as! NSArray
                        let ItemObj = ItemsArr[0] as! NSDictionary
                        let ItemArr = ItemObj["Item"] as! NSArray
                        var imgURL = ""
                        for itemObj in ItemArr {
                            // some things will throw errors depending on what they search...
                            let item = itemObj as! NSDictionary
                            let ASINArr = item["ASIN"] as! NSArray
                            let ASIN = ASINArr[0] as! String
//                            print("\(idx): \(ASINArray[0] as! String)")
                            let ImageSetsArr = item["ImageSets"] as! NSArray
                            let ImageSetsObj = ImageSetsArr[0] as! NSDictionary
                            let ImageSetArr = ImageSetsObj["ImageSet"] as! NSArray
                            let ImageSetObj = ImageSetArr[0] as! NSDictionary
                            let SmallImageObjArr = ImageSetObj["SmallImage"] as! NSArray
                            let SmallImageObj = SmallImageObjArr[0] as! NSDictionary
                            let URLArr = SmallImageObj["URL"] as! NSArray
                            imgURL = URLArr[0] as! String
//                            if item["ImageSet"] == nil {
//                                let SmallImageArr = item["SmallImage"] as! NSArray
//                                let SmallImageObj = SmallImageArr[0] as! NSDictionary
//                                let URLArr = SmallImageObj["URL"] as! NSArray
//                                imgURL = URLArr[0] as! String
//                                // print(imgURL)
//                            } else {
//
//                            }
                           

                            let ItemAttributesArr = item["ItemAttributes"] as! NSArray
                            let ItemAttributeObj = ItemAttributesArr[0] as! NSDictionary
                            let ListPriceArr = ItemAttributeObj["ListPrice"] as! NSArray
                            let ListPriceObj = ListPriceArr[0] as! NSDictionary
//                            print(ListPriceObj.description)
                            let formattedPriceArr = ListPriceObj["FormattedPrice"] as! NSArray
                            let formattedPrice = formattedPriceArr[0] as! String
//                            print(formattedPrice)
                            let TitleArr = ItemAttributeObj["Title"] as! NSArray
                            let title = TitleArr[0] as! String
                            print(title)
                            let PublisherArr = ItemAttributeObj["Publisher"] as! NSArray
                            let publisher = PublisherArr[0] as! String
//                            print(publisher)
                            let product: Product = Product(image: imgURL, ASIN: ASIN, title: title, publisher: publisher, price: formattedPrice)
                            self.appdata.products.append(product)

                        }
                        DispatchQueue.main.async {
                            self.productTableView.reloadData()
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
            return appdata.friends.count
        } else {
            return appdata.products.count
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        myIndex = indexPath.row
//        performSegue(withIdentifier: "segue", sender: self)
    }
    
    // Trying to figure out why this tableView gets called more than the expected appdata.friends.count
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        if pageNum == 1 {
//            print(indexPath.row)
//            let cell = tableView.dequeueReusableCell(withIdentifier: "activityCell", for: indexPath) as! TableViewCell
//            let personObj = appdata.friends[indexPath.row]
//            cell.name.text = "\(personObj.firstName) \(personObj.lastName)"
//            cell.handle.text = "\(personObj.email)"
//            let url = URL(string:"\(personObj.avatar)")
//            let defaultURL = URL(string: "https://scontent.fsea1-1.fna.fbcdn.net/v/t31.0-8/17621927_1373277742718305_6317412440813490485_o.jpg?oh=4689a54bc23bc4969eacad74b6126fea&oe=5B460897")
//            if let data = try? Data(contentsOf: url!) {
//                cell.img.image = UIImage(data: data)!
//            } else if let data = try? Data(contentsOf: defaultURL!){
//                cell.img.image = UIImage(data: data)
//            }
//            cell.friendshipType.text = "\(personObj.avatar)"
//            return cell
//        } else {
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
//        }
    }
}
