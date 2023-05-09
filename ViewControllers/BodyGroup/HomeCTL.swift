//
//  HomeCTL.swift
//  Ninox
//
//  Created by saeed on 09/05/2023.
//

import UIKit

class HomeCTL: UIViewController {

    
    @IBOutlet weak var lblEmail: UILabel!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setViews()
        
    }
    
    func setViews(){
        let user = DBManager().getUserFromDB()
        lblEmail.text = user?.email
    }
    
    @IBAction func searchAction(_ sender: Any) {
        performSegue(withIdentifier: "home2search", sender: self)
    }
    
    @IBAction func logout(_ sender: Any) {
        DBManager().deleteUser()
        performSegue(withIdentifier: "home2spalsh", sender: self)
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
