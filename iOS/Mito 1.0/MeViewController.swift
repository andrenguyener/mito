//
//  MeViewController.swift
//  Mito 1.0
//
//  Created by Benny on 2/25/18.
//  Copyright © 2018 Benny Souriyadeth. All rights reserved.
//

import UIKit
import Alamofire
import CoreGraphics
import GoogleMaps
import GooglePlaces
import GooglePlacePicker
import PayCardsRecognizer

class MeViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate, CLLocationManagerDelegate, PayCardsRecognizerPlatformDelegate {
    
    // https://developer.apple.com/documentation/corelocation/choosing_the_authorization_level_for_location_services/requesting_always_authorization
    var appdata = AppData.shared
    
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblAddress: UILabel!
    
    var placesClient: GMSPlacesClient!
    let locationManager = CLLocationManager()
    
    var recognizer: PayCardsRecognizer!
    
    @IBAction func btnScanCreditCard(_ sender: Any) {
//        recognizer.startCamera()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        recognizer.startCamera()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        recognizer.stopCamera()
    }
    
    func payCardsRecognizer(_ payCardsRecognizer: PayCardsRecognizer, didRecognize result: PayCardsRecognizerResult) {
//        result.recognizedNumber // Card number
//        result.recognizedHolderName // Card holder
//        result.recognizedExpireDateMonth // Expire month
//        result.recognizedExpireDateYear // Expire year
        print("Card Number: \(result.recognizedNumber)")
        print("Holder name: \(result.recognizedHolderName)")
        print("Expire Date Month: \(result.recognizedExpireDateMonth)")
        print("Expire Date Year: \(result.recognizedExpireDateYear)")
    }
    

