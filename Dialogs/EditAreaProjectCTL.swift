//
//  EditAreaProjectCTL.swift
//  Ninox
//
//  Created by saeed on 28/05/2023.
//

import UIKit

class EditAreaProjectCTL: MyViewController , UITextFieldDelegate{

    var targetAction: Int?//target1 edit area , 2 edit project
    var prevData: String?
    var row: Int?
    @IBOutlet weak var lblTitle: UILabel!
    
    var theProtocol: EditAreaProjectProtocol?
    
    @IBOutlet weak var theTxtFld: UITextField!
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        theTxtFld.text = prevData
        
        if targetAction == 1{
            lblTitle.text = "Edit Area"
        }else{
            lblTitle.text = "Edit Project"
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        
        self.view.isUserInteractionEnabled = true
        let viewTap = UITapGestureRecognizer(target: self, action: #selector(ViewTap(_:)))
        self.view.addGestureRecognizer(viewTap)
    }
    
    
    @objc func ViewTap(_ sender: UITapGestureRecognizer){
        self.dismiss(animated: true)
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
    
    
    @IBAction func saveAction(_ sender: Any) {
        if let title = theTxtFld.text{
            let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
            if  trimmedTitle != ""{
                self.manageDataEdition(title: trimmedTitle)
            }else{
                let _ = ViewPatternMethods.showAlert(controller: self, title: "Error", message: "For delete item you should use delete button!", handler: UIAlertAction(title: "OK", style: .destructive))
            }
        }
    }
    
    func manageDataEdition(title: String){
        if targetAction == 1{
            sendNewArea(title: title)
        }else {
            sendNewProject(title: title)
        }
    }
    
    func sendNewArea(title: String){
        
        var params = [String:Any]()
        params["area"] = prevData
        params["newArea"] = title
        
        let waiting = ViewPatternMethods.waitingDialog(controller: self)
        
        HttpClientApi.instance().makeAPICall(url: URLS.EDITAREA, headers: Dictionary<String, String>(), params: params, method: .POST) { data, response, error in
            
            
            let json = try? JSONSerialization.jsonObject(with: data!, options: [])
            
            var message = ""
            
            if let j = json as? [String:Any]{
                message = j["message"] as? String ?? ""
                if let success = j["success"] as? String{
                    if(success == "true"){
                        DispatchQueue.main.async {
                            waiting.dismiss(animated: true) {
                                self.theProtocol?.editAreaProject(row: self.row!, newTitle: title)
                                self.dismiss(animated: true)
                                return;
                            }
                        }
                    }
                }
            }
            DispatchQueue.main.async {
                waiting.dismiss(animated: true) {
                    ViewPatternMethods.showAlert(controller: self, title: "Error", message: message, handler: UIAlertAction(title: "OK", style: .destructive))
                }
            }
            
        } failure: { data, response, error in
            
            DispatchQueue.main.async {
                waiting.dismiss(animated: true) {
                    ViewPatternMethods.showAlert(controller: self, title: "Error", message: "Problem in connection!!!", handler: UIAlertAction(title: "OK", style: .destructive))
                }
            }
            
            print(data)
            print(response)
            print(error)
        }

    }
    
    func sendNewProject(title: String){
        var params = [String:Any]()
        params["project"] = prevData
        params["newProject"] = title
        
        let waiting = ViewPatternMethods.waitingDialog(controller: self)
        
        HttpClientApi.instance().makeAPICall(url: URLS.EDITPROJECT, headers: Dictionary<String, String>(), params: params, method: .POST) { data, response, error in
            
            
            let json = try? JSONSerialization.jsonObject(with: data!, options: [])
            var message = ""
            if let j = json as? [String:Any]{
                message = j["message"] as? String ?? ""
                if let success = j["success"] as? String{
                    if(success == "true"){
                        DispatchQueue.main.async {
                            waiting.dismiss(animated: true) {
                                self.theProtocol?.editAreaProject(row: self.row!, newTitle: title)
                                self.dismiss(animated: true)
                                return;
                            }
                        }
                    }
                }
            }
            DispatchQueue.main.async {
                waiting.dismiss(animated: true) {
                    ViewPatternMethods.showAlert(controller: self, title: "Error", message: message, handler: UIAlertAction(title: "OK", style: .destructive))
                }
            }
            
        } failure: { data, response, error in
            
            DispatchQueue.main.async {
                waiting.dismiss(animated: true) {
                    ViewPatternMethods.showAlert(controller: self, title: "Error", message: "Problem in connection!!!", handler: UIAlertAction(title: "OK", style: .destructive))
                }
            }
            
            print(data)
            print(response)
            print(error)
        }
    }
    
    @IBAction func cancleAction(_ sender: Any) {
        self.dismiss(animated: true)
    }
}
