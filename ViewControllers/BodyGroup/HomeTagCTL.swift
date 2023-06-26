//
//  TagCTL.swift
//  Ninox
//
//  Created by saeed on 22/06/2023.
//

import UIKit

class HomeTagCTL: MyViewController {

    var homeItems = [HomeCollectionModel]()
    
    @IBOutlet weak var theCollectionView: UICollectionView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        homeItems.append(HomeCollectionModel(imgName: "", title: "Setup", description: "", storyboardID: "ScanQRCTL", targetJob: "setup"))
        homeItems.append(HomeCollectionModel(imgName: "", title: "Edit", description: "", storyboardID: "ScanQRCTL", targetJob: "edit"))
        homeItems.append(HomeCollectionModel(imgName: "", title: "Replace", description: "", storyboardID: "ReplaceSB", targetJob: "replace"))
        homeItems.append(HomeCollectionModel(imgName: "", title: "Delete", description: "", storyboardID: "ScanQRCTL", targetJob: "delete"))
        
        theCollectionView.register(UINib(nibName: "HomeCollectionCell", bundle: nil), forCellWithReuseIdentifier: "homeCollectionCell")
        
        theCollectionView.delegate = self
        theCollectionView.dataSource = self
    }
    
}

extension HomeTagCTL: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let points = (self.view.frame.width/2)-25
        return CGSize(width: points, height: points)
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return homeItems.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "homeCollectionCell", for: indexPath) as! HomeCollectionCell
        let item = self.homeItems[indexPath.row]
        cell.lblTitle.text = item.title
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let storyboard = UIStoryboard(name: "BodyStoryboard", bundle: nil)
        let HI = homeItems[indexPath.row]
        if HI.storyboardID == "ScanQRCTL"{
            let dest = storyboard.instantiateViewController(identifier: HI.storyboardID) as! ScanQRCTL
            dest.fromWhere = "home"
            dest.targetJob = HI.targetJob
            self.present(dest, animated: true, completion: nil)
        }else{
            let dest = storyboard.instantiateViewController(identifier: HI.storyboardID)
            self.present(dest, animated: true)
        }
        
    }
    
}
