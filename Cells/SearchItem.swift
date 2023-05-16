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
    
    
    @IBOutlet weak var viewExpandParent: UIView!
    
    
    
    @IBOutlet weak var lblExpireDate: UILabel!
    
    @IBOutlet weak var serviceDateTopBorder: UIView!
    
    @IBOutlet weak var serviceDateTopBorderHeight: NSLayoutConstraint!
    
    
    @IBOutlet weak var viewServiceDateTitle: UIView!
    
    @IBOutlet weak var serviceDateTitleHeight: NSLayoutConstraint!
    
    
    @IBOutlet weak var taviewViewServiceDate: UITableView!
    
    @IBOutlet weak var serviceDateTableHeight: NSLayoutConstraint!
    
    
    @IBOutlet weak var serviceDateMoreHeight: NSLayoutConstraint!
    
    @IBOutlet weak var viewServiceDateMoreParent: UIView!
    
    
    @IBOutlet weak var lblMoreServiceDate: UILabel!
    
    
    @IBOutlet weak var customInfoTopBorder: UIView!
    
    @IBOutlet weak var customInfoTopBorderHeight: NSLayoutConstraint!
    
    
    
    @IBOutlet weak var viewCustomInfoTitle: UIView!
    @IBOutlet weak var customInfoTitleHeight: NSLayoutConstraint!
    
    @IBOutlet weak var tableViewCustomInfo: UITableView!
    @IBOutlet weak var tableViewCustomInfoHeight: NSLayoutConstraint!
    
    @IBOutlet weak var viewMoreCustomInfoParent: UIView!
    
    @IBOutlet weak var lblMoreCustomInfo: UILabel!
    
    
    @IBOutlet weak var customInfoMoreheight: NSLayoutConstraint!
    
    
    
    
    @IBOutlet weak var btnGreenFlag: UIButton!
    @IBOutlet weak var btnYellowFlag: UIButton!
    @IBOutlet weak var btnOrangeFlag: UIButton!
    
    
    
    @IBOutlet weak var txtFldFlagNote: UITextField!
    
    
    @IBOutlet weak var lblMacAddress: UILabel!
    @IBOutlet weak var lblEstimatedLife: UILabel!
    @IBOutlet weak var lblBatteryExpireDate: UILabel!
    
    
    
    @IBOutlet weak var btnReplace: UIButton!
    
    @IBOutlet weak var btnEdit: UIButton!
    
    @IBOutlet weak var btnDelete: UIButton!
    
    
    
    @IBOutlet weak var viewParentOfExpandination: UIView!
    
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
