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
        appdata.fnDisplaySimpleImage(strImageURL: appdata.personRecipient.avatar, img: imgRecipientProfile, boolCircle: true)
        strRecipientName.text = "\(appdata.personRecipient.firstName) \(appdata.personRecipient.lastName)"
        textviewWriteMessage.text = "What's it for?"
//        textviewWriteMessage.keyboardDismissMode = .interactive
    }
    
//    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
//        if(text == "\n") {
//            textView.resignFirstResponder()
//            return false
//        }
//        return true
//    }
    
    func textViewDidChange(_ textView: UITextView) {
        
        print(textView.text)
        if(textView.text.contains("\n")) {
            textView.resignFirstResponder()
//            return false
        }
//        return true
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
