//
//  PackageDetailsViewController.swift
//  Mito 1.0
//
//  Created by JJ Guo on 5/19/18.
//  Copyright © 2018 Benny Souriyadeth. All rights reserved.
//

import UIKit
import Alamofire

class PackageDetailsViewController: UIViewController {

    @IBOutlet weak var imgSender: UIImageView!
    @IBOutlet weak var strPackageSenderName: UILabel!
    @IBOutlet weak var lblMessage: UILabel!
    var appdata = AppData.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(intOrderID)
        if appdata.arrNotifications[intOrderID] as? Package != nil {
            let package = appdata.arrNotifications[intOrderID] as! Package
            fnRetrieveIncomingOrderDetails(intOrderID: package.intOrderID)
            appdata.fnDisplayImage(strImageURL: package.strPhotoUrl, img: imgSender, boolCircle: true)
            strPackageSenderName.text = "\(package.strUserFName) \(package.strUserLName)"
            lblMessage.text = package.strOrderMessage
            fnRetrieveIncomingOrderDetails(intOrderID: intOrderID)
        }
    }
    
    func fnRetrieveIncomingOrderDetails(intOrderID: Int) {
        let urlRetrieveIncomingOrderDetails = URL(string: "https://api.projectmito.io/v1/order/products")
        let parameters: Parameters = [
            "orderId": intOrderID
        ]
        let headers: HTTPHeaders = [
            "Authorization": UserDefaults.standard.object(forKey: "Authorization") as! String
        ]
        Alamofire.request(urlRetrieveIncomingOrderDetails!, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers).validate().responseJSON { response in
            switch response.result {
            case .success:
                if let dictionary = response.result.value {
                    print(dictionary)
                    print("\(response): Successful")
                }
                
            case .failure(let error):
                print("Can't get order details")
                print(error)
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
