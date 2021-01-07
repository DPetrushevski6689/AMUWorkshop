//
//  JobsTableViewCell.swift
//  WorkshopApp
//
//  Created by David Petrushevski on 12/27/20.
//  Copyright © 2020 David Petrushevski. All rights reserved.
//

import UIKit

class JobsTableViewCell: UITableViewCell {
    
    @IBOutlet weak var datumLabel: UILabel!
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
