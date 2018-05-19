//
//  ChooseAddressViewController.swift
//  Mito 1.0
//
//  Created by JJ Guo on 5/17/18.
//  Copyright © 2018 Benny Souriyadeth. All rights reserved.
//

import UIKit
import Alamofire

class ChooseAddressViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
   
    
    @IBOutlet weak var tblviewAddress: UITableView!
    var appdata = AppData.shared

    override func viewDidLoad() {
        super.viewDidLoad()
        print(appdata.arrCurrUserAddresses.count)
        tblviewAddress.delegate = self
        tblviewAddress.dataSource = self
        tblviewAddress.rowHeight = 106
        fnLoadCurrUserAddresses()
        if boolSender {
             self.navigationItem.title = "Select Billing Address"
        } else {
             self.navigationItem.title = "Select Shipping Address"
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
                    if (self.appdata.arrCurrUserAddresses.count > 0) {
                        print("Load Current User Addresses: \(self.appdata.arrCurrUserAddresses[self.appdata.arrCurrUserAddresses.count - 1].strAddressAlias)")
                    }
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
        return self.appdata.arrCurrUserAddresses.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AddressTableViewCell", for: indexPath) as! AddressTableViewCell
        let objAddress = self.appdata.arrCurrUserAddresses[indexPath.row]
        cell.strAddressNickname.text = objAddress.strAddressAlias!
        cell.strAddressStreet.text = "\(objAddress.strStreetAddress1!) \(objAddress.strStreetAddress2 ?? "")"
        cell.strCityStateZIP.text = "\(objAddress.strCityName!), \(objAddress.strStateName!) \(objAddress.strZipCode!)"
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        appdata.address = appdata.arrCurrUserAddresses[indexPath.row]
        print(boolSender)
        if boolSender {
            performSegue(withIdentifier: "segChooseBillingAddressToReviewOrder", sender: self)
        } else {
            appdata.address = appdata.arrCurrUserAddresses[indexPath.row]
            fnAcceptOrDeclinePackage(response: "Accepted", senderId: appdata.currPackage.intSenderID, orderId: appdata.currPackage.intOrderID, shippingAddressId: appdata.arrCurrUserAddresses[indexPath.row].intAddressID!)
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
                    self.appdata.address = Address(intAddressID: 0, strAddressAlias: "", strCityName: "", strStateName: "", strStreetAddress1: "", strStreetAddress2: "", strZipCode: "")
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
