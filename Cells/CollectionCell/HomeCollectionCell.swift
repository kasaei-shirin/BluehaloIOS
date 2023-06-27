//
//  HomeCollectionCell.swift
//  Ninox
//
//  Created by saeed on 22/06/2023.
//

import UIKit

class HomeCollectionCell: UICollectionViewCell {

    @IBOutlet weak var imgView: UIImageView!
    
    @IBOutlet weak var lblTitle: HeaderLabel!
    
    @IBOutlet weak var txtViewDesc: UITextView!
    
//    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
//        return false
//    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}
