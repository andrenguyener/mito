//
//  TabBarViewController.swift
//  Mito 1.0
//
//  Created by Benny on 5/30/18.
//  Copyright © 2018 Benny Souriyadeth. All rights reserved.
//

import UIKit

class TabBarViewController: UITabBarController {

    var appdata = AppData.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //tabBar.items?[1].badgeValue = "1"
        
        let packageCount = self.appdata.arrCurrUserPackages.count
        let pendingFriendCount = self.appdata.arrPendingFriends.count
        
        let notificationCount = packageCount + pendingFriendCount
        
        print("package Count: \(packageCount) Friend Count: \(pendingFriendCount)")
        print("total: \(notificationCount)")
        
        // to apply it to your last tab
        tabBar.items?.last?.badgeValue = "1"
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
