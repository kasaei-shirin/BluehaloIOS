//
//  CustomInfoSPCell.swift
//  Ninox
//
//  Created by saeed on 15/05/2023.
//

import UIKit

class CustomInfoSPCell: UITableViewCell {

    
    
    @IBOutlet weak var lblTitle: UILabel!
    
    @IBOutlet weak var lblServiceDate: UILabel!
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
