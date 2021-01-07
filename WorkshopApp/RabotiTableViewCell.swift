//
//  RabotiTableViewCell.swift
//  WorkshopApp
//
//  Created by David Petrushevski on 1/1/21.
//  Copyright © 2021 David Petrushevski. All rights reserved.
//

import UIKit

class RabotiTableViewCell: UITableViewCell {
    
    
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var imeLabel: UILabel!
    @IBOutlet weak var prezimeLabel: UILabel!
    
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
