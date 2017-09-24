//
//  BusinessCell.swift
//  Yelp
//
//  Created by Xiang Yu on 9/21/17.
//  Copyright © 2017 Timothy Lee. All rights reserved.
//

import UIKit

class BusinessCell: UITableViewCell {

    @IBOutlet weak var thumbImageView: UIImageView!
    @IBOutlet weak var ratingImageView: UIImageView!
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var reviewsCountLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var categoriesLabel: UILabel!
    
    var business: Business! {
        didSet {
            nameLabel.text = business.name
            distanceLabel.text = business.distance
            reviewsCountLabel.text = "\(business.reviewCount ?? 0) Reviews"
            addressLabel.text = business.address
            categoriesLabel.text = business.categories
            
            if let imageURL = business.imageURL {
                thumbImageView.setImageWith(imageURL)
            } else {
                thumbImageView.image = nil
            }
            
            if let imageURL = business.ratingImageURL {
                ratingImageView.setImageWith(imageURL)
            } else {
                ratingImageView.image = nil
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        thumbImageView.layer.cornerRadius = 5
        thumbImageView.clipsToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
