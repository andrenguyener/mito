//
//  ChooseFriendViewController.swift
//  Mito 1.0
//
//  Created by JJ Guo on 5/17/18.
//  Copyright © 2018 Benny Souriyadeth. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireImage

class ChooseFriendViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {

    @IBOutlet weak var tblviewPeople: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    var appdata = AppData.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tblviewPeople.delegate = self
        tblviewPeople.dataSource = self
        tblviewPeople.rowHeight = 106
        searchBar.delegate = self
        appdata.fnLoadFriendsAndAllUsers(tableview: tblviewPeople)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if (searchBar.text?.isEmpty)! {
            appdata.arrCurrFriendsAndAllMitoUsers = appdata.arrFriendsAndAllMitoUsers
            appdata.arrCurrAllUsers = appdata.arrAllUsers
            appdata.arrCurrFriends = appdata.arrFriends
            tblviewPeople.reloadData()
            return
        } else {
            filterFriends(text: searchText)
            filterAllUsers(text: searchText)
            appdata.arrCurrFriendsAndAllMitoUsers.removeAll()
            appdata.arrCurrFriendsAndAllMitoUsers.append(appdata.arrCurrFriends)
            appdata.arrCurrFriendsAndAllMitoUsers.append(appdata.arrCurrAllUsers)
            tblviewPeople.reloadData()
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        appdata.personRecipient = appdata.arrCurrFriendsAndAllMitoUsers[indexPath.section][indexPath.row]
        self.performSegue(withIdentifier: "segChooseFriendToWriteMessage", sender: self)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.appdata.arrCurrFriendsAndAllMitoUsers[section].count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.appdata.arrCurrFriendsAndAllMitoUsers.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return self.appdata.arrSections[section]
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "activityCell", for: indexPath) as! TableViewCell
        let objPerson = self.appdata.arrCurrFriendsAndAllMitoUsers[indexPath.section][indexPath.row]
        Alamofire.request(objPerson.avatar).responseImage(completionHandler: { (response) in
            if let image = response.result.value {
                let circularImage = image.af_imageRoundedIntoCircle()
                DispatchQueue.main.async {
                    cell.img.image = circularImage
                }
            }
        })
        cell.name.text = "\(objPerson.firstName) \(objPerson.lastName)"
        cell.handle.text = "\(objPerson.email)"
        return cell
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
