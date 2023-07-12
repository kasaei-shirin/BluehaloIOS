//
//  UserCTL.swift
//  Ninox
//
//  Created by saeed on 08/06/2023.
//

import UIKit

class UserCTL: MyViewController {

    
    @IBOutlet weak var lblEmail: UILabel!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblLastName: UILabel!
    @IBOutlet weak var lblRole: UILabel!
    @IBOutlet weak var lblPhone: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUserProps()
    }
    
    func setUserProps(){
        let user = DBManager().getUserFromDB()
        
        lblEmail.text = user?.email
        lblName.text = user?.name
        lblLastName.text = user?.lastname
        lblRole.text = user?.role
        lblPhone.text = user?.phoneNum
    }
    

    
    @IBAction func logoutAction(_ sender: Any) {
        DBManager().deleteUser()
        performSegue(withIdentifier: "user2spalsh", sender: self)
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
