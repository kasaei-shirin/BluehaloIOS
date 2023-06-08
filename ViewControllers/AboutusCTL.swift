//
//  AboutusCTL.swift
//  Ninox
//
//  Created by saeed on 08/06/2023.
//

import UIKit

class AboutusCTL: UIViewController {

    @IBOutlet weak var viewBackParent: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        viewBackParent.isUserInteractionEnabled = true
        let backTap = UITapGestureRecognizer(target: self, action: #selector(backTap(_:)))
        viewBackParent.addGestureRecognizer(backTap)
    }
    
    @objc func backTap(_ sender: UITapGestureRecognizer){
        self.dismiss(animated: true)
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
