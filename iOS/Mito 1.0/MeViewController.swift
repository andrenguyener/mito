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
import Contacts
import SwiftDate

class MeViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate, CLLocationManagerDelegate, PayCardsRecognizerPlatformDelegate {
    
    // https://developer.apple.com/documentation/corelocation/choosing_the_authorization_level_for_location_services/requesting_always_authorization
    var appdata = AppData.shared
    var contactStore = CNContactStore()
    
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblAddress: UILabel!
    
    var placesClient: GMSPlacesClient!
    let locationManager = CLLocationManager()
    
    var recognizer: PayCardsRecognizer!
    
    @IBAction func btnScanCreditCard(_ sender: Any) {
//        recognizer.startCamera()
    }
    @IBAction func btnFetchContacts(_ sender: Any) {
//        let dateDate = Date()
//        let diffFormatter = DateFormatter()
//        diffFormatter.timeZone = TimeZone(abbreviation: "UTC")
//        diffFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
//        let strUTCTime = diffFormatter.string(from: dateDate)
//        print("UTC: \(strUTCTime)")
//        let strLocalTime = fnUTCStrToLocalStr(date: strUTCTime)
//        print("Local: \(strLocalTime)")
//        fnLoadMyActivity()
//        fnLoadFriendActivity()
//        fnLoadNotifications()
        fnUsePodTime(strDate: "2018-05-08T06:01:55.883Z")
//        contactStore.requestAccess(for: .contacts) { (success,error) in
//            if success {
//                print("Authorization success")
//            }
//        }
//        fnFetchContacts()
    }
    
    // Get two dates. Get difference in dates. Then convert
    func fnUsePodTime(strDate: String) {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        formatter.timeZone = TimeZone(abbreviation: "UTC")
        let p_1 = strDate.date(format: .custom("MMM d, h:mm a"))
        let date = DateInRegion()
        print(p_1)
        print(date)
//        let formatter = DateFormatter()
//        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
//        formatter.timeZone = TimeZone(abbreviation: "UTC")
//        let p_2 = date.date(formate: .custom("MMM d, h:mm a"))
    }
    
    func fnUTCStrToLocalStr(date:String) -> String {
        print("UTC: \(date)")
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        formatter.timeZone = TimeZone(abbreviation: "UTC")
        
        // Apply UTC
        let dt = formatter.date(from: date)
        
        // Change to current
        formatter.timeZone = TimeZone.current
        formatter.dateFormat = "MMM d, h:mm a"
        
        return formatter.string(from: dt!)
    }
    
//    func fnHowLongAgo(date: Date) -> Date {
//        print("UTC: \(date)")
//        let formatter = DateFormatter()
//        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
//        formatter.timeZone = TimeZone(abbreviation: "UTC")
//
//        // Apply UTC
//        let dt = formatter.string(from: date)
//
//        // Change to current
//        formatter.timeZone = TimeZone.current
//        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
//        print("Local: \(formatter.date(from: dt))")
//
//        return formatter.date(from: dt)!
//    }
    
    func fnLoadMyActivity() {
        let urlLoadMyActivity = URL(string: "https://api.projectmito.io/v1/feed/")
        let headers: HTTPHeaders = [
            "Authorization": UserDefaults.standard.object(forKey: "Authorization") as! String
        ]
        Alamofire.request(urlLoadMyActivity!, method: .get, encoding: JSONEncoding.default, headers: headers).validate().responseJSON { response in
            switch response.result {
            case .success:
                print("Loaded My Activity")
                if let dictionary = response.result.value {
                    print(dictionary)
                }
                
            case .failure(let error):
                print("Error loading my activity")
                print(error)
            }
        }
    }
    
    func fnLoadFriendActivity() {
        let urlLoadFriendActivity = URL(string: "https://api.projectmito.io/v1/feed/friends")
        let headers: HTTPHeaders = [
            "Authorization": UserDefaults.standard.object(forKey: "Authorization") as! String
        ]
        Alamofire.request(urlLoadFriendActivity!, method: .get, encoding: JSONEncoding.default, headers: headers).validate().responseJSON { response in
            switch response.result {
            case .success:
                print("Loaded Friend Activity")
                if let dictionary = response.result.value {
                    print(dictionary)
                }
                
            case .failure(let error):
                print("Error loading friend activity")
                print(error)
            }
        }
    }
    
    func fnLoadNotifications() {
        let urlLoadNotifications = URL(string: "https://api.projectmito.io/v1/notification")
        let headers: HTTPHeaders = [
            "Authorization": UserDefaults.standard.object(forKey: "Authorization") as! String
        ]
        Alamofire.request(urlLoadNotifications!, method: .get, encoding: JSONEncoding.default, headers: headers).validate().responseJSON { response in
            switch response.result {
            case .success:
                print("Loaded Notifications")
                if let dictionary = response.result.value {
                    print(dictionary)
                }
                
            case .failure(let error):
                print("Error loading my notifications")
                print(error)
            }
        }
    }
    
