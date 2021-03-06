//
//  PasswordViewController.swift
//  Mito 1.0
//
//  Created by JJ Guo on 5/7/18.
//  Copyright © 2018 Benny Souriyadeth. All rights reserved.
//

import UIKit
import Alamofire

class PasswordViewController: UIViewController, UITextFieldDelegate {

    var appdata = AppData.shared
    @IBOutlet weak var txtCurrentPassword: UITextField!
    @IBOutlet weak var txtNewPassword: UITextField!
    @IBOutlet weak var txtConfPassword: UITextField!
    
    @IBAction func btnDonePassword(_ sender: Any) {
        if txtNewPassword.text == txtConfPassword.text {
            fnChangePassword()
        } else {
            let alert = appdata.fnDisplayAlert(title: "Passwords do not match", message: "Wrong")
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func fnChangePassword() {
        let urlChangePassword = URL(string: "https://api.projectmito.io/v1/users/password")
        let parameters: Parameters = [
            "password": txtCurrentPassword.text!,
            "passwordNew": txtNewPassword.text!,
            "passwordNewConf": txtConfPassword.text!
        ]
        let headers: HTTPHeaders = [
            "Authorization": UserDefaults.standard.object(forKey: "Authorization") as! String
        ]
        Alamofire.request(urlChangePassword!, method: .patch, parameters: parameters, encoding: JSONEncoding.default, headers: headers).validate().responseString { response in
            switch response.result {
            case .success:
                if response.result.value != nil {
                    let alertController = UIAlertController(title: "Success!", message: "Password changed!", preferredStyle: .alert)
                    alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
                        self.performSegue(withIdentifier: "ChangePasswordToSettings", sender: self)
                    }))
                    self.present(alertController, animated: true, completion: nil)
                }
                
            case .failure(let error):
                print("Change password error")
                print(error)
                if let data = response.data, let utf8Text = String(data: data, encoding: .utf8) {
                    print(data)
                    print(utf8Text)
                }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboard()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    // Finish Editing The Text Field
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField.tag > 3 {
            moveTextField(textField, moveDistance: 200, up: true)
            print("hey i ended")
        }
        //        else if textField.tag > 0 && password != nil {
        //            moveTextField(textField, moveDistance: 50, up: true)
        //            print("Finished entering password")
        //        }
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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
