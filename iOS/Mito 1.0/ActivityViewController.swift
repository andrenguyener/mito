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
        print(productPeopleTab.selectedSegmentIndex)
        if productPeopleTab.selectedSegmentIndex == 0 {
            UIView.transition(from: peopleTableView, to: productTableView, duration: 0, options: .showHideTransitionViews)
        } else {
            UIView.transition(from: productTableView, to: peopleTableView, duration: 0, options: .showHideTransitionViews)
        }
    }
    
    var appdata = AppData.shared
    var url = URL(string: "https://api.projectmito.io/v1/friend/34")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        peopleTableView.delegate = self
        peopleTableView.dataSource = self
        peopleTableView.rowHeight = 106
        
        productTableView.delegate = self
        productTableView.dataSource = self
        productTableView.rowHeight = 106
        
        loadPeopleData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        appdata.friends.removeAll()
        loadPeopleData()
        peopleTableView.reloadData()
    }
    
    func loadPeopleData() {
        let task = URLSession.shared.dataTask(with: url!) { (data, response, error) in
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
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return appdata.friends.count
//        return appdata.people.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        myIndex = indexPath.row
//        performSegue(withIdentifier: "segue", sender: self)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "activityCell", for: indexPath) as! TableViewCell
        let personObj = appdata.friends[indexPath.row]
//        cell.img.image = UIImage(named: "\(personObj.avatar)")
        cell.name.text = "\(personObj.firstName) \(personObj.lastName)"
        cell.handle.text = "\(personObj.email)"
        let url = URL(string:"\(personObj.avatar)")
        let defaultURL = URL(string: "https://www.sparklabs.com/forum/styles/comboot/theme/images/default_avatar.jpg")
        if let data = try? Data(contentsOf: url!) {
            cell.img.image = UIImage(data: data)!
        } else if let data = try? Data(contentsOf: defaultURL!){
            cell.img.image = UIImage(data: data)
        }
//        cell.img.image = UIImage(named: "Sopheak.png")
        cell.friendshipType.text = "\(personObj.avatar)"
//        cell.friendshipType.text = "\(personObj.friendshipType)"
        return cell
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
