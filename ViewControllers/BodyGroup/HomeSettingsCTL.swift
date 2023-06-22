//
//  HomeSettingsCTL.swift
//  Ninox
//
//  Created by saeed on 22/06/2023.
//

import UIKit

class HomeSettingsCTL: MyViewController {

    var settingItems = [HomeCollectionModel]()
    
    @IBOutlet weak var theCollectionView: UICollectionView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        settingItems.append(HomeCollectionModel(imgName: "", title: "Language", description: "", storyboardID: "languageCTL", targetJob: nil))
        settingItems.append(HomeCollectionModel(imgName: "", title: "Add Project/Place", description: "", storyboardID: "addProjectCTL", targetJob: nil))
        settingItems.append(HomeCollectionModel(imgName: "", title: "Add Area", description: "", storyboardID: "addAreaCTL", targetJob: nil))
        settingItems.append(HomeCollectionModel(imgName: "", title: "Set battery alert range", description: "", storyboardID: "batteryAlertCTL", targetJob: nil))
        
        theCollectionView.register(UINib(nibName: "HomeCollectionCell", bundle: nil), forCellWithReuseIdentifier: "homeCollectionCell")
        
        theCollectionView.delegate = self
        theCollectionView.dataSource = self
        
    }
   
}

extension HomeSettingsCTL: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return settingItems.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let points = (self.view.frame.width/2)-25
        return CGSize(width: points, height: points)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let storyboard = UIStoryboard(name: "SettingStoryboard", bundle: nil)
        let SI = self.settingItems[indexPath.row]
        let dest = storyboard.instantiateViewController(identifier: SI.storyboardID)
        self.present(dest, animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "homeCollectionCell", for: indexPath) as! HomeCollectionCell
        let item = self.settingItems[indexPath.row]
        cell.lblTitle.text = item.title
        return cell
    }
}
