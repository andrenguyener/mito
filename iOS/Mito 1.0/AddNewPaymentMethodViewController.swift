//
//  AddNewPaymentMethodViewController.swift
//  Mito 1.0
//
//  Created by JJ Guo on 5/23/18.
//  Copyright © 2018 Benny Souriyadeth. All rights reserved.
//

import UIKit
import Alamofire

class AddNewPaymentMethodViewController: UIViewController {

    @IBOutlet weak var txtFldName: UITextField!
    @IBOutlet weak var txtFldCardNumber: UITextField!
    @IBOutlet weak var txtFldExp: UITextField!
    @IBOutlet weak var txtFldCVV: UITextField!
    var appdata = AppData.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Add Payment"
        self.hideKeyboard()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func btnSavePayment(_ sender: Any) {
        let strName: [String] = (txtFldName.text?.components(separatedBy: " "))!
        let strFName = strName[0]
        let strLName = strName[1]
        let strCardName = fnDetermineCardType()
        let intCardNumber = fnFormatCardNumber()
        let intCardCVV = fnFormatCVV()
        let intExpMonth = Int(String((txtFldExp.text?.prefix(2))!))
        let intExpYear = Int(String((txtFldExp.text?.suffix(2))!))
        fnAddPaymentMethod(strFName: strFName, strLName: strLName, strCardName: strCardName, intCardNumber: intCardNumber, intExpMonth: intExpMonth!, intExpYear: intExpYear!, intCardCVV: intCardCVV)
    }
    
    func fnDetermineCardType() -> String {
        let intCardNumber = Int(String((txtFldCardNumber.text?.prefix(2))!))
        if intCardNumber == 3 {
            return "American Express"
        } else if intCardNumber == 4 {
            return "Visa"
        } else if intCardNumber == 5 {
            return "MasterCard"
        } else {
            return "Discover"
        }
    }
    
    func fnFormatCardNumber() -> Int {
        return Int(String((txtFldCardNumber.text?.prefix(16))!))!
    }
    
    func fnFormatCVV() -> Int {
        return Int(String((txtFldCVV.text?.prefix(3))!))!
    }
    
    func fnAddPaymentMethod(strFName: String, strLName: String, strCardName: String, intCardNumber: Int, intExpMonth: Int, intExpYear: Int, intCardCVV: Int) {
        let urlInsertNewAddress = URL(string: "https://api.projectmito.io/v1/payment/")
        let parameters: Parameters = [
            "firstName": strFName,
            "lastName": strLName,
            "cardTypeName": strCardName,
            "cardNumber": String(intCardNumber),
            "expMonth": intExpMonth,
            "expYear": 2000 + intExpYear,
            "cardCVV": intCardCVV
        ]
        let headers: HTTPHeaders = [
            "Authorization": UserDefaults.standard.object(forKey: "Authorization") as! String
        ]
        Alamofire.request(urlInsertNewAddress!, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers).validate().responseJSON { response in
            switch response.result {
            case .success:
                if response.result.value != nil {
                    print("Successfully added")
                    self.appdata.strCardNumber = String(intCardNumber)
//                    self.performSegue(withIdentifier: "segAddCreditCard", sender: self)
//                    print(dictionary)
                    DispatchQueue.main.async {
                        self.performSegue(withIdentifier: "segBackToPaymentMethods", sender: self)
                    }
                }
                
            case .failure(let error):
                print("Insert new payment method error")
                print(error)
            }
        }
    }
    
    // add textfield as delegate of viewcontroller first
    // increment tags to delegate which uitextfield will be active after pressing return
    // Only shifts up if tag is > 3
    // --> want to be able to change to "if uitextfield is height of keyboard"
    // Start Editing The Text Field
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        print("Your textfield position : \(textField.frame)") // (x,y,width,height)
        //print("Your stack position : \(userpassstack.frame)")
        textField.returnKeyType = UIReturnKeyType.next
        if textField.tag > 3 {
            moveTextField(textField, moveDistance: -200, up: true)
            print("Hey i entered")
        }
    }
    
    // Finish Editing The Text Field
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField.tag > 3 {
            moveTextField(textField, moveDistance: 200, up: true)
            print("hey i ended")
        }
    }
    
    // Hide the keyboard when the return key pressed
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        let nextTag = textField.tag + 1
        if let nextResponder = textField.superview?.viewWithTag(nextTag) {
            nextResponder.becomeFirstResponder()
            print("next yo")
        } else {
            textField.resignFirstResponder()
        }
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
