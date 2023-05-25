//
//  AddAreaItem.swift
//  Ninox
//
//  Created by saeed on 25/05/2023.
//

import UIKit

class AddAreaItem: UITableViewCell {

    @IBOutlet weak var lblArea: UILabel!
    
    
    @IBOutlet weak var viewParentEdit: UIView!
    @IBOutlet weak var viewParentDelete: UIView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
