//
//  CheckoutSelectUserViewController.swift
//  Mito 1.0
//
//  Created by Benny on 4/18/18.
//  Copyright © 2018 Benny Souriyadeth. All rights reserved.
//

import UIKit
import Alamofire
import GoogleMaps
import GooglePlaces
import GooglePlacePicker

var boolSender = true

class CheckoutSelectUserViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, UITextFieldDelegate, UITextViewDelegate {
    
    @IBOutlet weak var tblviewPeople: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    @IBOutlet weak var tblviewAddress: UITableView!
    @IBOutlet weak var lblAddressNickname: UILabel!
    
    var placesClient: GMSPlacesClient!
    
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
        let defaultURL = URL(string: "https://t3.ftcdn.net/jpg/00/64/67/80/240_F_64678017_zUpiZFjj04cnLri7oADnyMH0XBYyQghG.jpg")
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
            print(boolSender)
            if boolSender {
                performSegue(withIdentifier: "ChooseAddressToCheckout", sender: self)
            } else {
                appdata.address = appdata.arrCurrUserAddresses[indexPath.row]
                fnAcceptOrDeclinePackage(response: "Accepted", senderId: appdata.currPackage.intSenderID, orderId: appdata.currPackage.intOrderID, shippingAddressId: appdata.arrCurrUserAddresses[indexPath.row].intAddressID)
            }
        } else if tblviewPeople != nil {
            appdata.personRecipient = appdata.arrCurrFriendsAndAllMitoUsers[indexPath.section][indexPath.row]
            self.performSegue(withIdentifier: "choosePersonToEditCheckout", sender: self)
        } else {
            appdata.personRecipient = appdata.arrCurrFriendsAndAllMitoUsers[indexPath.section][indexPath.row]
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
                self.appdata.personRecipient = Person(firstName: "FName", lastName: "LName", email: "", avatar: "dd", intUserID: 0, strUsername: "", intNumFriends: 0, dateRequested: Date.distantPast)
                DispatchQueue.main.async {
                    let alertController = UIAlertController(title: "Success!", message: "Your package has been confirmed!", preferredStyle: .alert)
                    alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
                        self.performSegue(withIdentifier: "CompleteChooseReceivingAddress", sender: self)
                    }))
                    self.present(alertController, animated: true, completion: nil)
                }
                
            case .failure(let error):
                print("Accept or decline package error")
                print(error)
            }
        }
    }
    
    @IBAction func btnInsertNewAddress(_ sender: Any) {
        fnLoadCurrUserAddresses()
        fnInsertNewAddress()
    }
    
    func fnInsertNewAddress() {
        let center = CLLocationCoordinate2D(latitude: 37.788204, longitude: -122.411937)
        let northEast = CLLocationCoordinate2D(latitude: center.latitude + 0.001, longitude: center.longitude + 0.001)
        let southWest = CLLocationCoordinate2D(latitude: center.latitude - 0.001, longitude: center.longitude - 0.001)
        let viewport = GMSCoordinateBounds(coordinate: northEast, coordinate: southWest)
        let config = GMSPlacePickerConfig(viewport: viewport)
        let placePicker = GMSPlacePicker(config: config)
        
        placePicker.pickPlace(callback: {(place, error) -> Void in
            if let error = error {
                print("Pick Place error: \(error.localizedDescription)")
                return
            }
            
            if let place = place {
                let strFormattedAddress = place.formattedAddress?.components(separatedBy: ", ")
                    .joined(separator: "\n")
                let arrAddress = strFormattedAddress?.components(separatedBy: "\n")
                let strStreet = arrAddress![0]
                let strCity = arrAddress![1]
                let strStateZip = arrAddress![2]
                var strState = ""
                var strZip = ""
                if strStateZip.index(of: " ") != nil {
                    strState = (strStateZip as NSString).substring(to: 2)
                    strZip = (strStateZip as NSString).substring(from: 3)
                }
                let strCountry = arrAddress![(arrAddress?.count)! - 1]
                let strAlias = place.name
                self.fnAddNewAddress(strStreet: strStreet, strCity: strCity, strState: strState, strStateZip: strZip, strAlias: strAlias)
                DispatchQueue.main.async {
                    self.tblviewAddress.reloadData()
                }
            } else {
                print("No place selected")
            }
        })
    }
    
    func fnLoadCurrUserAddresses() {
        let urlGetMyAddresses = URL(string: "https://api.projectmito.io/v1/address/")
        let headers: HTTPHeaders = [
            "Authorization": UserDefaults.standard.object(forKey: "Authorization") as! String
        ]
        Alamofire.request(urlGetMyAddresses!, method: .get, encoding: JSONEncoding.default, headers: headers).validate().responseJSON { response in
            switch response.result {
            case .success:
                if let dictionary = response.result.value {
                    self.appdata.arrCurrUserAddresses.removeAll()
                    let arrAddresses = dictionary as! NSArray
                    for elem in arrAddresses {
                        let objAddress = elem as! NSDictionary
                        print(objAddress)
                        var strAddress2 = ""
                        if objAddress["StreetAddress2"] != nil {
                            strAddress2 = objAddress["StreetAddress2"] as! String
                        }
                        let objAddressObject = Address(intAddressID: objAddress["AddressId"] as! Int, strAddressAlias: objAddress["Alias"] as! String, strCityName: objAddress["CityName"] as! String, strStateName: objAddress["StateName"] as! String, strStreetAddress1: objAddress["StreetAddress"] as! String, strStreetAddress2: strAddress2, strZipCode: objAddress["ZipCode"] as! String)
                        print("\(objAddress["Alias"] as! String) \(String(describing: objAddress["AddressId"]))")
                        self.appdata.arrCurrUserAddresses.append(objAddressObject)
                    }
                    print("This user has \(self.appdata.arrCurrUserAddresses.count) addresses")
                }
                DispatchQueue.main.async {
                    if (self.appdata.arrCurrUserAddresses.count > 0) {
                        print("Load Current User Addresses: \(self.appdata.arrCurrUserAddresses[self.appdata.arrCurrUserAddresses.count - 1].strAddressAlias)")
                    }
//                    self.appdata.address = self.appdata.arrCurrUserAddresses[self.appdata.arrCurrUserAddresses.count - 1]
                    self.tblviewAddress.reloadData()
                }
                
            case .failure(let error):
                print("Get all addresses error")
                print(error.localizedDescription)
            }
        }
    }
    
    func fnAddNewAddress(strStreet: String, strCity: String, strState: String, strStateZip: String, strAlias: String) {
        let parameters: Parameters = [
            "streetAddress1": strStreet,
            "cityName": strCity,
            "zipCode": strStateZip,
            "stateName": strState,
            "aliasName": strAlias
        ]
        let headers: HTTPHeaders = [
            "Authorization": UserDefaults.standard.object(forKey: "Authorization") as! String
        ]
        Alamofire.request("https://api.projectmito.io/v1/address", method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers).validate().responseJSON { response in
            switch response.result {
            case .success:
                
                if let dictionary = response.result.value {
                    print("JSON: \(dictionary)") // serialized json response
                    DispatchQueue.main.async {
//                        self.appdata.address = self.appdata.arrCurrUserAddresses[self.appdata.arrCurrUserAddresses.count - 1]
                        self.performSegue(withIdentifier: "ChooseAddressToCheckout", sender: self)
                    }
                }
                
            case .failure(let error):
                print(error)
            }
        }
    }
    
    
    var appdata = AppData.shared
    
    @IBOutlet weak var imgRecipientProfile: RoundedImage!
    @IBOutlet weak var strRecipientName: UILabel!
    @IBOutlet weak var textviewWriteMessage: UITextView!
    
    @IBAction func btnConfirmMessage(_ sender: Any) {
        appdata.strOrderMessage = textviewWriteMessage.text
    }
    
    @IBAction func btnDoneTypingMessage(_ sender: Any) {
        appdata.strOrderMessage = textviewWriteMessage.text
        performSegue(withIdentifier: "TypeMessageToCheckout", sender: self)
    }
    
    
    @IBOutlet weak var lblCreditCardNumber: UITextField!
    @IBOutlet weak var lblChooseAddressHeading: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if tblviewPeople != nil {
            tblviewPeople.delegate = self
            tblviewPeople.dataSource = self
            tblviewPeople.rowHeight = 106
            searchBar.delegate = self
            appdata.fnLoadFriendsAndAllUsers(tableview: tblviewPeople)
        } else if tblviewAddress != nil {
            print(appdata.arrCurrUserAddresses.count)
            tblviewAddress.delegate = self
            tblviewAddress.dataSource = self
            tblviewAddress.rowHeight = 106
            fnLoadCurrUserAddresses()
            if boolSender {
//                lblChooseAddressHeading.text = "Select Billing Address"
            } else {
//                lblChooseAddressHeading.text = "Select Shipping Address"
            }
        } else if lblRecipient != nil {
            lblRecipient.text = "\(appdata.personRecipient.firstName) \(appdata.personRecipient.lastName)"
            appdata.fnDisplaySimpleImage(strImageURL: appdata.personRecipient.avatar, img: imgRecipientImage)
            lblAddressNickname.text = appdata.address.strAddressAlias
            if appdata.strCardNumber.count > 0 {
                let stars = String(repeating:"*", count:12)
                let last4 = String(appdata.strCardNumber.suffix(4))
                lblCreditCardNumberCheckoutProcess.text = "\(stars)\(last4)"
            }
        } else if imgRecipientProfile != nil {
            textviewWriteMessage.keyboardDismissMode = .onDrag
            appdata.fnDisplaySimpleImage(strImageURL: appdata.personRecipient.avatar, img: imgRecipientProfile)
            strRecipientName.text = "\(appdata.personRecipient.firstName) \(appdata.personRecipient.lastName)"
            textviewWriteMessage.text = "What's it for?"
        }
        if textviewWriteMessage != nil {
            textviewWriteMessage.delegate = self
        }
    }
    
    func textViewDidChange(_ textView: UITextView) {
        if textviewWriteMessage != nil {
            if textviewWriteMessage.text.count == 0 {
                textviewWriteMessage.text = "What's it for?"
                textviewWriteMessage.textColor = UIColor.gray
            } else if textviewWriteMessage.text.count > 0 {
                textviewWriteMessage.textColor = UIColor.black
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
    
    @IBOutlet weak var lblCreditCardNumberCheckoutProcess: UILabel!
    
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
