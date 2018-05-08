//
//  ProductViewController.swift
//  Mito 1.0
//
//  Created by JJ Guo on 3/11/18.
//  Copyright © 2018 Benny Souriyadeth. All rights reserved.
//

import UIKit

class ProductViewController: UIViewController {
    
    @IBOutlet weak var searchTextField: UITextField!
    var searchText = ""
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let talkView = segue.destination as! SearchViewController
//        talkView.strSearchQuery = searchText
    }
    
    
    @IBAction func checkSearchString(_ sender: Any) {
        searchTextField.text = searchText
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
