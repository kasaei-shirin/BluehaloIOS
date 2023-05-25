//
//  AddProjectItem.swift
//  Ninox
//
//  Created by saeed on 25/05/2023.
//

import UIKit

class AddProjectItem: UITableViewCell {

    
    @IBOutlet weak var lblProject: UILabel!
    
    @IBOutlet weak var viewParentDelete: UIView!
    @IBOutlet weak var viewParentEdit: UIView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
