//
//  WriteMessageViewController.swift
//  Mito 1.0
//
//  Created by JJ Guo on 5/17/18.
//  Copyright © 2018 Benny Souriyadeth. All rights reserved.
//

import UIKit

class WriteMessageViewController: UIViewController, UITextViewDelegate {
    
    @IBOutlet weak var imgRecipientProfile: RoundedImage!
    @IBOutlet weak var strRecipientName: UILabel!
    @IBOutlet weak var textviewWriteMessage: UITextView!
    var appdata = AppData.shared

    override func viewDidLoad() {
        super.viewDidLoad()
        textviewWriteMessage.delegate = self
        textviewWriteMessage.keyboardDismissMode = .onDrag
        appdata.fnDisplayImage(strImageURL: appdata.personRecipient.avatar, img: imgRecipientProfile, boolCircle: true)
        strRecipientName.text = "\(appdata.personRecipient.firstName) \(appdata.personRecipient.lastName)"
        textviewWriteMessage.text = "What's it for?"
        let photoString = appdata.personRecipient.avatar
        let decodedImage = Data(base64Encoded: photoString)
        let image = UIImage(data: decodedImage!)
        imgRecipientProfile.image = image
    }
    
    func textViewDidChange(_ textView: UITextView) {
        if textView.text.contains("\n") {
            textView.resignFirstResponder()
        }
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == "What's it for?" {
            textView.text = ""
            textView.textColor = UIColor.black
        } else if textView.text == "" {
            textView.text = "What's it for?"
            textView.textColor = UIColor.gray
        } else {
            textView.becomeFirstResponder()
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text == "" {
            textView.text = "What's it for?"
            textView.textColor = UIColor.gray
        } else {
            textView.resignFirstResponder()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func btnConfirmMessage(_ sender: Any) {
        appdata.strOrderMessage = textviewWriteMessage.text
        performSegue(withIdentifier: "segWriteMessageToSelectPaymentMethod", sender: self)
    }
    
}
