//
//  HandymanTableViewCell.swift
//  WorkshopApp
//
//  Created by David Petrushevski on 12/29/20.
//  Copyright © 2020 David Petrushevski. All rights reserved.
//

import UIKit

class HandymanTableViewCell: UITableViewCell {
    
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var surnameLabel: UILabel!
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
