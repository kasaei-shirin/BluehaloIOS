//
//  HomeCTL.swift
//  Ninox
//
//  Created by saeed on 09/05/2023.
//

import UIKit

class HomeCTL: MyViewController {

    
//    @IBOutlet weak var lblEmail: UILabel!
    
    var targetJob: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setViews()
        
    }
    
    func setViews(){
//        let user = DBManager().getUserFromDB()
//        lblEmail.text = user?.email
    }
    
//    @IBAction func searchAction(_ sender: Any) {
//        performSegue(withIdentifier: "home2search", sender: self)
//    }
//    
//    @IBAction func logout(_ sender: Any) {
//        DBManager().deleteUser()
//        performSegue(withIdentifier: "home2spalsh", sender: self)
//    }
    
    @IBAction func setupAction(_ sender: Any) {
        targetJob = "setup"
        performSegue(withIdentifier: "home2scanQR", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "home2scanQR"{
            let dest = segue.destination as? ScanQRCTL
            dest?.fromWhere = "home"
            dest?.targetJob = targetJob
        }
    }

    
    @IBAction func editAction(_ sender: Any) {
        targetJob = "edit"
        performSegue(withIdentifier: "home2scanQR", sender: self)
    }
    
    @IBAction func deleteAction(_ sender: Any) {
        targetJob = "delete"
        performSegue(withIdentifier: "home2scanQR", sender: self)
    }
    
}
