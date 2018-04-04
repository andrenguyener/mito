//
//  NotificationViewController.swift
//  Mito 1.0
//
//  Created by Benny on 2/27/18.
//  Copyright © 2018 Benny Souriyadeth. All rights reserved.
//

import UIKit

class NotificationViewController: UIViewController {

    @IBOutlet weak var packageInView: UIView!
    @IBOutlet weak var notificationView: UIView!
    @IBOutlet weak var segment: UISegmentedControl!
    
    @IBAction func segmentControl(_ sender: Any) {
        print(segment.selectedSegmentIndex)
//        if segment.selectedSegmentIndex == 0 {
//            UIView.transition(from: packageInView, to: notificationView, duration: 0, options: .showHideTransitionViews)
//        } else {
//            UIView.transition(from: notificationView, to: packageInView, duration: 0, options: .showHideTransitionViews)
//        }
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}
