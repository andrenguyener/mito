//
//  WelcomeViewController.swift
//  Mito 1.0
//
//  Created by Benny on 4/6/18.
//  Copyright © 2018 Benny Souriyadeth. All rights reserved.
//

import UIKit

class WelcomeViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // delay welcome screen segue
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: {
            self.functionToCall()
        })
    }
    
    func functionToCall() {
        print("hello i delay")
        self.performSegue(withIdentifier: "toHome", sender: self)
    }
}
