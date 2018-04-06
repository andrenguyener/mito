//
//  WelcomeViewController.swift
//  
//
//  Created by Benny on 4/6/18.
//

import UIKit

class WelcomeViewController: UIViewController {

    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        print("AAAAAAAAAAAAAA")
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: {
            self.functionToCall()
            print("hello i delay")
        })
       
    }
}
