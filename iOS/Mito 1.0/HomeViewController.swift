//
//  HomeViewController.swift
//  Mito 1.0
//
//  Created by JJ Guo on 2/25/18.
//  Copyright © 2018 Benny Souriyadeth. All rights reserved.
//

import UIKit
import Alamofire
import Starscream

class HomeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, WebSocketDelegate {
    func websocketDidConnect(socket: WebSocketClient) {
        print("websocket is connected")
    }
    
    func websocketDidDisconnect(socket: WebSocketClient, error: Error?) {
        if let e = error as? WSError {
            print("websocket is disconnected: \(e.message)")
        } else if let e = error {
            print("websocket is disconnected: \(e.localizedDescription)")
        } else {
            print("websocket disconnected")
        }
    }
    
    func websocketDidReceiveMessage(socket: WebSocketClient, text: String) {
        
//        print("Received text: \(text)")
        let jsonData = text.data(using: .utf8)
        let dictionary = try? JSONSerialization.jsonObject(with: jsonData!, options: .mutableLeaves)
        print(dictionary)
    }
    
    func websocketDidReceiveData(socket: WebSocketClient, data: Data) {
        print("Received data: \(data.count)")
    }
    

    @IBOutlet weak var tableView: UITableView!
    var peopleUrl = URL(string: "https://api.projectmito.io/v1/friend/")
    var urlPeopleCall = URL(string: "https://api.projectmito.io/v1/friend/")
    var appdata = AppData.shared
    var socket: WebSocket!
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = 133
        
        let userURL = "https://api.projectmito.io/v1/friend/\(appdata.intCurrentUserID)"
//        print("userURL: \(userURL)")
        peopleUrl = URL(string: userURL)
//        loadPeopleData()
        print("Authorization: \(String(describing: UserDefaults.standard.object(forKey: "Authorization")))")
        let authToken = UserDefaults.standard.object(forKey: "Authorization") as! String
//        self.fnLoadFriendData()
//        self.fnLoadAllUsers()

//        var request = URLRequest(url: URL(string: "wss://api.projectmito.io/v1/ws?auth=\(String(describing: UserDefaults.standard.object(forKey: "Authorization")))")!)
        var urlWebsocket = "wss://api.projectmito.io/v1/ws?auth=\(authToken)"
        urlWebsocket = urlWebsocket.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)!
        var request = URLRequest(url: URL(string: urlWebsocket)!)
        print("Request: \(request)")
        request.timeoutInterval = 5
        socket = WebSocket(request: request)
        
        socket.delegate = self
        socket.connect()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        tableView.reloadData()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return appdata.arrFeedItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "homeCell", for: indexPath) as! HomeTableViewCell
        let feedItemObj = appdata.arrFeedItems[indexPath.row]
        cell.img.image = UIImage(named: "\(feedItemObj.avatar)")
        cell.whatHappened.text = "\(feedItemObj.whatHappened)"
        cell.time.text = "\(feedItemObj.time)"
        cell.descr.text = "\(feedItemObj.descr)"
        cell.whatHappened.numberOfLines = 2
        return cell
    }
    
    func fnLoadAllUsers() {
        let headers: HTTPHeaders = [
            "Authorization": UserDefaults.standard.object(forKey: "Authorization") as! String
        ]
        Alamofire.request("https://api.projectmito.io/v1/users/all", method: .get, encoding: JSONEncoding.default, headers: headers).validate().responseJSON { response in
            switch response.result {
            case .success:
                if let dictionary = response.result.value {
                    let objUsers = dictionary as! NSArray
                    for objUser in objUsers {
                        let objPerson2 = objUser as! NSDictionary
                        let objPerson = Person(firstName: objPerson2["userFname"] as! String, lastName: objPerson2["userLname"] as! String, email: objPerson2["userEmail"] as! String, avatar: objPerson2["photoURL"] as! String, intUserID: objPerson2["userId"] as! Int, strUsername: objPerson2["username"] as! String, intNumFriends: objPerson2["NumFriends"] as! Int)
                        self.appdata.arrAllUsers.append(objPerson)
                    }
                    
                }
                
            case .failure(let error):
                print("Get all users error")
                print(error)
            }
        }
    }
    
    // Loading Friends (people tab)
    // POST: inserting (attach object) / GET request: put key word in the URL
    func fnLoadFriendData() {
        let urlGetFriends = URL(string: (urlPeopleCall?.absoluteString)! + "1")
        let headers: HTTPHeaders = [
            "Authorization": UserDefaults.standard.object(forKey: "Authorization") as! String
        ]
        Alamofire.request(urlGetFriends!, method: .get, encoding: JSONEncoding.default, headers: headers).validate().responseJSON { response in
            switch response.result {
            case .success:
                //                let authHeader = response.response?.allHeaderFields["Authorization"] ?? ""
                if let dictionary = response.result.value {
                    let dict2 = dictionary as! NSArray
                    for obj in dict2 {
                        let object = obj as! NSDictionary
                        let p: Person = Person(firstName: (object["UserFname"] as? String)!,
                                               lastName: (object["UserLname"] as? String)!,
                                               email: (object["UserEmail"] as? String?)!!,
                                               avatar: (object["PhotoUrl"] as? String?)!!,
                                               intUserID: (object["UserId"] as? Int)!,
                                               strUsername: (object["Username"] as? String)!,
                                               intNumFriends: (object["NumFriends"] as! Int))
                        self.appdata.arrFriends.append(p)
                        //                        DispatchQueue.main.async {
                        //                            UserDefaults.standard.set(authHeader, forKey: "Authorization")
                        //                        }
                    }
                }

            case .failure(let error):
                print("Get all users error")
                print(error)
            }
        }
    }
    
//    // Loading Friends (people tab)
//    // POST: inserting (attach object) / GET request: put key word in the URL
//    func loadPeopleData() {
//        let task = URLSession.shared.dataTask(with: peopleUrl!) { (data, response, error) in
//            if error != nil {
//                print("ERROR")
//            } else {
//                if let content = data {
//                    do {
//                        let myJson = try JSONSerialization.jsonObject(with: content, options: JSONSerialization.ReadingOptions.mutableContainers) as! NSArray
//                        for obj in myJson {
//                            let object = obj as! NSDictionary
//                            let p: Person = Person(firstName: (object["UserFname"] as? String)!, lastName: (object["UserLname"] as? String)!, email: (object["UserEmail"] as? String?)!!, avatar: (object["PhotoUrl"] as? String?)!!, intUserID: (object["UserID"] as? Int?)!!, strUsername: (object["Username"] as? String)!)
//                            self.appdata.arrFriends.append(p)
//                        }
//
//                    } catch {
//                        print("Catch")
//                    }
//                } else {
//                    print("Error")
//                }
//            }
//        }
//        task.resume()
//    }
    

    @IBAction func cart(_ sender: Any) {
        performSegue(withIdentifier: "homeToCart", sender: self)
    }
    
    
}
