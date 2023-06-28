//
//  AddProjectCTL.swift
//  Ninox
//
//  Created by saeed on 25/05/2023.
//

import UIKit

enum OpenAddingState{
    case open, close, opening, closing
}

class AddProjectCTL: MyViewController {

    var allProjects = [String]()
    
    var openAddingState: OpenAddingState = .close
    
    @IBOutlet weak var viewBackParent: UIView!
    @IBOutlet weak var addProjectActionView: UIView!
    
    @IBOutlet weak var btnAddProject: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var viewParentAddProject: UIView!
    
    @IBOutlet weak var constraintAddProjectHeight: NSLayoutConstraint!
    @IBOutlet weak var txtFldAddProject: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewBackParent.isUserInteractionEnabled = true
        let backTap = UITapGestureRecognizer(target: self, action: #selector(backTap(_:)))
        viewBackParent.addGestureRecognizer(backTap)
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        self.viewParentAddProject.isHidden = true
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        
        self.addProjectActionView.isUserInteractionEnabled = true
        let addProjectTap = UITapGestureRecognizer(target: self, action: #selector(addProjectTap(_:)))
        
        addProjectActionView.addGestureRecognizer(addProjectTap)
    }
    
    @objc func addProjectTap(_ sender: UITapGestureRecognizer){
        if self.openAddingState == .open{
            closeAnimation()
        }else if self.openAddingState == .close{
            openAnimation()
        }
    }
    
    func openAnimation(){
        self.viewParentAddProject.isHidden = false
        UIView.animate(withDuration: 0.25, delay: 0.0 ,options: .curveLinear ,animations: {
        self.constraintAddProjectHeight.constant = 199
        self.view.layoutIfNeeded()
        }) { Bool in
            self.openAddingState = .open
        }
    }
    
    func closeAnimation(){
        
        UIView.animate(withDuration: 0.25, delay: 0.0 ,options: UIView.AnimationOptions.curveLinear ,animations: {
        self.constraintAddProjectHeight.constant = 0
        self.view.layoutIfNeeded()
        }) { Bool in
            self.viewParentAddProject.isHidden = true
            self.openAddingState = .close
        }
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
    

    @IBAction func addProjectAction(_ sender: Any) {
        
        txtFldAddProject.resignFirstResponder()
        
        if txtFldAddProject.text?.trimmingCharacters(in: .whitespacesAndNewlines) == ""{
            ViewPatternMethods.showAlert(controller: self, title: "Error", message: "Fill project textfield!", handler: UIAlertAction(title: "OK", style: .destructive))
            return
        }
        
        let alter = ViewPatternMethods.waitingDialog(controller: self)
        
        guard let project = txtFldAddProject.text else {
            return
        }
        var params = [String:Any]()
        params["project"] = project
        
        HttpClientApi.instance().makeAPICall(url: URLS.AddProject, headers: Dictionary<String, String>(), params: params, method: .POST) { data, response, error in
            
            DispatchQueue.main.async {
                alter.dismiss(animated: true)
            }
            
            let json = try? JSONSerialization.jsonObject(with: data!, options: [])
            
            if let j = json as? [String:Any]{
                //                print(j)
                if let success = j["success"] as? String{
                    if(success == "true"){
                        DispatchQueue.main.async {
                            self.txtFldAddProject.text = ""
                            self.allProjects.append(project)
                            self.tableView.insertRows(at: [IndexPath(row: self.allProjects.count-1, section: 0)], with: .middle)
                            self.tableView.scrollToRow(at: IndexPath(row: self.allProjects.count-1, section: 0), at: .none, animated: true)
                        }
                    }
                }
            }
            
            
        } failure: { data, response, error in
            
            DispatchQueue.main.async {
                alter.dismiss(animated: true) {
                    ViewPatternMethods.showAlert(controller: self, title: "Warning", message: "There is a problem to connecting to web! Please check your internet connection!", handler: UIAlertAction(title: "OK", style: .destructive))
                }
            }
            
            print(data)
            print(response)
            print(error)
            
        }
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        constraintAddProjectHeight.constant = 0
        getAllProjects()
    }
    
    
    func getAllProjects(){
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
                                let areasOPT = j["project"] as? [String]
                                if let areas = areasOPT{
                                    for area in areas {
                                        self.allProjects.append(area)
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
    

}

extension AddProjectCTL: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.allProjects.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "addProjectItem", for: indexPath)
         as! AddProjectItem
        
        
        let item = allProjects[indexPath.row]
        cell.lblProject.text = item
        
        
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
        let dialogStoryboard = UIStoryboard(name: "dialogStoryboard", bundle: nil)
        let dest = dialogStoryboard.instantiateViewController(withIdentifier: "editAreaProjectCTL") as! EditAreaProjectCTL
        dest.row = sender.view?.tag
        dest.prevData = allProjects[sender.view!.tag]
        dest.targetAction = 2
        dest.theProtocol = self
        self.present(dest, animated: true, completion: nil)
    }
    
    @objc func deleteAction(_ sender: UITapGestureRecognizer){
        let dialogStoryboard = UIStoryboard(name: "dialogStoryboard", bundle: nil)
        let dest = dialogStoryboard.instantiateViewController(withIdentifier: "deleteAreaProjectCTL") as! DeleteAreaProjectCTL
        dest.row = sender.view?.tag
        dest.prevData = allProjects[sender.view!.tag]
        dest.targetAction = 2
        dest.theProtocol = self
        self.present(dest, animated: true, completion: nil)
    }
    
}


extension AddProjectCTL: UITextFieldDelegate, UIScrollViewDelegate, EditAreaProjectProtocol, DeleteAreaProjectProtocol{
    
    func deleteAreaProject(row: Int) {
        self.allProjects.remove(at: row)
        self.tableView.deleteRows(at: [IndexPath(row: row, section: 0)], with: .bottom)
    }
    
    func editAreaProject(row: Int, newTitle: String) {
        self.allProjects[row] = newTitle
        self.tableView.reloadRows(at: [IndexPath(row: row, section: 0)], with: .fade)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
    }
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if txtFldAddProject.isFirstResponder{
            self.txtFldAddProject.resignFirstResponder()
        }
    }
}
