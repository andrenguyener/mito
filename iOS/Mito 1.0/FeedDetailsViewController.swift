//
//  FeedDetailsViewController.swift
//  Mito 1.0
//
//  Created by JJ Guo on 5/29/18.
//  Copyright © 2018 Benny Souriyadeth. All rights reserved.
//

import UIKit

class FeedDetailsViewController: UIViewController {

    // Xib Outlets
//    @IBOutlet weak var imgSender: UIImageView!
//    @IBOutlet weak var lblWhatHappened: UILabel!
//    @IBOutlet weak var lblDate: UILabel!
//    @IBOutlet weak var lblDescr: UILabel!
    
    
    @IBOutlet weak var imgSender: UIImageView!
    @IBOutlet weak var lblWhatHappened: UILabel!
    @IBOutlet weak var lblDate: UILabel!
    @IBOutlet weak var lblDescr: UILabel!
    
    var appdata = AppData.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fnLoadInformation()
        self.navigationController?.isNavigationBarHidden = false
        self.navigationItem.title = "Story"
    }
    
    func fnLoadInformation() {
        var objFeedItem: FeedItem = FeedItem(strDate: "", photoSenderUrl: "", strMessage: "", strRecipientFName: "", strRecipientLName: "", strSenderFName: "", strSenderLName: "", intRecipientId: 0, intSenderId: 0, strPhotoBytes: "")
        if appdata.intSegmentIdx == 0 {
            objFeedItem = appdata.arrFriendsFeedItems[appdata.intFeedIdx]
        } else {
            objFeedItem = appdata.arrMyFeedItems[appdata.intFeedIdx]
        }
        appdata.fnDisplayImage(strImageURL: objFeedItem.photoSenderUrl, img: imgSender, boolCircle: true)
        var strSender = "\(objFeedItem.strSenderFName) \(objFeedItem.strSenderLName)"
        var strRecipient = "\(objFeedItem.strRecipientFName) \(objFeedItem.strRecipientLName)"
        if objFeedItem.intSenderId == appdata.intCurrentUserID {
            strSender = "You"
        }
        if objFeedItem.intRecipientId == appdata.intCurrentUserID {
            strRecipient = "You"
        }
        lblWhatHappened.text = "\(strSender) sent \(strRecipient)"
        lblDate.text = "\(appdata.fnUTCToLocal(date: objFeedItem.strDate))"
        lblDescr.text = "\(objFeedItem.strMessage)"
        lblDescr.numberOfLines = 2
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
