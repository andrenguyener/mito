//
//  NotificationViewController.swift
//  Mito 1.0
//
//  Created by Benny on 2/27/18.
//  Copyright © 2018 Benny Souriyadeth. All rights reserved.
//

import UIKit
import Alamofire

class NotificationViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    var appdata = AppData.shared

    @IBOutlet weak var packageInView: UIView!
    @IBOutlet weak var notificationView: UIView!
    @IBOutlet weak var segment: UISegmentedControl!
    
    @IBOutlet weak var tblviewNotification: UITableView!
    
    var urlPeopleCall = URL(string: "https://api.projectmito.io/v1/friend/")
    var urlAcceptFriendRequest = URL(string: "https://api.projectmito.io/v1/friend/request")
    
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
        appdata.arrPendingFriends.removeAll()
        self.fnPendingRequestsData()
        print("Pending friends count: \(appdata.arrPendingFriends.count)")
        tblviewNotification.delegate = self
        tblviewNotification.dataSource = self
        tblviewNotification.rowHeight = 100
    }
    
    func fnPendingRequestsData() {
        let urlGetFriends = URL(string: (urlPeopleCall?.absoluteString)! + "0")
        let headers: HTTPHeaders = [
            "Authorization": UserDefaults.standard.object(forKey: "Authorization") as! String
        ]
        print("fnPendingRequestsData: \(UserDefaults.standard.object(forKey: "Authorization"))")
        Alamofire.request(urlGetFriends!, method: .get, encoding: JSONEncoding.default, headers: headers).validate().responseJSON { response in
            switch response.result {
            case .success:
                if let dictionary = response.result.value {
                    let dict2 = dictionary as! NSArray
                    for obj in dict2 {
                        let object = obj as! NSDictionary
                        print(object)
                        let p: Person = Person(firstName: (object["UserFname"] as? String)!,
                                               lastName: (object["UserLname"] as? String)!,
                                               email: (object["UserEmail"] as? String?)!!,
                                               avatar: (object["PhotoUrl"] as? String?)!!,
                                               intUserID: (object["UserId"] as? Int)!,
                                               strUsername: (object["Username"] as? String)!)
                        self.appdata.arrPendingFriends.append(p)
                        DispatchQueue.main.async {
                            self.tblviewNotification.reloadData()
                        }
                    }
                }
                
            case .failure(let error):
                print("Get pending users error")
                print(error)
            }
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return appdata.arrPendingFriends.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let person = appdata.arrPendingFriends[indexPath.row]
        self.fnAcceptFriendRequest(person: person)
        
    }
    
    func fnAcceptFriendRequest(person: Person) {
        let parameters: Parameters = [
            "friendId": person.intUserID,
            "friendType": "Friend",
            "notificationType": "Friend"
        ]
        let headers: HTTPHeaders = [
            "Authorization": UserDefaults.standard.object(forKey: "Authorization") as! String
        ]
        Alamofire.request(urlAcceptFriendRequest!, method: .patch, parameters: parameters, encoding: JSONEncoding.default, headers: headers).validate().responseString { response in
            switch response.result {
            case .success:
                if let dictionary = response.result.value {
//                    print(dictionary)
                    DispatchQueue.main.async {
                        self.tblviewNotification.reloadData()
                        self.appdata.arrPendingFriends.removeAll()
                        self.fnPendingRequestsData()
                    }
                }
                
            case .failure(let error):
                print("Get pending users error")
                print(error)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tblviewNotification.dequeueReusableCell(withIdentifier: "cellNotification", for: indexPath) as! NotificationTableViewCell
        if appdata.arrPendingFriends.count > 0 {
            let objPerson = appdata.arrPendingFriends[indexPath.row]
            cell.strFirstNameLastName.text = "\(objPerson.firstName) \(objPerson.lastName)"
            cell.strUsername.text =  objPerson.strUsername
            let urlPersonImage = URL(string:"\(objPerson.avatar)")
            let defaultURL = URL(string: "https://scontent.fsea1-1.fna.fbcdn.net/v/t31.0-8/17621927_1373277742718305_6317412440813490485_o.jpg?oh=4689a54bc23bc4969eacad74b6126fea&oe=5B460897")
            if let data = try? Data(contentsOf: urlPersonImage!) {
                cell.imgPerson.image = UIImage(data: data)!
            } else if let data = try? Data(contentsOf: defaultURL!){
                cell.imgPerson.image = UIImage(data: data)
            }
        }
        return cell
    }
}
