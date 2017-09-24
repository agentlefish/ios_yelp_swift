//
//  Filter.swift
//  Yelp
//
//  Created by Xiang Yu on 9/23/17.
//  Copyright © 2017 Timothy Lee. All rights reserved.
//

import UIKit

enum FilterSectionIdentifier : String {
    case Deals = "Deals"
    case Categories = "Categories"
    case SortBy = "Sory By"
    case Distance = "Distance"
}

typealias FilterTable = [(FilterSectionIdentifier, [[String:String]])]

class Filter: NSObject {
    var deals : Bool?
    var categories : [String]?
    var sortBy: YelpSortMode?
    var distance: Double?
}
