//
//  ChooseAddressViewController.swift
//  Mito 1.0
//
//  Created by JJ Guo on 5/17/18.
//  Copyright © 2018 Benny Souriyadeth. All rights reserved.
//

import UIKit
import Alamofire
import GoogleMaps
import GooglePlaces
import GooglePlacePicker

class ChooseAddressViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
   
    
    @IBOutlet weak var tblviewAddress: UITableView!
    var appdata = AppData.shared

    override func viewDidLoad() {
        super.viewDidLoad()
        print(appdata.arrCurrUserAddresses.count)
        tblviewAddress.delegate = self
        tblviewAddress.dataSource = self
        fnLoadCurrUserAddresses()
        self.navigationController?.isNavigationBarHidden = false
        if boolSender {
             self.navigationItem.title = "Billing Address"
        } else {
             self.navigationItem.title = "Shipping Address"
        }
        let nibAddNewAddress = UINib(nibName: "AddAddressTableViewCell", bundle: nil)
        tblviewAddress.register(nibAddNewAddress, forCellReuseIdentifier: "AddNewAddressCell")
    }
    // overrides next screen's back button title
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        if segue.identifier == "DirectAcceptPackage" {
//
//        } else {
            let backItem = UIBarButtonItem()
            backItem.title = "Back"
            navigationItem.backBarButtonItem = backItem // This will show in the next view controller being pushed
//        }
    }
    
    func fnGoogleChooseAddress() {
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
                let strNickname = place.name
                let arrInformation = place.formattedAddress?.components(separatedBy: ", ")
                    .joined(separator: "\n")
                let arr: [String] = (arrInformation?.components(separatedBy: "\n"))!
                print(arr)
                
                var strStreet = ""
                var strCity = ""
                var strState = ""
                var intZIP = 0
                if arr.count > 3 {
                    let arrStateZIP = arr[2].components(separatedBy: " ")
                    strStreet = arr[0]
                    strCity = arr[1]
                    strState = arrStateZIP[0]
                    intZIP = Int(arrStateZIP[1])!
                } else {
                    strCity = arr[0]
                    let arrStateZIP = arr[1].components(separatedBy: " ")
                    strState = arrStateZIP[0]
                    intZIP = Int(arrStateZIP[1])!
                }
                
                //1. Create the alert controller.
                let alert = UIAlertController(title: "Nickname", message: "Enter an address nickname (Optional)", preferredStyle: .alert)
                
                //2. Add the text field. You can configure it however you need.
                alert.addTextField { (textField) in
                    textField.text = strNickname
                }
                
                // 3. Grab the value from the text field, and print it when the user clicks OK.
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak alert] (_) in
                    let textField = alert?.textFields![0] // Force unwrapping because we know it exists.
                    let strAlias = textField?.text!