    func fnFetchContacts() {
        let key = [CNContactGivenNameKey, CNContactFamilyNameKey, CNContactPhoneNumbersKey] as [CNKeyDescriptor]
        let request = CNContactFetchRequest(keysToFetch: key)
        var count = 0
        try! contactStore.enumerateContacts(with: request) { (contact, stoppingPointer) in
            let strFirstName = contact.givenName
            let strLastName = contact.familyName
            let strNumber = contact.phoneNumbers.first?.value.stringValue
            if count <= 5 {
                print("First Name: \(strFirstName)")
                print("Last Name: \(strLastName)")
                print("Number: \(strNumber)")
            }
            count += 1
        }
    }
    
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//
//        recognizer.startCamera()
//    }
    
//    override func viewDidDisappear(_ animated: Bool) {
//        super.viewDidDisappear(animated)
//
//        recognizer.stopCamera()
//    }
    
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
    
    @IBAction func fnInsertNewAddress(_ sender: Any) {
        fnInsertNewAddress()
    }
    @IBAction func fnGetIncomingPackages(_ sender: Any) {
        fnGetIncomingPackages2()
    }
   
    override func viewDidLoad() {
        super.viewDidLoad()
        placesClient = GMSPlacesClient.shared()
//        recognizer = PayCardsRecognizer(delegate: self, resultMode: .sync, container: self.view, frameColor: .green)

        if UserDefaults.standard.object(forKey: "UserInfo") != nil {
            let data = UserDefaults.standard.object(forKey: "UserInfo") as! NSDictionary
            appdata.fnDisplaySimpleImage(strImageURL: data["photoURL"] as! String, img: imgProfilePic)
            self.userID.text = data["userId"] as? String
            self.userEmail.text = data["userEmail"] as? String
            self.username.text = data["username"] as? String
            // Prevent showing Optional("")
            self.userFname.text = "\(data["userFname"]!) \(data["userLname"]!)"
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
        let crop = CGRect(x: image.size.width / 2, y: image.size.height / 2, width: 20, height: 20)
        let imageRef2 = image.cgImage!.cropping(to: crop)
        return imageRef2!
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            print(image)
            let cgImage = fnCropImage(image: image)
            imgProfilePic.image = UIImage(cgImage: cgImage)
            let imageData: Data = UIImageJPEGRepresentation(imgProfilePic.image!, 1)!
            print(imageData)
            fnUploadImage(imageData: imageData)
        } else {
            print("Error")
        }
        self.dismiss(animated: true, completion: nil)
    }
    
    func fnUploadImage(imageData: Data) {
        let urlUploadImage = URL(string: "https://api.projectmito.io/v1/image")
        let parameters: Parameters = [
            "imageData": imageData
        ]
        let headers: HTTPHeaders = [
            "Authorization": UserDefaults.standard.object(forKey: "Authorization") as! String
        ]
        Alamofire.upload(multipartFormData: { (multipartFormData) in
            for (key, value) in parameters {
                let dataValue = value as! Data
                multipartFormData.append(dataValue, withName: key)
            }
            multipartFormData.append(imageData, withName: "temp_file.jpeg")
//            multipartFormData.append(imageData, withName: "image", fileName: "swift_file.jpeg", mimeType: "image/jpeg")
        }, to: urlUploadImage!)
        { (result) in
            switch result {
            case .success(let upload, _, _):
                print("Successfully uploaded")
                upload.uploadProgress(closure: { (Progress) in
                    print("Upload Progress: \(Progress.fractionCompleted)")
                })
                
                upload.responseJSON { response in
                    //self.delegate?.showSuccessAlert()
                    print(response.request)  // original URL request
                    print(response.response) // URL response
                    print(response.data)     // server data
                    print(response.result)   // result of response serialization
                    //                        self.showSuccesAlert()
                    //self.removeImage("frame", fileExtension: "txt")
                    if let JSON = response.result.value {
                        print("JSON: \(JSON)")
                    }
                }
                
            case .failure(let encodingError):
                //self.delegate?.showFailAlert()
                print("Unsuccessfully uploaded")
                print(encodingError)
            }
            
        }
        
        ///
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
    
    func fnInsertNewAddress() {
        let urlInsertNewAddress = URL(string: "https://api.projectmito.io/v1/address/")
        let parameters: Parameters = [
            "streetAddress1": "286 Zerega Ave",
            "streetAddress2": "",
            "cityName": "Bronx",
            "stateName": "NY",
            "zipCode": 10473,
            "aliasName": "Big Bro"
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
}

