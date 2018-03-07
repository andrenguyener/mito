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

    @IBAction func switchTab(_ sender: UISegmentedControl) {
        if productPeopleTab.selectedSegmentIndex == 0 {
            UIView.transition(from: peopleTableView, to: productTableView, duration: 0, options: .showHideTransitionViews)
        } else {
            UIView.transition(from: productTableView, to: peopleTableView, duration: 0, options: .showHideTransitionViews)
        }
    }
    
    var appdata = AppData.shared
    var peopleUrl = URL(string: "https://api.projectmito.io/v1/friend/34")
    var prodUrl = URL(string: "https://api.projectmito.io/v1/amazonhashtest/bunny" )
    
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
    }
    
    override func viewDidAppear(_ animated: Bool) {
        appdata.friends.removeAll()
        loadPeopleData()
        peopleTableView.reloadData()
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
                            print("hi")
                            let object = obj as! NSDictionary
                            let p: Person = Person(firstName: (object["UserFname"] as? String)!, lastName: (object["UserLname"] as? String)!, email: (object["UserEmail"] as? String!)!, avatar: (object["PhotoUrl"] as? String!)!)
                            print(p.description())
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
                        let items = itemSearchResponse["Items"] as! NSArray
                        let secondObj = items[0] as! NSDictionary
                        let item = secondObj["Item"] as! NSArray
                        var idx = 0
                        for itemObj in item {
                            let item = itemObj as! NSDictionary
                            let ASINArray = item["ASIN"] as! NSArray
                            print("\(idx): \(ASINArray[0] as! String)")
                            idx += 1
                        }
                        DispatchQueue.main.async {
                            //self.peopleTableView.reloadData()
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
        return appdata.friends.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        myIndex = indexPath.row
//        performSegue(withIdentifier: "segue", sender: self)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if productPeopleTab.selectedSegmentIndex == 1 {
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
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "activityCell", for: indexPath) as! TableViewCell
            return cell
        }
    }
}
