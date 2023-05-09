//
//  ViewController.swift
//  Ninox
//
//  Created by saeed on 20/04/2023.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
//        DBManager().deleteUser()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
            let dbManager = DBManager()
            let user = dbManager.getUserFromDB()
            if(user != nil){
                if(user?.userType != -1)
                {
                    self.performSegue(withIdentifier: "splash2main", sender: self)
                }
                else
                {
                    self.performSegue(withIdentifier: "splash2select", sender: self)
                }
            }
            else{
                self.performSegue(withIdentifier: "splash2signin", sender: self)
            }
        }
        
        
        //ready to commit
    }


}