//                    print("Text field: \(textField?.text)")
                    self.fnInsertNewAddress(strAddress: strStreet, strCity: strCity, strState: strState, intZIP: intZIP, strAlias: strAlias!)
                }))
                
                // 4. Present the alert.
                self.present(alert, animated: true, completion: nil)
                
            } else {
//                self.lblName.text = "No place selected"
//                self.lblAddress.text = ""
            }
        })
    }
    
    func fnInsertNewAddress(strAddress: String, strCity: String, strState: String, intZIP: Int, strAlias: String) {
        let urlInsertNewAddress = URL(string: "https://api.projectmito.io/v1/address/")
        let parameters: Parameters = [
            "streetAddress1": strAddress,
            "streetAddress2": "",
            "cityName": strCity,
            "stateName": strState,
            "zipCode": intZIP,
            "aliasName": strAlias
        ]
        let headers: HTTPHeaders = [
            "Authorization": UserDefaults.standard.object(forKey: "Authorization") as! String
        ]
        Alamofire.request(urlInsertNewAddress!, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers).validate().responseJSON { response in
            switch response.result {
            case .success:
                if let dictionary = response.result.value {
                    print(dictionary)
                    self.fnLoadCurrUserAddresses()
                }
                
            case .failure(let error):
                print("Insert new address error")
                print(error)
            }
        }
    }
    
    func fnAcceptOrDeclinePackage(strPackageAction: String, senderId: Int, orderId: Int, shippingAddressId: Int) {
        let urlAcceptOrDeclinePackage = URL(string: "https://api.projectmito.io/v1/package/")
        let parameters: Parameters = [
            "senderId": senderId,
            "orderId": orderId,
            "response": strPackageAction,
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
                if strPackageAction != "Denied" {
                    let alert = self.appdata.fnDisplayAlert(title: "Success!", message: "Packaged \(response)")
                    self.present(alert, animated: true, completion: nil)
                }
                
            case .failure(let error):
                print("Accept or decline package error")
                print(error)
            }
        }
    }
    
    func fnLoadCurrUserAddresses() {
        let urlGetMyAddresses = URL(string: "https://api.projectmito.io/v1/address/")
        let headers: HTTPHeaders = [
            "Authorization": UserDefaults.standard.object(forKey: "Authorization") as! String
        ]
        Alamofire.request(urlGetMyAddresses!, method: .get, encoding: JSONEncoding.default, headers: headers).validate().responseJSON { response in
            switch response.result {
            case .success:
                if let dictionary = response.data {
                    let decoder = JSONDecoder()
                    do {
                        self.appdata.arrCurrUserAddresses = try decoder.decode([Address].self, from: dictionary)
                    } catch let jsonErr {
                        print("Failed to decode: \(jsonErr)")
                    }
                }
                DispatchQueue.main.async {
                    self.tblviewAddress.reloadData()
                }
                
            case .failure(let error):
                print("Get all addresses error")
                print(error.localizedDescription)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Addresses"
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.appdata.arrCurrUserAddresses.count + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == self.appdata.arrCurrUserAddresses.count {
            var cell:AddAddressTableViewCell! = tblviewAddress.dequeueReusableCell(withIdentifier: "AddNewAddressCell", for:indexPath)as! AddAddressTableViewCell
            // This function actually loads the xib
            if cell == nil{
                let cellnib = Bundle.main.loadNibNamed("AddNewAddressCell", owner:self, options: nil)?.first as! AddAddressTableViewCell
                cell = cellnib
            }
//            cell.lblAddNewAddress.text = "Testing this"
            return cell
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: "AddressTableViewCell", for: indexPath) as! AddressTableViewCell
        let objAddress = self.appdata.arrCurrUserAddresses[indexPath.row]
        cell.strAddressNickname.text = objAddress.strAddressAlias!
        cell.strAddressStreet.text = "\(objAddress.strStreetAddress1!) \(objAddress.strStreetAddress2 ?? "")"
        cell.strCityStateZIP.text = "\(objAddress.strCityName!), \(objAddress.strStateName!) \(objAddress.strZipCode!)"
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == appdata.arrCurrUserAddresses.count {
            fnGoogleChooseAddress()
        } else {
            appdata.intAddressIdx = indexPath.row
            print(boolSender)
            if boolSender {
                performSegue(withIdentifier: "segChooseBillingAddressToReviewOrder", sender: self)
            } else {
                let address = appdata.arrCurrUserAddresses[indexPath.row]
                fnAcceptOrDeclinePackage(response: "Accepted", senderId: appdata.currPackage.intSenderID, orderId: appdata.currPackage.intOrderID, shippingAddressId: address.intAddressID!)
            }
        }
        tableView.deselectRow(at: indexPath, animated: true)
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
                    self.appdata.intAddressIdx = 0
//                    self.appdata.address = Address(intAddressID: 0, strAddressAlias: "", strCityName: "", strStateName: "", strStreetAddress1: "", strStreetAddress2: "", strZipCode: "")
                    self.appdata.personRecipient = Person(firstName: "FName", lastName: "LName", email: "", avatar: "", intUserID: 0, strUsername: "", intNumFriends: 0)
                }
                
            case .failure(let error):
                print("Accept or decline package error")
                print(error)
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
