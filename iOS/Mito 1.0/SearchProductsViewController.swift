//
//  SearchProductsViewController.swift
//  Mito 1.0
//
//  Created by JJ Guo on 5/24/18.
//  Copyright © 2018 Benny Souriyadeth. All rights reserved.
//

import UIKit

class SearchProductsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {

    @IBOutlet weak var productTableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    var appdata = AppData.shared
    var strProductResultsPageNumber = 1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.text = ""
        searchBar.placeholder = "Search for products"
        productTableView.delegate = self
        productTableView.dataSource = self
        productTableView.rowHeight = 106
        searchBar.delegate = self
        searchBar.returnKeyType = UIReturnKeyType.done
        searchBar.text = strSearchQuery

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if (searchBar.text!.replacingOccurrences(of: " ", with: "").count > 0) { // tests for only spaces
//            spinnerProductSearch.isHidden = false
//            spinnerProductSearch.startAnimating()
//            swirlSearchImg.isHidden = true
            strSearchQuery = ""
            strSearchQuery = searchBar.text!
//            productPeopleTab.isEnabled = false
//            fnLoadProductData(strCodedSearchQuery: searchBar.text!.replacingOccurrences(of: " ", with: "+"))
        } else {
            strSearchQuery = searchBar.text!.replacingOccurrences(of: " ", with: "")
            searchBar.text! = ""
            //strSearchQuery = "Amazon"
            //searchBar.text = "Amazon"
        }
        searchBar.resignFirstResponder()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("Product count: \(appdata.arrProductSearchResults.count)")
        return appdata.arrProductSearchResults.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        print("Chose products")
        print("Product indexPath.row: \(indexPath.row)")
        let cell = tableView.dequeueReusableCell(withIdentifier: "productCell", for: indexPath) as! ProductTableViewCell
        //            if (indexPath.row == appdata.arrProductSearchResults.count - 1) {
        //                strProductResultsPageNumber += 1
        //                fnLoadProductData()
        //            }
        let objProduct = appdata.arrProductSearchResults[indexPath.row]
        appdata.fnDisplayImage(strImageURL: objProduct.image, img: cell.img, boolCircle: false)
        cell.title.text = objProduct.title
        cell.publisher.text = objProduct.publisher
        cell.price.text = objProduct.price
        return cell
    }
}
