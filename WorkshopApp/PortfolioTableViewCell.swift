//
//  PortfolioTableViewCell.swift
//  WorkshopApp
//
//  Created by David Petrushevski on 12/26/20.
//  Copyright © 2020 David Petrushevski. All rights reserved.
//

import UIKit

class PortfolioTableViewCell: UITableViewCell {
    
    
    @IBOutlet weak var dateLabel: UILabel!
    
    
    @IBOutlet weak var jobImage: UIImageView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
