//
//  ViewController.swift
//  Mito 1.0
//
//  Created by Benny on 2/22/18.
//  Copyright © 2018 Benny Souriyadeth. All rights reserved.
//

import UIKit

class PeopleDetailsViewController: UIViewController {

    var appdata = AppData.shared
    
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblEmail: UILabel!
    @IBOutlet weak var img: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadPersonData()
    }
    
    func loadPersonData() {
        print("PeopleDetailsViewController Index: \(myIndex)")
        print(appdata.friends[myIndex].description())
        let friend = appdata.friends[myIndex]
        lblName.text = "\(friend.firstName) \(friend.lastName)"
        lblEmail.text = "\(friend.email)"
        let url = URL(string:"\(friend.avatar)")
        if let data = try? Data(contentsOf: url!) {
            img.image = UIImage(data: data)!
        }
    }

    @IBAction func backButton(_ sender: Any) {
        performSegue(withIdentifier: "prodDetailBack", sender: self)
    }
}

