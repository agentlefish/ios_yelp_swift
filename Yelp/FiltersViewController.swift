//
//  FiltersViewController.swift
//  Yelp
//
//  Created by Xiang Yu on 9/21/17.
//  Copyright © 2017 Timothy Lee. All rights reserved.
//

import UIKit

let milesPerMeter = 0.000621371

@objc protocol FiltersViewControllerDelegate {
    @objc optional func filtersViewController(filtersViewController: FiltersViewController, didUpdateFilters filters: Filter)
}

class FiltersViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, SwitchCellDelegate {

    @IBOutlet weak var tableView: UITableView!
    
    weak var delegate: FiltersViewControllerDelegate!

    var tableData = FilterTable()
    var switchStates: [IndexPath:Bool]!
    
    var isCategoriesExpanded = false
    
    let IndexOfSeeAll = 3
    let HeaderViewIdentifier = "TableViewHeaderView"
    
    private func initData() {
        switchStates = switchStates ?? [IndexPath:Bool]()
        
        //hard coded default value
        switchStates[IndexPath(row:0,section:1)] = true
        switchStates[IndexPath(row:0,section:2)] = true
        
        tableData.append((.Deals, [["name":"Offering Deals", "code":"deals"]]))
        tableData.append((.Distance, [["name":"Auto", "code":"0"]]))
        tableData.append((.SortBy, [["name":"Best Match", "code":"0"]]))
        tableData.append((.Categories, yelpCategories))
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initData()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.estimatedRowHeight = 40
        tableView.rowHeight = UITableViewAutomaticDimension
        
        tableView.backgroundColor = UIColor.white
        
        tableView.register(UITableViewHeaderFooterView.self, forHeaderFooterViewReuseIdentifier: HeaderViewIdentifier)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onCancelButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }

    @IBAction func onSearchButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
        
        let filters = Filter()
        var seletedCategories = [String]()
        for (indexPath,isOn) in switchStates {
            switch tableData[indexPath.section].0 {
            case .Categories:
                if isOn {
                    seletedCategories.append(yelpCategories[indexPath.row]["code"]!)
                }
                break
            case .Deals:
                if isOn {
                    filters.deals = true;
                }
                break
            case .Distance:
                if isOn {
                    if let strDistance = yelpDistance[indexPath.row]["code"] {
                        filters.distance = Double(strDistance)
                    }
                }
                break
            case .SortBy:
                if isOn {
                    if let strSort = yelpSortBy[indexPath.row]["code"], let intSort = Int(strSort) {
                        filters.sortBy = YelpSortMode(rawValue: intSort)
                    }
                }
                break
            }
        }
        
        if seletedCategories.count > 0 {
            filters.categories = seletedCategories
        }
        
