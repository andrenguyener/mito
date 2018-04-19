//
//  CheckoutSelectUserViewController.swift
//  Mito 1.0
//
//  Created by Benny on 4/18/18.
//  Copyright © 2018 Benny Souriyadeth. All rights reserved.
//

import UIKit
import Alamofire

class CheckoutSelectUserViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
    
    @IBOutlet weak var tblviewPeople: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.appdata.arrCurrFriendsAndAllMitoUsers[section].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
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
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return self.appdata.arrSections[section]
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.appdata.arrCurrFriendsAndAllMitoUsers.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        appdata.personRecipient = appdata.arrCurrFriendsAndAllMitoUsers[indexPath.section][indexPath.row]
        performSegue(withIdentifier: "choosePersonToEditCheckout", sender: self)
    }
    
    var appdata = AppData.shared
    var urlPeopleCall = URL(string: "https://api.projectmito.io/v1/friend/")
    var urlAllUserCall = URL(string: "https://api.projectmito.io/v1/users/all")
    
    @IBOutlet weak var lblCreditCardNumber: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        if tblviewPeople != nil {
            tblviewPeople.delegate = self
            tblviewPeople.dataSource = self
            tblviewPeople.rowHeight = 106
            searchBar.delegate = self
            fnLoadFriendsAndAllUsers()
        }
    }
    
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
                    print(self.appdata.arrFriends.count)
                    self.appdata.arrFriendsAndAllMitoUsers.append(self.appdata.arrFriends)
                    DispatchQueue.main.async {
                        self.appdata.arrCurrFriendsAndAllMitoUsers = self.appdata.arrFriendsAndAllMitoUsers
                        self.tblviewPeople.reloadData()
                    }
                }
                
            case .failure(let error):
                print("Get all users error")
                print(error)
            }
        }
    }
    
    // Once text changes, filter friends and all users, then merge into arrCurrFriendsAndAllMitoUsers
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
    
    @IBAction func btnEditCheckoutToCart(_ sender: Any) {
        performSegue(withIdentifier: "editCheckoutToCart", sender: self)
    }
    
    @IBAction func btnEditCheckoutToChooseFriend(_ sender: Any) {
        performSegue(withIdentifier: "editCheckoutToChooseFriend", sender: self)
//        fnLoadFriendsAndAllUsers()
    }
    @IBAction func btnPaymentMethodToEditCheckout(_ sender: Any) {
        appdata.strCardNumber = lblCreditCardNumber.text!
        performSegue(withIdentifier: "paymentMethodToEditCheckout", sender: self)
    }
    
    
    @IBAction func btnCancelAddPaymentMethod (_ sender: Any) {
        performSegue(withIdentifier: "paymentMethodToEditCheckout", sender: self)
    }
    
    
    @IBAction func btnContinueToOrderSummary(_ sender: Any) {
        performSegue(withIdentifier: "editCheckoutToOrderSummary", sender: self)
    }
    
    @IBAction func btnAddNewPaymentMethod(_ sender: Any) {
        performSegue(withIdentifier: "editCheckoutToPaymentMethod", sender: self)
    }
    
    
    @IBAction func btnChoosePersonToEditCheckout(_ sender: Any) {
        performSegue(withIdentifier: "choosePersonToEditCheckout", sender: self)
    }
}
