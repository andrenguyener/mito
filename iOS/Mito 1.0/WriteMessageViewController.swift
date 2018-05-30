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
        self.navigationItem.title = "Send A Message"
        appdata.fnDisplayImage(strImageURL: appdata.personRecipient.avatar, img: imgRecipientProfile, boolCircle: true)
        strRecipientName.text = "\(appdata.personRecipient.firstName) \(appdata.personRecipient.lastName)"
        if appdata.strOrderMessage != "What's it for?" {
            textviewWriteMessage.text = appdata.strOrderMessage.replacingOccurrences(of: "\n", with: "")
            textviewWriteMessage.textColor = UIColor.black
        } else {
            textviewWriteMessage.text = "What's it for?"
        }
        appdata.fnDisplayImage(strImageURL: appdata.personRecipient.avatar, img: imgRecipientProfile, boolCircle: true)
    }
    
    // overrides next screen's back button title
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let backItem = UIBarButtonItem()
        backItem.title = "Back"
        navigationItem.backBarButtonItem = backItem // This will show in the next view controller being pushed
    }
    
    func textViewDidChange(_ textView: UITextView) {
        if textView.text.contains("\n") {
//            let str = String((textView.text?.prefix(textView.text.count - 2))!)
            appdata.strOrderMessage = textView.text.replacingOccurrences(of: "\n", with: "")
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
