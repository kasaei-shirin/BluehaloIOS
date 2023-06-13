//
//  MainTabbarCTL.swift
//  Ninox
//
//  Created by saeed on 06/06/2023.
//

import UIKit

class MainTabbarCTL: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.selectedIndex = 2
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
//    override var preferredStatusBarStyle: UIStatusBarStyle {
//        return .lightContent
//    }

}
