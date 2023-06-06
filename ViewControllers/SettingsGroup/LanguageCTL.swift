//
//  LanguageCTL.swift
//  Ninox
//
//  Created by saeed on 30/05/2023.
//

import UIKit

class LanguageCTL: MyViewController {

    var languages = ["English"]
    
    @IBOutlet weak var viewBackParent: UIView!
    
    @IBOutlet weak var tableView: UITableView!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
        
        viewBackParent.isUserInteractionEnabled = true
        let backtap = UITapGestureRecognizer(target: self, action: #selector(backTap(_:)))
        viewBackParent.addGestureRecognizer(backtap)
    }

    @objc func backTap(_ sender: UITapGestureRecognizer){
        self.dismiss(animated: true)
    }
    
}

extension LanguageCTL: UITableViewDelegate, UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 45
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return languages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "languageCell", for: indexPath) as! LanuageCell
        let item = languages[indexPath.row]
        
        cell.lblTitle.text = item
        
        return cell
    }
    
    
}
