//
//  SearchFilterCTL.swift
//  Ninox
//
//  Created by saeed on 09/05/2023.
//

import UIKit

class SearchFilterCTL: UIViewController {

    @IBOutlet weak var backView: UIView!
    
    var allAreas = [String]()
    var allProjects = [String]()
    
    @IBOutlet weak var historyTableView: UITableView!
    
    @IBOutlet weak var txtFldProject: UITextField!
    
    @IBOutlet weak var txtFldArea: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let backTap = UITapGestureRecognizer(target: self, action: #selector(backTap(_:)))
        backView.isUserInteractionEnabled = true
        backView.addGestureRecognizer(backTap)
        
    }
    

    
    @objc func backTap(_ gest: UITapGestureRecognizer){
        self.dismiss(animated: true)
    }
    
    @IBAction func nextAction(_ sender: Any) {
        performSegue(withIdentifier: "location2search", sender: self)
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
