//
//  SearchItem.swift
//  Ninox
//
//  Created by saeed on 03/05/2023.
//

import UIKit

class SearchItem: UITableViewCell {

    
//    @IBOutlet weak var topParent: UIView!
    
    @IBOutlet weak var topParent: UIView!
    @IBOutlet weak var lblProductName: UILabel!
    @IBOutlet weak var lblDeviceName: UILabel!
    @IBOutlet weak var lblAlias: UILabel!
    
    @IBOutlet weak var lblRSSI: UILabel!
    
    @IBOutlet weak var sliderRSSI: UISlider!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
