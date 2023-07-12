//
//  AddAreaCTL.swift
//  Ninox
//
//  Created by saeed on 25/05/2023.
//

import UIKit

class AddAreaCTL: MyViewController {

    var allAreas = [AreaModel]()
    
    var openAddingState: OpenAddingState = .close
    
    @IBOutlet weak var viewBackParent: UIView!
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var constraintAddAreaHeight: NSLayoutConstraint!
    
    @IBOutlet weak var txtFldArea: UITextField!
    @IBOutlet weak var viewAddAreaParent: UIView!
    
    @IBOutlet weak var btnSaveArea: UIButton!
    
    @IBOutlet weak var lblProject: UILabel!
    @IBOutlet weak var viewProjectParent: RoundedCornerView!
    
    var allProjects = [ProjectModel]()
    
    var selectedProject: ProjectModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
        
        self.viewAddAreaParent.isHidden = true
        
        viewBackParent.isUserInteractionEnabled = true
        let backTap = UITapGestureRecognizer(target: self, action: #selector(backTap(_:)))
        viewBackParent.addGestureRecognizer(backTap)
        
        txtFldArea.delegate = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        viewProjectParent.isUserInteractionEnabled = true
        let projectTap = UITapGestureRecognizer(target: self, action: #selector(projectTap(_:)))
        viewProjectParent.addGestureRecognizer(projectTap)
        
//        self.addAreaActionView.isUserInteractionEnabled = true
//        let addAreaTap = UITapGestureRecognizer(target: self, action: #selector(addAreaTap(_:)))
//
//        addAreaActionView.addGestureRecognizer(addAreaTap)
        
    }
    
    @objc func projectTap(_ sender: UITapGestureRecognizer){
        if allProjects.count > 0{
            var projs = [String]()
            for proj in self.allProjects{
                projs.append(proj.name)
            }
            DataPickerDialog.PresentDataPickerDialog(ViewController: self, titleOfDialog: "Projects", selectionProtocol: self, datas: projs, targetAction: 2)
        }
    }
    
    
    
    @IBAction func addAreaTapAction(_ sender: Any) {
        if self.openAddingState == .open{
            closeAnimation()
        }else if self.openAddingState == .close{
            openAnimation()
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
    
    
    func getProjectFromWeb(TRY: Int){
        
        let alter = ViewPatternMethods.waitingDialog(controller: self)
        
        let header = Dictionary<String, String>()
        
        allProjects.removeAll()
        
        
        HttpClientApi.instance().makeAPICall(viewController: self, refreshReq: false, url: URLSV2.COMPANYPROJECT, headers: header, params: nil, method: .GET) { data, response, error in
            
            DispatchQueue.main.async {
                
                alter.dismiss(animated: true) {
                    let json = try? JSONSerialization.jsonObject(with: data!, options: [])
                    
                    DispatchQueue.main.async {
                        alter.dismiss(animated: true)
                    }
                    
                    if let j = json as? [String:Any]{
                        
                        let projectOPT = j["items"] as? [[String:Any]]
                        if let projects = projectOPT{
                            for project in projects {
                                self.allProjects.append(ProjectModel(json: project))
                            }
                            
                            DispatchQueue.main.async {
                                self.selectedProject = self.allProjects[0]
                                self.lblProject.text = self.allProjects[0].name
                                self.getAllAreasByID(theID: self.allProjects[0]._id)
                            }
                            
                        }
                    }

                }
            }
            
            
            
        } failure: { data, response, error in
            
            DispatchQueue.main.async {
                alter.dismiss(animated: true) {
                    if TRY < 4{
                        self.getProjectFromWeb(TRY: TRY+1)
                    }
                }
            }
            
            print(data)
            print(response)
            print(error)
        }
    }
    
    func getAllAreasByID(theID: String){
        
        allAreas.removeAll()
        
        let alter = ViewPatternMethods.waitingDialog(controller: self)
        let url = URLSV2.PROJECTAREAS+"?filter={\"project\": \"" + theID + "\"}"
        HttpClientApi.instance().makeAPICall(viewController: self, refreshReq: false, url: url, headers: Dictionary<String, String>(), params: nil, method: .GET) { data, response, error in
            
            DispatchQueue.main.async {
                alter.dismiss(animated: true) {
                    let json = try? JSONSerialization.jsonObject(with: data!, options: [])
                    
                    DispatchQueue.main.async {
                        alter.dismiss(animated: true)
                    }
                    if let j = json as? [String:Any]{
                        let areaOPT = j["items"] as? [[String:Any]]
                        if let areas = areaOPT{
                            for area in areas {
                                self.allAreas.append(AreaModel(json: area))
                            }
                        }
                        self.tableView.reloadData()
                    }
                }
            }
            
            
        } failure: { data, response, error in
            print(data)
            print(response)
            print(error)
        }
    }
    
    @objc func backTap(_ sender: UITapGestureRecognizer){
        self.dismiss(animated: true)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.constraintAddAreaHeight.constant = 0
        getProjectFromWeb(TRY: 1)
    }
    
    
    
//    @objc func addAreaTap(_ sender: UITapGestureRecognizer){
//        if self.openAddingState == .open{
//            closeAnimation()
//        }else if self.openAddingState == .close{
//            openAnimation()
//        }
//    }
    
    func openAnimation(){
        self.viewAddAreaParent.isHidden = false
        UIView.animate(withDuration: 0.25, delay: 0.0 ,options: .curveLinear ,animations: {
        self.constraintAddAreaHeight.constant = 199
        self.view.layoutIfNeeded()
        }) { Bool in
            self.openAddingState = .open
        }
    }
    
    func closeAnimation(){
        UIView.animate(withDuration: 0.25, delay: 0.0 ,options: UIView.AnimationOptions.curveLinear ,animations: {
        self.constraintAddAreaHeight.constant = 0
        self.view.layoutIfNeeded()
        }) { Bool in
            self.viewAddAreaParent.isHidden = true
            self.openAddingState = .close
        }
    }
    
    func getAllAreas(){
        let alter = ViewPatternMethods.waitingDialog(controller: self)
        
        let header = Dictionary<String, String>()
        
        HttpClientApi.instance().makeAPICall(viewController: self, refreshReq: false, url: URLSV2.PROJECTAREAS, headers: header, params: nil, method: .GET) { data, response, error in
            
            DispatchQueue.main.async {
                alter.dismiss(animated: true) {
                    let json = try? JSONSerialization.jsonObject(with: data!, options: [])
                    
                    DispatchQueue.main.async {
                        alter.dismiss(animated: true)
                    }
                    
                    if let j = json as? [String:Any]{
                        
                        DispatchQueue.main.async {
                            let theAreas = j["items"] as? [[String:Any]]
//                            let areasOPT = j["area"] as? [String]
                            if let areas = theAreas{
                                for area in areas {
                                    self.allAreas.append(AreaModel(json: area))
                                }
                            }
                            self.tableView.reloadData()
                        }
//                        print(j)
//                        if let success = j["success"] as? String{
//
//                        }
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
        params["name"] = area
        params["projectId"] = selectedProject!._id
        
        HttpClientApi.instance().makeAPICall(viewController: self, refreshReq: false, url: URLSV2.PROJECTAREAS, headers: Dictionary<String, String>(), params: params, method: .POST) { data, response, error in
            
            DispatchQueue.main.async {
                alter.dismiss(animated: true)
            }
            
            let json = try? JSONSerialization.jsonObject(with: data!, options: [])
            
            if let j = json as? [String:Any]{
                //                print(j)
                DispatchQueue.main.async {
                    //TODO 4 below lines is for adding area
//                    self.txtFldArea.text = ""
//                    self.allAreas.append(AreaModel(json: j))
//                    self.tableView.insertRows(at: [IndexPath(row: self.allAreas.count-1, section: 0)], with: .middle)
//                    self.tableView.scrollToRow(at: IndexPath(row: self.allAreas.count-1, section: 0), at: .none, animated: true)
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
        cell.lblArea.text = item.name
        
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
        ///TODO edit area action
//        let dialogStoryboard = UIStoryboard(name: "dialogStoryboard", bundle: nil)
//        let dest = dialogStoryboard.instantiateViewController(withIdentifier: "editAreaProjectCTL") as! EditAreaProjectCTL
//
//        dest.row = sender.view?.tag
//        dest.prevData = allAreas[sender.view!.tag]
//        dest.targetAction = 1
//        dest.theProtocol = self
//        self.present(dest, animated: true, completion: nil)
    }
    
    @objc func deleteAction(_ sender: UITapGestureRecognizer){
        ///TODO delete area action
//        let dialogStoryboard = UIStoryboard(name: "dialogStoryboard", bundle: nil)
//        let dest = dialogStoryboard.instantiateViewController(withIdentifier: "deleteAreaProjectCTL") as! DeleteAreaProjectCTL
//        dest.row = sender.view?.tag
//        dest.prevData = allAreas[sender.view!.tag]
//        dest.targetAction = 1
//        dest.theProtocol = self
//        self.present(dest, animated: true, completion: nil)
    }
    
    
}

extension AddAreaCTL: UITextFieldDelegate, UIScrollViewDelegate, EditAreaProjectProtocol, DeleteAreaProjectProtocol{
    func deleteAreaProject(row: Int) {
        print("deleted row : \(row)")
        self.allAreas.remove(at: row)
        self.tableView.deleteRows(at: [IndexPath(row: row, section: 0)], with: .bottom)
    }
    
    func editAreaProject(row: Int, newTitle: String) {
//        self.allAreas[row] = newTitle
//        self.tableView.reloadRows(at: [IndexPath(row: row, section: 0)], with: .fade)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
    }
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if txtFldArea.isFirstResponder{
            self.txtFldArea.resignFirstResponder()
        }
    }
}

extension AddAreaCTL: DataSelection{
    func DataSelected(selectedItemIndex: Int, targetAction: Int) {
        self.lblProject.text = allProjects[selectedItemIndex].name
        self.selectedProject = allProjects[selectedItemIndex]
        getAllAreasByID(theID: allProjects[selectedItemIndex]._id)
    }
    
}
