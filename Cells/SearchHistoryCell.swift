//
//  SearchHistoryCell.swift
//  Ninox
//
//  Created by saeed on 24/05/2023.
//

import UIKit

class SearchHistoryCell: UITableViewCell {

    
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblDeleteItem: UILabel!
    
    @IBOutlet weak var lblTime: UILabel!
    @IBOutlet weak var lblMonthDay: UILabel!
    @IBOutlet weak var lblYear: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
