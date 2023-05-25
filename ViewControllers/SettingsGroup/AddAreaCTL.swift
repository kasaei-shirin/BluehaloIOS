//
//  AddAreaCTL.swift
//  Ninox
//
//  Created by saeed on 25/05/2023.
//

import UIKit

class AddAreaCTL: UIViewController {

    var allAreas = [String]()
    
    @IBOutlet weak var viewBackParent: UIView!
    
    @IBOutlet weak var tableView: UITableView!
    
    
    @IBOutlet weak var txtFldArea: UITextField!
    @IBOutlet weak var veiwAddAreaParent: UIView!
    
    @IBOutlet weak var btnSaveArea: UIButton!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
        
        viewBackParent.isUserInteractionEnabled = true
        let backTap = UITapGestureRecognizer(target: self, action: #selector(backTap(_:)))
        viewBackParent.addGestureRecognizer(backTap)
        
        txtFldArea.delegate = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y == 0 {
                self.view.frame.origin.y -= keyboardSize.height
            }
        }
    }

    @objc func keyboardWillHide(notification: NSNotification) {
        if self.view.frame.origin.y != 0 {
            self.view.frame.origin.y = 0
        }
    }
    
    
    @objc func backTap(_ sender: UITapGestureRecognizer){
        self.dismiss(animated: true)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        getAllAreas()
    }
    
    func getAllAreas(){
        let alter = ViewPatternMethods.waitingDialog(controller: self)
        
        let header = Dictionary<String, String>()
        
        HttpClientApi.instance().makeAPICall(url: URLS.PROJAREA, headers: header, params: nil, method: .GET) { data, response, error in
            
            DispatchQueue.main.async {
                alter.dismiss(animated: true) {
                    let json = try? JSONSerialization.jsonObject(with: data!, options: [])
                    
                    DispatchQueue.main.async {
                        alter.dismiss(animated: true)
                    }
                    
                    if let j = json as? [String:Any]{
                        
                        print(j)
                        if let success = j["success"] as? String{
                            DispatchQueue.main.async {
                                let areasOPT = j["area"] as? [String]
                                if let areas = areasOPT{
                                    for area in areas {
                                        self.allAreas.append(area)
                                    }
                                }
                                self.tableView.reloadData()
                            }
                        }
                    }
                }
            }
            
            
            
        } failure: { data, response, error in
            
            DispatchQueue.main.async {
                alter.dismiss(animated: true)
            }
            
            print(data)
            print(response)
            print(error)
        }
    }
    
    @IBAction func addAreaAction(_ sender: Any) {
        
        txtFldArea.resignFirstResponder()
        
        if txtFldArea.text?.trimmingCharacters(in: .whitespacesAndNewlines) == ""{
            ViewPatternMethods.showAlert(controller: self, title: "Error", message: "Fill area textfield!", handler: UIAlertAction(title: "OK", style: .destructive))
            return
        }
        
        let alter = ViewPatternMethods.waitingDialog(controller: self)
        
        guard let area = txtFldArea.text else {
            return
        }
        var params = [String:Any]()
        params["area"] = area
        
        HttpClientApi.instance().makeAPICall(url: URLS.AddArea, headers: Dictionary<String, String>(), params: params, method: .POST) { data, response, error in
            
            DispatchQueue.main.async {
                alter.dismiss(animated: true)
            }
            
            let json = try? JSONSerialization.jsonObject(with: data!, options: [])
            
            if let j = json as? [String:Any]{
                //                print(j)
                if let success = j["success"] as? String{
                    if(success == "true"){
                        DispatchQueue.main.async {
                            self.txtFldArea.text = ""
                            self.allAreas.append(area)
                            self.tableView.insertRows(at: [IndexPath(row: self.allAreas.count-1, section: 0)], with: .middle)
                            self.tableView.scrollToRow(at: IndexPath(row: self.allAreas.count-1, section: 0), at: .none, animated: true)
                        }
                    }
                }
            }
            
            
        } failure: { data, response, error in
            
            DispatchQueue.main.async {
                alter.dismiss(animated: true)
            }
            
            print(data)
            print(response)
            print(error)
            
        }

    }
    
}

extension AddAreaCTL: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allAreas.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "addAreaItem", for: indexPath) as! AddAreaItem
        let item = allAreas[indexPath.row]
        cell.lblArea.text = item
        
        cell.viewParentEdit.isUserInteractionEnabled = true
        cell.viewParentDelete.isUserInteractionEnabled = true
        
        let editTap = UITapGestureRecognizer(target: self, action: #selector(editAction(_:)))
        let deleteTap = UITapGestureRecognizer(target: self, action: #selector(deleteAction(_:)))
        
        cell.viewParentEdit.addGestureRecognizer(editTap)
        cell.viewParentDelete.addGestureRecognizer(deleteTap)
        
        editTap.view?.tag = indexPath.row
        deleteTap.view?.tag = indexPath.row
        
        return cell
    }
    
    @objc func editAction(_ sender: UITapGestureRecognizer){
        
    }
    
    @objc func deleteAction(_ sender: UITapGestureRecognizer){
        
    }
    
    
}

extension AddAreaCTL: UITextFieldDelegate, UIScrollViewDelegate{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
    }
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if txtFldArea.isFirstResponder{
            self.txtFldArea.resignFirstResponder()
        }
    }
}