        delegate?.filtersViewController?(filtersViewController: self, didUpdateFilters: filters)
    }
    
    // MARK: - Delegate functions
    func numberOfSections(in tableView: UITableView) -> Int {
        return tableData.count
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: HeaderViewIdentifier)!
        //skip the first deals section header
        if section > 0 {
            header.textLabel?.text = tableData[section].0.rawValue
        }
        return header
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableData[section].0 == .Categories && !isCategoriesExpanded {
            return IndexOfSeeAll+1
        }
        
        return tableData[section].1.count
    }
    
    func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        let sectionId = tableData[indexPath.section].0
        if tableView.cellForRow(at: indexPath)?.accessoryType == UITableViewCellAccessoryType.detailButton {
            
            if sectionId == .Distance {
                tableData[indexPath.section].1 = yelpDistance
            }
            else if sectionId == .SortBy {
                tableData[indexPath.section].1 = yelpSortBy
            }
        }
        
        tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let sectionId = tableData[indexPath.section].0
        if sectionId == .Deals{
            return
        }
        
        if sectionId == .Categories {
            if !isCategoriesExpanded && indexPath.row == IndexOfSeeAll {
                tableView.cellForRow(at: indexPath)?.selectionStyle = .none
                
                isCategoriesExpanded = true;
                
                tableView.reloadData()
            }
            
            return
        }
        
        // expand table section
        if tableView.cellForRow(at: indexPath)?.accessoryType == UITableViewCellAccessoryType.detailButton {
            
            if sectionId == .Distance {
                tableData[indexPath.section].1 = yelpDistance
            }
            else if sectionId == .SortBy {
                tableData[indexPath.section].1 = yelpSortBy
            }
        } else { // fold section
            //unselect everything first
            let rowsCount = self.tableView.numberOfRows(inSection: indexPath.section)
            for i in 0..<rowsCount  {
                let curIdxPath = IndexPath(row: i, section: indexPath.section)
                let cell = self.tableView.cellForRow(at: curIdxPath)

                cell?.accessoryType = UITableViewCellAccessoryType.none
                switchStates[curIdxPath] = false
            }
            
            // now select and fold
            switchStates[indexPath] = true
            tableView.cellForRow(at: indexPath)?.accessoryType = UITableViewCellAccessoryType.checkmark
            
            let currentCellData = tableData[indexPath.section].1[indexPath.row]
            tableData[indexPath.section].1.removeAll()
            tableData[indexPath.section].1.append(currentCellData)
        }
        
        tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch tableData[indexPath.section].0 {
        case .Distance, .SortBy:
            let cell = tableView.dequeueReusableCell(withIdentifier: "BasicFilterCell", for: indexPath)
            
            cell.textLabel?.text = tableData[indexPath.section].1[indexPath.row]["name"]
            
            if tableData[indexPath.section].1.count == 1 {
                cell.accessoryType = UITableViewCellAccessoryType.detailButton
            } else if tableData[indexPath.section].1.count > 1 {
                cell.accessoryType = switchStates[indexPath] ?? false ?UITableViewCellAccessoryType.checkmark : UITableViewCellAccessoryType.none
            }
            
            return cell
        default:
            if tableData[indexPath.section].0 == .Categories
                && !isCategoriesExpanded
                && indexPath.row == IndexOfSeeAll {
                let cell = UITableViewCell()
                
                cell.textLabel?.text = "See All"
                cell.textLabel?.textColor = .gray
                cell.textLabel?.textAlignment = .center
                
                return cell
            }
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "SwitchCell", for: indexPath) as! SwitchCell
            
            cell.switchLabel.text = tableData[indexPath.section].1[indexPath.row]["name"]
            cell.delegate = self
            
            cell.onSwitch.isOn = switchStates[indexPath] ?? false
            
            return cell
        }
    }
    
    func switchCell(switchCell: SwitchCell, didChangeValue value: Bool) {
        guard let indexPath = tableView.indexPath(for: switchCell) else {
            return
        }
        
        switchStates[indexPath] = value
        
        print("switch event got")
    }
    
    let yelpDistance = [["name":"Auto", "code":"0"],
                        ["name":"0.5 miles", "code":(0.5/milesPerMeter).description],
                        ["name":"1 miles", "code":(1/milesPerMeter).description],
                        ["name":"5 miles", "code":(5/milesPerMeter).description],
                        ["name":"10 miles", "code":(10/milesPerMeter).description],
                        ["name":"25 miles", "code":(25/milesPerMeter).description]]
    
    let yelpSortBy = [["name":"Best Match", "code":"0"],
                      ["name":"Distance", "code":"1"],
                      ["name":"Highly Rated", "code":"2"]]
    
    let yelpCategories = [["name" : "Afghan", "code": "afghani"],
                      ["name" : "African", "code": "african"],
                      ["name" : "American, New", "code": "newamerican"],
                      ["name" : "American, Traditional", "code": "tradamerican"],
                      ["name" : "Arabian", "code": "arabian"],
                      ["name" : "Argentine", "code": "argentine"],
                      ["name" : "Armenian", "code": "armenian"],
                      ["name" : "Asian Fusion", "code": "asianfusion"],
                      ["name" : "Asturian", "code": "asturian"],
                      ["name" : "Australian", "code": "australian"],
                      ["name" : "Austrian", "code": "austrian"],
                      ["name" : "Baguettes", "code": "baguettes"],
                      ["name" : "Bangladeshi", "code": "bangladeshi"],
                      ["name" : "Barbeque", "code": "bbq"],
                      ["name" : "Basque", "code": "basque"],
                      ["name" : "Bavarian", "code": "bavarian"],
                      ["name" : "Beer Garden", "code": "beergarden"],
                      ["name" : "Beer Hall", "code": "beerhall"],
                      ["name" : "Beisl", "code": "beisl"],
                      ["name" : "Belgian", "code": "belgian"],
                      ["name" : "Bistros", "code": "bistros"],
                      ["name" : "Black Sea", "code": "blacksea"],
                      ["name" : "Brasseries", "code": "brasseries"],
                      ["name" : "Brazilian", "code": "brazilian"],
                      ["name" : "Breakfast & Brunch", "code": "breakfast_brunch"],
                      ["name" : "British", "code": "british"],
                      ["name" : "Buffets", "code": "buffets"],
                      ["name" : "Bulgarian", "code": "bulgarian"],
                      ["name" : "Burgers", "code": "burgers"],
                      ["name" : "Burmese", "code": "burmese"],
                      ["name" : "Cafes", "code": "cafes"],
                      ["name" : "Cafeteria", "code": "cafeteria"],
                      ["name" : "Cajun/Creole", "code": "cajun"],
                      ["name" : "Cambodian", "code": "cambodian"],
                      ["name" : "Canadian", "code": "New)"],
                      ["name" : "Canteen", "code": "canteen"],
                      ["name" : "Caribbean", "code": "caribbean"],
                      ["name" : "Catalan", "code": "catalan"],
                      ["name" : "Chech", "code": "chech"],
                      ["name" : "Cheesesteaks", "code": "cheesesteaks"],
                      ["name" : "Chicken Shop", "code": "chickenshop"],
                      ["name" : "Chicken Wings", "code": "chicken_wings"],
                      ["name" : "Chilean", "code": "chilean"],
                      ["name" : "Chinese", "code": "chinese"],
                      ["name" : "Comfort Food", "code": "comfortfood"],
                      ["name" : "Corsican", "code": "corsican"],
                      ["name" : "Creperies", "code": "creperies"],
                      ["name" : "Cuban", "code": "cuban"],
                      ["name" : "Curry Sausage", "code": "currysausage"],
                      ["name" : "Cypriot", "code": "cypriot"],
                      ["name" : "Czech", "code": "czech"],
                      ["name" : "Czech/Slovakian", "code": "czechslovakian"],
                      ["name" : "Danish", "code": "danish"],
                      ["name" : "Delis", "code": "delis"],
                      ["name" : "Diners", "code": "diners"],
                      ["name" : "Dumplings", "code": "dumplings"],
                      ["name" : "Eastern European", "code": "eastern_european"],
                      ["name" : "Ethiopian", "code": "ethiopian"],
                      ["name" : "Fast Food", "code": "hotdogs"],
                      ["name" : "Filipino", "code": "filipino"],
                      ["name" : "Fish & Chips", "code": "fishnchips"],
                      ["name" : "Fondue", "code": "fondue"],
                      ["name" : "Food Court", "code": "food_court"],
                      ["name" : "Food Stands", "code": "foodstands"],
                      ["name" : "French", "code": "french"],
                      ["name" : "French Southwest", "code": "sud_ouest"],
                      ["name" : "Galician", "code": "galician"],
                      ["name" : "Gastropubs", "code": "gastropubs"],
                      ["name" : "Georgian", "code": "georgian"],
                      ["name" : "German", "code": "german"],
                      ["name" : "Giblets", "code": "giblets"],
                      ["name" : "Gluten-Free", "code": "gluten_free"],
                      ["name" : "Greek", "code": "greek"],
                      ["name" : "Halal", "code": "halal"],
                      ["name" : "Hawaiian", "code": "hawaiian"],
                      ["name" : "Heuriger", "code": "heuriger"],
                      ["name" : "Himalayan/Nepalese", "code": "himalayan"],
                      ["name" : "Hong Kong Style Cafe", "code": "hkcafe"],
                      ["name" : "Hot Dogs", "code": "hotdog"],
                      ["name" : "Hot Pot", "code": "hotpot"],
                      ["name" : "Hungarian", "code": "hungarian"],
                      ["name" : "Iberian", "code": "iberian"],
                      ["name" : "Indian", "code": "indpak"],
                      ["name" : "Indonesian", "code": "indonesian"],
                      ["name" : "International", "code": "international"],
                      ["name" : "Irish", "code": "irish"],
                      ["name" : "Island Pub", "code": "island_pub"],
                      ["name" : "Israeli", "code": "israeli"],
                      ["name" : "Italian", "code": "italian"],
                      ["name" : "Japanese", "code": "japanese"],
                      ["name" : "Jewish", "code": "jewish"],
                      ["name" : "Kebab", "code": "kebab"],
                      ["name" : "Korean", "code": "korean"],
                      ["name" : "Kosher", "code": "kosher"],
                      ["name" : "Kurdish", "code": "kurdish"],
                      ["name" : "Laos", "code": "laos"],
                      ["name" : "Laotian", "code": "laotian"],
                      ["name" : "Latin American", "code": "latin"],
                      ["name" : "Live/Raw Food", "code": "raw_food"],
                      ["name" : "Lyonnais", "code": "lyonnais"],
                      ["name" : "Malaysian", "code": "malaysian"],
                      ["name" : "Meatballs", "code": "meatballs"],
                      ["name" : "Mediterranean", "code": "mediterranean"],
                      ["name" : "Mexican", "code": "mexican"],
                      ["name" : "Middle Eastern", "code": "mideastern"],
                      ["name" : "Milk Bars", "code": "milkbars"],
                      ["name" : "Modern Australian", "code": "modern_australian"],
                      ["name" : "Modern European", "code": "modern_european"],
                      ["name" : "Mongolian", "code": "mongolian"],
                      ["name" : "Moroccan", "code": "moroccan"],
                      ["name" : "New Zealand", "code": "newzealand"],
                      ["name" : "Night Food", "code": "nightfood"],
                      ["name" : "Norcinerie", "code": "norcinerie"],
                      ["name" : "Open Sandwiches", "code": "opensandwiches"],
                      ["name" : "Oriental", "code": "oriental"],
                      ["name" : "Pakistani", "code": "pakistani"],
                      ["name" : "Parent Cafes", "code": "eltern_cafes"],
                      ["name" : "Parma", "code": "parma"],
                      ["name" : "Persian/Iranian", "code": "persian"],
                      ["name" : "Peruvian", "code": "peruvian"],
                      ["name" : "Pita", "code": "pita"],
                      ["name" : "Pizza", "code": "pizza"],
                      ["name" : "Polish", "code": "polish"],
                      ["name" : "Portuguese", "code": "portuguese"],
                      ["name" : "Potatoes", "code": "potatoes"],
                      ["name" : "Poutineries", "code": "poutineries"],
                      ["name" : "Pub Food", "code": "pubfood"],
                      ["name" : "Rice", "code": "riceshop"],
                      ["name" : "Romanian", "code": "romanian"],
                      ["name" : "Rotisserie Chicken", "code": "rotisserie_chicken"],
                      ["name" : "Rumanian", "code": "rumanian"],
                      ["name" : "Russian", "code": "russian"],
                      ["name" : "Salad", "code": "salad"],
                      ["name" : "Sandwiches", "code": "sandwiches"],
                      ["name" : "Scandinavian", "code": "scandinavian"],
                      ["name" : "Scottish", "code": "scottish"],
                      ["name" : "Seafood", "code": "seafood"],
                      ["name" : "Serbo Croatian", "code": "serbocroatian"],
                      ["name" : "Signature Cuisine", "code": "signature_cuisine"],
                      ["name" : "Singaporean", "code": "singaporean"],
                      ["name" : "Slovakian", "code": "slovakian"],
                      ["name" : "Soul Food", "code": "soulfood"],
                      ["name" : "Soup", "code": "soup"],
                      ["name" : "Southern", "code": "southern"],
                      ["name" : "Spanish", "code": "spanish"],
                      ["name" : "Steakhouses", "code": "steak"],
                      ["name" : "Sushi Bars", "code": "sushi"],
                      ["name" : "Swabian", "code": "swabian"],
                      ["name" : "Swedish", "code": "swedish"],
                      ["name" : "Swiss Food", "code": "swissfood"],
                      ["name" : "Tabernas", "code": "tabernas"],
                      ["name" : "Taiwanese", "code": "taiwanese"],
                      ["name" : "Tapas Bars", "code": "tapas"],
                      ["name" : "Tapas/Small Plates", "code": "tapasmallplates"],
                      ["name" : "Tex-Mex", "code": "tex-mex"],
                      ["name" : "Thai", "code": "thai"],
                      ["name" : "Traditional Norwegian", "code": "norwegian"],
                      ["name" : "Traditional Swedish", "code": "traditional_swedish"],
                      ["name" : "Trattorie", "code": "trattorie"],
                      ["name" : "Turkish", "code": "turkish"],
                      ["name" : "Ukrainian", "code": "ukrainian"],
                      ["name" : "Uzbek", "code": "uzbek"],
                      ["name" : "Vegan", "code": "vegan"],
                      ["name" : "Vegetarian", "code": "vegetarian"],
                      ["name" : "Venison", "code": "venison"],
                      ["name" : "Vietnamese", "code": "vietnamese"],
                      ["name" : "Wok", "code": "wok"],
                      ["name" : "Wraps", "code": "wraps"],
                      ["name" : "Yugoslav", "code": "yugoslav"]]
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
