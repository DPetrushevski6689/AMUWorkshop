//
//  HandymenTableViewCell.swift
//  WorkshopApp
//
//  Created by David Petrushevski on 12/26/20.
//  Copyright © 2020 David Petrushevski. All rights reserved.
//

import UIKit

class HandymenTableViewCell: UITableViewCell {
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var surnameLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var checkedLabel: UILabel!
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