    @IBAction func fnPickPlace(_ sender: Any) {
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
                self.lblName.text = place.name
                self.lblAddress.text = place.formattedAddress?.components(separatedBy: ", ")
                    .joined(separator: "\n")
            } else {
                self.lblName.text = "No place selected"
                self.lblAddress.text = ""
            }
        })
    }
    
    func fnEnableLocationServices() {
//        locationManager.delegate = self
//
//        switch CLLocationManager.authorizationStatus() {
//        case .notDetermined:
//            // Request when-in-use authorization initially
//            locationManager.requestWhenInUseAuthorization()
//            break
//
//        case .restricted, .denied:
//            // Disable location features
//            disableMyLocationBasedFeatures()
//            break
//
//        case .authorizedWhenInUse:
//            // Enable basic location features
//            enableMyWhenInUseFeatures()
//            break
//
//        case .authorizedAlways:
//            // Enable any of your app's location features
//            enableMyAlwaysFeatures()
//            break
//        }
    }
    
    func escalateLocationServiceAuthorization() {
        // Escalate only when the authorization is set to when-in-use
        if CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
            locationManager.requestAlwaysAuthorization()
        }
    }
    
    
    @IBAction func fnGetCurrentLocation(_ sender: Any) {
        escalateLocationServiceAuthorization()
        locationManager.requestAlwaysAuthorization()
        placesClient.currentPlace(callback: { (placeLikelihoodList, error) -> Void in
            if let error = error {
                print("Pick Place error: \(error.localizedDescription)")
                return
            }
            
            if let placeLikelihoodList = placeLikelihoodList {
                for likelihood in placeLikelihoodList.likelihoods {
                    let place = likelihood.place
                    print("Current Place name \(place.name) at likelihood \(likelihood.likelihood)")
                    print("Current Place address \(place.formattedAddress)")
                    print("Current Place attributions \(place.attributions)")
                    print("Current PlaceID \(place.placeID)")
                }
            }
        })
//
//        placesClient.currentPlace(callback: { (placeLikelihoodList, error) -> Void in
//            if let error = error {
//                print("Pick Place error: \(error.localizedDescription)")
//                return
//            }
//
//            self.lblName.text = "No current place"
//            self.lblAddress.text = ""
//
//            if let placeLikelihoodList = placeLikelihoodList {
//                let place = placeLikelihoodList.likelihoods.first?.place
//                if let place = place {
//                    self.lblName.text = place.name
//                    self.lblAddress.text = place.formattedAddress?.components(separatedBy: ", ")
//                        .joined(separator: "\n")
//                    print(self.lblAddress.text)
//                }
//            }
//        })
    }
    
    
    @IBOutlet weak var userID: UILabel!
    @IBOutlet weak var userEmail: UILabel!
    @IBOutlet weak var username: UILabel!
    @IBOutlet weak var userFname: UILabel!
    @IBOutlet weak var userLname: UILabel!
    @IBOutlet weak var userDOB: UILabel!
    @IBOutlet weak var photoURL: UILabel!
    @IBOutlet weak var imgProfilePic: UIImageView!
    
    @IBAction func meToSettings(_ sender: Any) {
        performSegue(withIdentifier: "meToSettings", sender: self)
    }
    
    @IBAction func loadCurrentUserAddresses(_ sender: Any) {
        fnLoadCurrUserAddresses()
    }
    @IBAction func loadCurrentOrders(_ sender: Any) {
        fnGetCurrentOrders()
    }
    @IBAction func fnInsertNewAddress(_ sender: Any) {
        fnInsertNewAddress()
    }
    @IBAction func fnAcceptOrDeclinePackage(_ sender: Any) {
        fnAcceptOrDeclinePackage()
    }
    @IBAction func fnGetPendingPackages(_ sender: Any) {
        fnGetPendingPackages()
    }
    @IBAction func fnGetIncomingPackages(_ sender: Any) {
        fnGetIncomingPackages2()
    }
    @IBAction func btnChangePassword(_ sender: Any) {
        fnChangePassword()
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        placesClient = GMSPlacesClient.shared()
        recognizer = PayCardsRecognizer(delegate: self, resultMode: .sync, container: self.view, frameColor: .green)

        if UserDefaults.standard.object(forKey: "UserInfo") != nil {
            let data = UserDefaults.standard.object(forKey: "UserInfo") as! NSDictionary
            appdata.fnDisplaySimpleImage(strImageURL: data["photoURL"] as! String, img: imgProfilePic)
            self.userID.text = data["userId"] as? String
            self.userEmail.text = data["userEmail"] as? String
            self.username.text = data["username"] as? String
            // Prevent showing Optional("")
            self.userFname.text = "\(String(describing: data["userFname"] as? String)) \(String(describing: data["userLname"]))"
            self.userLname.text = data["userLname"] as? String
            self.userDOB.text = data["userDOB"] as? String
            self.photoURL.text = data["photoURL"] as? String
            locationManager.delegate = self
//            print(data["userId"] as! String)
        }
    }
    
    @IBAction func btnEditProfilePicture(_ sender: Any) {
        fnImportImage()
    }
    
    func fnImportImage() {
        let image = UIImagePickerController()
        image.delegate = self
        image.sourceType = UIImagePickerControllerSourceType.photoLibrary
        image.allowsEditing = false
        self.present(image, animated: true)
    }
    
    func fnCropImage(image: UIImage) -> CGImage {
        let crop = CGRect(x: image.size.width / 2, y: image.size.height / 2, width: 200, height: 200)
        let imageRef2 = image.cgImage!.cropping(to: crop)
        return imageRef2!
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            print(image)
            let cgImage = fnCropImage(image: image)
            imgProfilePic.image = UIImage(cgImage: cgImage)
        } else {
            print("Error")
        }
        self.dismiss(animated: true, completion: nil)
    }
    
    func fnGetIncomingPackages2() {
        let urlGetIncomingPackage = URL(string: "https://api.projectmito.io/v1/package")
        let parameters: Parameters = [
            "type": "Incoming"
        ]
        let headers: HTTPHeaders = [
            "Authorization": UserDefaults.standard.object(forKey: "Authorization") as! String
        ]
        Alamofire.request(urlGetIncomingPackage!, method: .post, encoding: JSONEncoding.default, headers: headers).validate().responseJSON { response in
            switch response.result {
            case .success:
                if let dictionary = response.result.value {
                    print(dictionary)
                    print("Hello")
                }
                
            case .failure(let error):
                print("Get incoming packages error")
                print(error)
            }
        }
    }
    
    func fnAcceptOrDeclinePackage() {
        let urlAcceptOrDeclinePackage = URL(string: "https://api.projectmito.io/v1/package/")
        let parameters: Parameters = [
            "senderId": 7,
            "orderId": 19,
            "response": "Accepted",
            "shippingAddressId": 24
        ]
        let headers: HTTPHeaders = [
            "Authorization": UserDefaults.standard.object(forKey: "Authorization") as! String
        ]
        Alamofire.request(urlAcceptOrDeclinePackage!, method: .patch, parameters: parameters, encoding: JSONEncoding.default, headers: headers).validate().responseJSON { response in
            switch response.result {
            case .success:
                if let dictionary = response.result.value {
                    print(dictionary)
                }
                
            case .failure(let error):
                print("Accept or decline package error")
                print(error)
            }
        }
    }
    
    func fnInsertNewAddress() {
        let urlInsertNewAddress = URL(string: "https://api.projectmito.io/v1/address/")
        let parameters: Parameters = [
            "streetAddress1": "445 Mount Eden Road",
            "streetAddress2": "",
            "cityName": "Philadelphia",
            "stateName": "Pennsylvania",
            "zipCode": 19019,
            "aliasName": "Apartment"
        ]
        let headers: HTTPHeaders = [
            "Authorization": UserDefaults.standard.object(forKey: "Authorization") as! String
        ]
        Alamofire.request(urlInsertNewAddress!, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers).validate().responseJSON { response in
            switch response.result {
            case .success:
                if let dictionary = response.result.value {
                    print(dictionary)
                }
                
            case .failure(let error):
                print("Insert new address error")
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
                if let dictionary = response.result.value {
                    self.appdata.arrCurrUserAddresses.removeAll()
                    let arrAddresses = dictionary as! NSArray
                    for elem in arrAddresses {
                        let objAddress = elem as! NSDictionary
                        let objAddressObject = Address(intAddressID: objAddress["AddressId"] as! Int, strAddressAlias: objAddress["Alias"] as! String, strCityName: objAddress["CityName"] as! String, strStateName: objAddress["StateName"] as! String, strStreetAddress1: objAddress["StreetAddress"] as! String, strStreetAddress2: objAddress["StreetAddress2"] as! String, strZipCode: objAddress["ZipCode"] as! String)
                        print("\(objAddress["Alias"] as! String) \(String(describing: objAddress["AddressId"]))")
                        self.appdata.arrCurrUserAddresses.append(objAddressObject)
                    }
                    print("This user has \(self.appdata.arrCurrUserAddresses.count) addresses")
                }
                
            case .failure(let error):
                print("Get all addresses error")
                print(error)
            }
        }
    }
    
    func fnGetCurrentOrders() {
        let urlGetMyOrders = URL(string: "https://api.projectmito.io/v1/order/products")
        let parameters: Parameters = [
            "orderId": 42
        ]
        let headers: HTTPHeaders = [
            "Authorization": UserDefaults.standard.object(forKey: "Authorization") as! String
        ]
        Alamofire.request(urlGetMyOrders!, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers).validate().responseJSON { response in
            switch response.result {
            case .success:
                if let dictionary = response.result.value {
                    let arrLineItems = dictionary as! NSArray
                    for elem in arrLineItems {
                        let objLineItemTemp = elem as! NSDictionary
                        let objProduct = Product(image: objLineItemTemp["ProductImageUrl"] as! String, ASIN: objLineItemTemp["AmazonItemId"] as! String, title: objLineItemTemp["ProductName"] as! String)
                        let intQty = objLineItemTemp["Quantity"] as! Int
                        let objLineItem = LineItem(objProduct: objProduct, intQty: intQty)
                        self.appdata.arrCurrUserCurrCart.append(objLineItem)
                    }
                    print("User has \(self.appdata.arrCurrUserCurrCart.count) line items")
                }
                
            case .failure(let error):
                print("Get current orders error")
                print(error)
            }
        }
    }
    
    func fnGetPendingPackages() {
        let urlGetPendingPackages = URL(string: "https://api.projectmito.io/v1/package")
        let parameters: Parameters = [
            "type": "Pending"
        ]
        let headers: HTTPHeaders = [
            "Authorization": UserDefaults.standard.object(forKey: "Authorization") as! String
        ]
        Alamofire.request(urlGetPendingPackages!, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers).validate().responseJSON { response in
            switch response.result {
            case .success:
                if let dictionary = response.result.value {
                    print(dictionary)
                    let arrPackages = dictionary as! NSArray
                    for objPackageTemp in arrPackages {
                        let elem = objPackageTemp as! NSDictionary
                        let objPackage = Package(intGiftOption: elem["GiftOption"] as! Int, strOrderDate: elem["OrderDate"] as! String, intOrderID: elem["OrderId"] as! Int, strOrderMessage: elem["OrderMessage"] as! String, strPhotoUrl: elem["PhotoUrl"] as! String, intSenderID: elem["SenderId"] as! Int, strUserFName: elem["UserFname"] as! String, strUserLName: elem["UserLname"] as! String)//
                        self.appdata.arrCurrUserPackages.append(objPackage)
                    }
                    print("User has \(self.appdata.arrCurrUserPackages.count) packages")
                }
                
            case .failure(let error):
                print("Get pending packages error")
                print(error)
            }
        }
    }
    
    func fnChangePassword() {
        let urlChangePassword = URL(string: "https://api.projectmito.io/v1/users/password")
        let parameters: Parameters = [
            "password": "123456",
            "passwordNew": "asdfgh",
            "passwordNewConf": "asdfgh"
        ]
        let headers: HTTPHeaders = [
            "Authorization": UserDefaults.standard.object(forKey: "Authorization") as! String
        ]
        Alamofire.request(urlChangePassword!, method: .patch, parameters: parameters, encoding: JSONEncoding.default, headers: headers).validate().responseString { response in
            switch response.result {
            case .success:
                if let dictionary = response.result.value {
                    print(dictionary)
                }
                
            case .failure(let error):
                print("Change password error")
                print(error)
                if let data = response.data, let utf8Text = String(data: data, encoding: .utf8) {
                    print(data)
                }
            }
        }
    }
}
