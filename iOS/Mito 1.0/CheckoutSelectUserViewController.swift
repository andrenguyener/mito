//
//  CheckoutSelectUserViewController.swift
//  Mito 1.0
//
//  Created by Benny on 4/18/18.
//  Copyright © 2018 Benny Souriyadeth. All rights reserved.
//

import UIKit
import Alamofire

var boolSender = true

class CheckoutSelectUserViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, UITextFieldDelegate {
    
    @IBOutlet weak var tblviewPeople: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    @IBOutlet weak var tblviewAddress: UITableView!
    @IBOutlet weak var lblAddressNickname: UILabel!
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tblviewAddress != nil {
            return self.appdata.arrCurrUserAddresses.count
        }
        return self.appdata.arrCurrFriendsAndAllMitoUsers[section].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tblviewAddress != nil {
            let cell = tableView.dequeueReusableCell(withIdentifier: "AddressTableViewCell", for: indexPath) as! AddressTableViewCell
            let objAddress = self.appdata.arrCurrUserAddresses[indexPath.row]
            cell.strAddressNickname.text = objAddress.strAddressAlias
            cell.strAddressStreet.text = "\(objAddress.strStreetAddress1) \(objAddress.strStreetAddress2)"
            cell.strCityStateZIP.text = "\(objAddress.strCityName), \(objAddress.strStateName) \(objAddress.strZipCode)"
            return cell
        }
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
        if tblviewAddress != nil {
            return "Addresses"
        }
        return self.appdata.arrSections[section]
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if tblviewAddress != nil {
            return 1
        }
        return self.appdata.arrCurrFriendsAndAllMitoUsers.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tblviewAddress != nil {
            appdata.address = appdata.arrCurrUserAddresses[indexPath.row]
            if boolSender {
                performSegue(withIdentifier: "ChooseAddressToCheckout", sender: self)
            } else {
                let package = appdata.arrCurrUserPackages[intOrderID]
                appdata.address = appdata.arrCurrUserAddresses[indexPath.row]
                fnAcceptOrDeclinePackage(response: "Accepted", senderId: package.intSenderID, orderId: package.intOrderID, shippingAddressId: appdata.arrCurrUserAddresses[indexPath.row].intAddressID)
            }
        } else {
            appdata.personRecipient = appdata.arrCurrFriendsAndAllMitoUsers[indexPath.section][indexPath.row]
            performSegue(withIdentifier: "choosePersonToEditCheckout", sender: self)
        }
    }
    
    func fnAcceptOrDeclinePackage(response: String, senderId: Int, orderId: Int, shippingAddressId: Int) {
        let urlAcceptOrDeclinePackage = URL(string: "https://api.projectmito.io/v1/package/")
        let parameters: Parameters = [
            "senderId": senderId,
            "orderId": orderId,
            "response": response,
            "shippingAddressId": shippingAddressId
        ]
        let headers: HTTPHeaders = [
            "Authorization": UserDefaults.standard.object(forKey: "Authorization") as! String
        ]
        Alamofire.request(urlAcceptOrDeclinePackage!, method: .patch, parameters: parameters, encoding: JSONEncoding.default, headers: headers).validate().responseJSON { response in
            switch response.result {
            case .success:
                if let dictionary = response.result.value {
                    print(dictionary)
                    print("\(response): Successful")
                }
                DispatchQueue.main.async {
                    self.performSegue(withIdentifier: "CompleteChooseReceivingAddress", sender: self)
                    let alert = self.appdata.fnDisplayAlert(title: "Success", message: "Package accepted!")
                    self.present(alert, animated: true, completion: nil)
                }
                
            case .failure(let error):
                print("Accept or decline package error")
                print(error)
            }
        }
    }
    
    var appdata = AppData.shared
    
    @IBOutlet weak var imgRecipientProfile: RoundedImage!
    @IBOutlet weak var strRecipientName: UILabel!
    @IBOutlet weak var textviewWriteMessage: UITextView!
    
    
    @IBOutlet weak var lblCreditCardNumber: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        fnLoadCurrUserAddresses()
        if tblviewPeople != nil {
            tblviewPeople.delegate = self
            tblviewPeople.dataSource = self
            tblviewPeople.rowHeight = 106
            searchBar.delegate = self
            appdata.fnLoadFriendsAndAllUsers(tableview: tblviewPeople)
        } else if tblviewAddress != nil {
            tblviewAddress.delegate = self
            tblviewAddress.dataSource = self
            tblviewAddress.rowHeight = 106
        } else if lblRecipient != nil {
            lblRecipient.text = "\(appdata.personRecipient.firstName) \(appdata.personRecipient.lastName)"
            appdata.fnDisplaySimpleImage(strImageURL: appdata.personRecipient.avatar, img: imgRecipientImage)
//            let urlPersonImage = URL(string: "\(appdata.personRecipient.avatar)")
//            let defaultURL = URL(string: "https://scontent.fsea1-1.fna.fbcdn.net/v/t31.0-8/17621927_1373277742718305_6317412440813490485_o.jpg?oh=4689a54bc23bc4969eacad74b6126fea&oe=5B460897")
//            if let data = try? Data(contentsOf: urlPersonImage!) {
//                imgRecipientImage.image = UIImage(data: data)!
//            } else if let data = try? Data(contentsOf: defaultURL!){
//                imgRecipientImage.image = UIImage(data: data)
//            }
            lblAddressNickname.text = appdata.address.strAddressAlias
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
    
    @IBOutlet weak var lblRecipient: UILabel!
    @IBOutlet weak var imgRecipientImage: RoundedImage!
    
    @IBAction func btnContinueToOrderSummary(_ sender: Any) {
        performSegue(withIdentifier: "editCheckoutToOrderSummary", sender: self)
    }
    
    @IBAction func btnAddNewPaymentMethod(_ sender: Any) {
        performSegue(withIdentifier: "editCheckoutToPaymentMethod", sender: self)
    }
    
    @IBAction func btnSelectExistingAddress(_ sender: Any) {
        performSegue(withIdentifier: "editCheckoutToChooseAddress", sender: self)
    }
    
    @IBAction func btnChoosePersonToEditCheckout(_ sender: Any) {
        performSegue(withIdentifier: "choosePersonToEditCheckout", sender: self)
    }
    
    // add textfield as delegate of viewcontroller first
    // Start Editing The Text Field
    func textFieldDidBeginEditing(_ textField: UITextField) {
        moveTextField(textField, moveDistance: -250, up: true)
    }
    
    // Finish Editing The Text Field
    func textFieldDidEndEditing(_ textField: UITextField) {
        moveTextField(textField, moveDistance: -250, up: false)
    }
    
    // Hide the keyboard when the return key pressed
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    // Move the text field in a pretty animation!
    func moveTextField(_ textField: UITextField, moveDistance: Int, up: Bool) {
        let moveDuration = 0.3
        let movement: CGFloat = CGFloat(up ? moveDistance : -moveDistance)
        
        UIView.beginAnimations("animateTextField", context: nil)
        UIView.setAnimationBeginsFromCurrentState(true)
        UIView.setAnimationDuration(moveDuration)
        self.view.frame = self.view.frame.offsetBy(dx: 0, dy: movement)
        UIView.commitAnimations()
    }
}
