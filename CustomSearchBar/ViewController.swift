//
//  ViewController.swift
//  CustomSearchBar
//
//  Created by Gabriel Theodoropoulos on 8/9/15.
//  Copyright (c) 2015 Appcoda. All rights reserved.
//

import UIKit
import ZFTokenField

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet var tokenField: ZFTokenField!
    
    @IBOutlet weak var tblSearchResults: UITableView!
    
    var dataArray = [String]()
    var filteredArray = [String]()
    var shouldShowSearchResults = false
    
    var tokens = [String]()
    
    var searchController: UISearchController!
    
    var customSearchController: CustomSearchController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        tblSearchResults.delegate = self
        tblSearchResults.dataSource = self
        
        loadListOfCountries()
//        configureSearchController()
        configureCustomSearchController()
        
        tokenField.delegate = self
        tokenField.dataSource = self
        self.tokenField.textField.placeholder = "Enter here"
        self.tokenField.reloadData()
        self.tokenField.textField.becomeFirstResponder()
    }
    
    @IBAction func sendButtonPressed(sender: AnyObject) {
        self.tokens = [String]()
        self.tokenField.reloadData()
    }

    func tokenDeleteButtonPressed(tokenButton: UIButton) {
        let index = self.tokenField.indexOfTokenView(tokenButton.superview)
        if (Int(index) != NSNotFound) {
            self.tokens.removeAtIndex(Int(index))
            self.tokenField.reloadData()
        }
    }

    
    // MARK: UITableView Delegate and Datasource functions
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if shouldShowSearchResults {
            return filteredArray.count
        } else {
            return dataArray.count
        }
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("idCell", forIndexPath: indexPath) 
        
        if shouldShowSearchResults {
            cell.textLabel?.text = filteredArray[indexPath.row]
        } else {
            cell.textLabel!.text = dataArray[indexPath.row]
        }
        return cell
    }
    
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 60.0
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if shouldShowSearchResults {
            self.tokens.append(filteredArray[indexPath.row])
        } else {
            self.tokens.append(dataArray[indexPath.row])
        }
        tokenField.reloadData()
    }
    
    func loadListOfCountries() {
        let pathToFile = NSBundle.mainBundle().pathForResource("tags", ofType: "txt")
        if let path = pathToFile {
            
            do {
                let countriesString = try NSString(contentsOfFile: path,
                    encoding: NSUTF8StringEncoding)
                dataArray = countriesString.componentsSeparatedByString("\n")
                tblSearchResults.reloadData()
            }
            catch let error as NSError {
                print(error.localizedDescription)
            }
            
        }
    }
    
    func configureSearchController() {
        searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = true
        searchController.searchBar.placeholder = "Search Here"
        searchController.searchBar.delegate = self
        searchController.searchBar.sizeToFit()
        
        tblSearchResults.tableHeaderView = searchController.searchBar
    }
    
    func configureCustomSearchController() {
        customSearchController = CustomSearchController(searchResultsController: self, searchBarFrame: CGRectMake(0.0, 0.0, tblSearchResults.frame.size.width, 50.0), searchBarFont: UIFont(name: "Futura", size: 16.0)!, searchBarTextColor: UIColor.orangeColor(), searchBarTintColor: UIColor.blackColor())
        
        customSearchController.customSearchBar.placeholder = "Search in this awesomebar......."
        tblSearchResults.tableHeaderView = customSearchController.customSearchBar
        
        customSearchController.customDelegate = self
    }
}

extension ViewController: UISearchResultsUpdating, UISearchBarDelegate {
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        shouldShowSearchResults = true
        tblSearchResults.reloadData()
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        shouldShowSearchResults = false
        tblSearchResults.reloadData()
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        if !shouldShowSearchResults {
            shouldShowSearchResults = true
            tblSearchResults.reloadData()
        }
        searchController.searchBar.resignFirstResponder()
    }
    
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        let searchString = searchController.searchBar.text
        
        filteredArray = dataArray.filter({ (country) -> Bool in
            let countryText: NSString = country
            return (countryText.rangeOfString(searchString!, options: NSStringCompareOptions.CaseInsensitiveSearch).location) != NSNotFound
        })
        
        tblSearchResults.reloadData()
    }
}

extension ViewController: CustomSearchControllerDelegate {
    func didStartSearching() {
        shouldShowSearchResults = true
        tblSearchResults.reloadData()
    }
    
    func didTapOnSearchButton() {
        if !shouldShowSearchResults {
            shouldShowSearchResults = true
            tblSearchResults.reloadData()
        }
    }
    
    func didTapOnCancelButton() {
        shouldShowSearchResults = false
        tblSearchResults.reloadData()
    }
    
    func didChangeSearchText(searchText: String) {
        // Filter the data array and get only those countries that match the search text.
        filteredArray = dataArray.filter({ (country) -> Bool in
            let countryText: NSString = country
            
            return (countryText.rangeOfString(searchText, options: NSStringCompareOptions.CaseInsensitiveSearch).location) != NSNotFound
        })
        
        // Reload the tableview.
        tblSearchResults.reloadData()
    }
}

extension ViewController: ZFTokenFieldDataSource, ZFTokenFieldDelegate {
    
    //pragma mark - ZFTokenField DataSource
    
    func lineHeightForTokenInField(tokenField: ZFTokenField!) -> CGFloat {
        return 40.0
    }
    
    func numberOfTokenInField(tokenField: ZFTokenField!) -> UInt {
        return UInt(tokens.count)
    }
    
    func tokenField(tokenField: ZFTokenField!, viewForTokenAtIndex index: UInt) -> UIView! {
        
        var view: UIView!
        
        if let tokenView = NSBundle.mainBundle().loadNibNamed("TokenView", owner: self, options: nil) {
            view = tokenView[0] as! UIView
            
            let label = view.viewWithTag(2) as! UILabel
            let button = view.viewWithTag(3) as! UIButton
            
            label.text = self.tokens[Int(index)];
            
            button.addTarget(self, action: "tokenDeleteButtonPressed:", forControlEvents: .TouchUpInside)
            
            let size = label.sizeThatFits(CGSizeMake(1000, 40))
            
            view.frame = CGRectMake(0, 0, size.width + 97, 40)
        }
        
        return view
    }
    
    //pragma mark - ZFTokenField Delegate
    
    func tokenMarginInTokenInField(tokenField: ZFTokenField!) -> CGFloat {
        return 5.0
    }
    
    func tokenField(tokenField: ZFTokenField!, didReturnWithText text: String!) {
        self.tokens.append(text)
        tokenField.reloadData()
    }
    
    func tokenField(tokenField: ZFTokenField!, didRemoveTokenAtIndex index: UInt) {
        self.tokens.removeAtIndex(Int(index))
    }
    
    func tokenFieldShouldEndEditing(textField: ZFTokenField!) -> Bool {
        return false
    }
    
    
    // text edit
    
    func tokenFieldDidBeginEditing(tokenField: ZFTokenField!) {
        shouldShowSearchResults = true
        tblSearchResults.reloadData()
    }
    
    func tokenField(tokenField: ZFTokenField!, didTextChanged text: String!) {
        // Filter the data array and get only those countries that match the search text.
        filteredArray = dataArray.filter({ (country) -> Bool in
            let countryText: NSString = country
            
            return (countryText.rangeOfString(text, options: NSStringCompareOptions.CaseInsensitiveSearch).location) != NSNotFound
        })
        
        // Reload the tableview.
        tblSearchResults.reloadData()
    }
}