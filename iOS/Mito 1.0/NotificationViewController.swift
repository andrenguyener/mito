//
//  NotificationViewController.swift
//  Mito 1.0
//
//  Created by Benny on 2/27/18.
//  Copyright © 2018 Benny Souriyadeth. All rights reserved.
//

import UIKit

class NotificationViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    var appdata = AppData.shared

    @IBOutlet weak var packageInView: UIView!
    @IBOutlet weak var notificationView: UIView!
    @IBOutlet weak var segment: UISegmentedControl!
    
    @IBOutlet weak var tblviewNotification: UITableView!
    
    
    var urlPeopleCall = URL(string: "https://api.projectmito.io/v1/friend/")
    
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
        tblviewNotification.delegate = self
        tblviewNotification.dataSource = self
        tblviewNotification.rowHeight = 100
        print(appdata.arrFriends.count)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return appdata.arrFriends.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tblviewNotification.dequeueReusableCell(withIdentifier: "cellNotification", for: indexPath) as! NotificationTableViewCell
        let objPerson = appdata.arrFriends[indexPath.row]
        cell.strFirstNameLastName.text = "\(objPerson.firstName) \(objPerson.lastName)"
        cell.strUsername.text =  objPerson.strUsername
        let urlPersonImage = URL(string:"\(objPerson.avatar)")
        let defaultURL = URL(string: "https://scontent.fsea1-1.fna.fbcdn.net/v/t31.0-8/17621927_1373277742718305_6317412440813490485_o.jpg?oh=4689a54bc23bc4969eacad74b6126fea&oe=5B460897")
        if let data = try? Data(contentsOf: urlPersonImage!) {
            cell.imgPerson.image = UIImage(data: data)!
        } else if let data = try? Data(contentsOf: defaultURL!){
            cell.imgPerson.image = UIImage(data: data)
        }
        return cell
    }
}
