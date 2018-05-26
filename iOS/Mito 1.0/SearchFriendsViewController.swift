//
//  SearchFriendsViewController.swift
//  Mito 1.0
//
//  Created by JJ Guo on 5/24/18.
//  Copyright © 2018 Benny Souriyadeth. All rights reserved.
//

import UIKit

class SearchFriendsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
    
    @IBOutlet weak var peopleTableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
//    @IBOutlet weak var swirlSearchImg: UIImageView!
    @IBOutlet weak var imgCurrentRecipient: UIImageView!
    var appdata = AppData.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.placeholder = "Search for a friend"
        searchBar.delegate = self
        searchBar.returnKeyType = UIReturnKeyType.done
        searchBar.text = strSearchQuery
        appdata.fnLoadFriendsAndAllUsers(tableview: peopleTableView)
        peopleTableView.delegate = self
        peopleTableView.dataSource = self
        peopleTableView.rowHeight = 76
        peopleTableView.keyboardDismissMode = .onDrag
        let data = UserDefaults.standard.object(forKey: "UserInfo") as! NSDictionary
        var strPhotoUrl = data["profileImageString"] as! String
        if strPhotoUrl.count < 100 {
            strPhotoUrl = data["photoURL"] as! String
        }
        appdata.fnDisplayImage(strImageURL: strPhotoUrl, img: imgCurrentRecipient, boolCircle: true)
        imgCurrentRecipient.isUserInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.fnGoToSettings))
        imgCurrentRecipient.addGestureRecognizer(tapGesture)
    }
    
    override func viewWillAppear(_ animated: Bool) {
//        appdata.fnLoadFriendsAndAllUsers(tableview: peopleTableView)
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    @objc func fnGoToSettings() {
        print("Tapped")
        performSegue(withIdentifier: "segSearchFriendToMeView", sender: self)
    }
    
    @IBAction func btnCartPressed(_ sender: Any) {
        performSegue(withIdentifier: "segSearchFriendToCart", sender: self)
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
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
    
    func filterFriends(text: String) {
        appdata.arrCurrFriends = appdata.arrFriends.filter({ person -> Bool in
            return person.firstName.lowercased().contains(text.lowercased().trimmingCharacters(in: .whitespacesAndNewlines))
        })
    }
    
    func filterAllUsers(text: String) {
        appdata.arrCurrAllUsers = appdata.arrAllUsers.filter({ person -> Bool in
            return person.firstName.lowercased().contains(text.lowercased().trimmingCharacters(in: .whitespacesAndNewlines))
        })
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let data = UserDefaults.standard.object(forKey: "UserInfo") as! NSDictionary
        let intNumFriends = data["NumFriends"] as? Int
        if intNumFriends == 0 {
            return min(self.appdata.arrCurrAllUsers.count, 10)
        } else {
            return min(self.appdata.arrCurrFriendsAndAllMitoUsers[section].count, 10)
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let data = UserDefaults.standard.object(forKey: "UserInfo") as! NSDictionary
        let intNumFriends = data["NumFriends"] as? Int
        if intNumFriends == 0 {
            return "Other people on Mito"
        } else {
            return self.appdata.arrSections[section]
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        let data = UserDefaults.standard.object(forKey: "UserInfo") as! NSDictionary
        let intNumFriends = data["NumFriends"] as? Int
        if intNumFriends == 0 {
            return 1
        } else {
            return self.appdata.arrCurrFriendsAndAllMitoUsers.count
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        myIndex = indexPath.row
        mySection = indexPath.section
        if appdata.arrCurrFriendsAndAllMitoUsers[mySection].count == 0 {
            mySection = 1
        }
        appdata.personToView = appdata.arrCurrFriendsAndAllMitoUsers[mySection][myIndex]
        performSegue(withIdentifier: "segSeeMitoProfile", sender: self)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        print("Chose people")
        print("People indexPath.row: \(indexPath.row)")
        let cell = tableView.dequeueReusableCell(withIdentifier: "activityCell", for: indexPath) as! TableViewCell
        let data = UserDefaults.standard.object(forKey: "UserInfo") as! NSDictionary
        let intNumFriends = data["NumFriends"] as? Int
        if intNumFriends == 0 {
            let objPerson = self.appdata.arrCurrAllUsers[indexPath.row]
            return fnLoadPersonCell(cell: cell, objPerson: objPerson)
        } else {
            let objPerson = self.appdata.arrCurrFriendsAndAllMitoUsers[indexPath.section][indexPath.row]
            return fnLoadPersonCell(cell: cell, objPerson: objPerson)
        }
    }
    
    func fnLoadPersonCell(cell: TableViewCell, objPerson: Person) -> TableViewCell {
        appdata.fnDisplayImage(strImageURL: objPerson.avatar, img: cell.img, boolCircle: true)
        cell.name.text = "\(objPerson.firstName) \(objPerson.lastName)"
        cell.handle.text = "@\(objPerson.strUsername)"
        return cell
    }

}
