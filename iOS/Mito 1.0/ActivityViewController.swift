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
    override func viewDidLoad() {
        super.viewDidLoad()
        peopleTableView.delegate = self
        peopleTableView.dataSource = self
        peopleTableView.rowHeight = 106
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        peopleTableView.reloadData()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return appdata.people.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        myIndex = indexPath.row
//        performSegue(withIdentifier: "segue", sender: self)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "activityCell", for: indexPath) as! TableViewCell
        let personObj = appdata.people[indexPath.row]
        cell.img.image = UIImage(named: "\(personObj.avatar)")
        cell.name.text = "\(personObj.firstName) \(personObj.lastName)"
        cell.handle.text = "\(personObj.handle)"
        cell.friendshipType.text = "\(personObj.friendshipType)"
        return cell
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
