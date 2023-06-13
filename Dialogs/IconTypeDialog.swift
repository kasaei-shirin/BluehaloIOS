//
//  IconTypeDialog.swift
//  Ninox
//
//  Created by saeed on 12/05/2023.
//

import UIKit

class IconTypeDialog: MyViewController {

    var iconTypes = [IconTypeModel]()
    
    var iconTypeSelection: IconTypeSelection?
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.iconTypes = IconTypeModel.getIconTypes()
        self.collectionView.delegate = self
        self.collectionView.dataSource = self

        self.view.isUserInteractionEnabled = true
        let viewTap = UITapGestureRecognizer(target: self, action: #selector(ViewTap(_:)))
        self.view.addGestureRecognizer(viewTap)
        
    }
    
    @objc func ViewTap(_ sender: UITapGestureRecognizer){
        self.dismiss(animated: true)
    }
    
    @IBAction func cancleAction(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
}

extension IconTypeDialog: UICollectionViewDelegate, UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 60, height: 60)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.iconTypes.count
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.iconTypeSelection?.IconTypeSelected(item: self.iconTypes[indexPath.row])
        self.dismiss(animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = self.collectionView.dequeueReusableCell(withReuseIdentifier: "IconTypeCell", for: indexPath) as! IconTypeCell
        
        let iconType = self.iconTypes[indexPath.row]
        
        cell.imgView.image = iconType.getImage()
        
        
        return cell
        
    }
    
    
    class func PresentIconTypeDialog(ViewController: UIViewController, iconTypeSelection: IconTypeSelection, iconTypes: [IconTypeModel]){
        
        let dialogStoryboard = UIStoryboard(name: "dialogStoryboard", bundle: nil)
        let dest = dialogStoryboard.instantiateViewController(withIdentifier: "dialogIconType") as! IconTypeDialog
        dest.iconTypeSelection = iconTypeSelection
        dest.iconTypes = iconTypes
        ViewController.present(dest, animated: true)
    }
    
    
}


class IconTypeCell: UICollectionViewCell{
    
    @IBOutlet weak var parentView: RoundedCornerView!
    @IBOutlet weak var imgView: UIImageView!
    
    
}
