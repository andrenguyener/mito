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
            // lblChooseAddressHeading.text = "Select Billing Address"
        } else {
            // lblChooseAddressHeading.text = "Select Shipping Address"
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

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
