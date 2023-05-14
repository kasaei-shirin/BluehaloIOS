//
//  CustomInfoCell.swift
//  Ninox
//
//  Created by saeed on 13/05/2023.
//

import UIKit

class CustomInfoCell: UITableViewCell {

    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var imgViewDelete: UIImageView!
    
    @IBOutlet weak var lblContent: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
