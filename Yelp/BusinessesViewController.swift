//
//  BusinessesViewController.swift
//  Yelp
//
//  Created by Timothy Lee on 4/23/15.
//  Copyright (c) 2015 Timothy Lee. All rights reserved.
//

import UIKit

class BusinessesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, FiltersViewControllerDelegate, UISearchBarDelegate {
    
    var businesses: [Business]!
    var businessesToDisplay: [Business] = []
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet var searchBar: UISearchBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 100
        
        searchBar.delegate = self
        
        self.navigationItem.titleView = searchBar
        
        Business.searchWithTerm(term: "Thai", completion: { (businesses: [Business]?, error: Error?) -> Void in
            
            self.businesses = businesses
            if let businesses = businesses {
                for business in businesses {
                    print(business.name!)
                    print(business.address!)
                }
            }
            
            self.filterBusinessesForSearchText(self.searchBar.text ?? "")
            self.tableView.reloadData()
            
            }
        )
        
        /* Example of Yelp search with more search options specified
         Business.searchWithTerm("Restaurants", sort: .Distance, categories: ["asianfusion", "burgers"], deals: true) { (businesses: [Business]!, error: NSError!) -> Void in
         self.businesses = businesses
         
         for business in businesses {
         print(business.name!)
         print(business.address!)
         }
         }
         */
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return businessesToDisplay.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "BusinessCell", for: indexPath) as! BusinessCell
        
        cell.business = businessesToDisplay[indexPath.row]
        
        return cell
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        filterBusinessesForSearchText(searchText)
        
        tableView.reloadData()
    }

    // MARK: - Navigation
     
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let navigationController = segue.destination as! UINavigationController
        
        let filtersViewController = navigationController.topViewController as! FiltersViewController
        
        filtersViewController.delegate = self
    }
    
    func filtersViewController(filtersViewController: FiltersViewController, didUpdateFilters filters: Filter) {
        
        let categories = filters.categories
        let sort = filters.sortBy
        let deals = filters.deals
        let distance = filters.distance
        
        Business.searchWithTerm(term: "Restaurants", sort: sort, categories: categories, deals: deals, distance: distance, completion: {
            (businesses: [Business]!, error: Error!) -> Void in
            self.businesses = businesses
            self.filterBusinessesForSearchText(self.searchBar.text ?? "")
            self.tableView.reloadData()
        })
    }
    
    func filterBusinessesForSearchText(_ searchText: String) {
        if(searchText.isEmpty) {
            self.businessesToDisplay = self.businesses
            return
        }
        
        self.businessesToDisplay = self.businesses.filter({( business: Business) -> Bool in
            // to start, let's just search by name
            return business.name?.lowercased().range(of: searchText.lowercased()) != nil
        })
    }
    
}
