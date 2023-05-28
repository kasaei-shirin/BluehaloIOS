//
//  DeleteAreaProjectCTL.swift
//  Ninox
//
//  Created by saeed on 28/05/2023.
//

import UIKit

class DeleteAreaProjectCTL: UIViewController, UITextFieldDelegate {

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
    }
    
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblMessage: UILabel!
    
    var targetAction: Int?//target1 edit area , 2 edit project
    var prevData: String?
    var row: Int?
    
    var theProtocol: DeleteAreaProjectProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if targetAction == 1{
            lblTitle.text = "Delete Area"
            lblMessage.text = "Are you sure you want delete \(prevData!) Area?"
        }else{
            lblTitle.text = "Delete Project"
            lblMessage.text = "Are you sure you want delete \(prevData!) Project?"
        }
    }
    
    @IBAction func deleteAction(_ sender: Any) {
        if targetAction == 1{
            self.deleteArea(prevData!)
        }else{
            self.deleteProject(prevData!)
        }
    }
    
    func deleteArea(_ title: String){
        let waiting = ViewPatternMethods.waitingDialog(controller: self)
        
        var params = [String:Any]()
        params["area"] = title
        HttpClientApi.instance().makeAPICall(url: URLS.DeleteAreaProject, headers: Dictionary<String, String>(), params: params, method: .POST) { data, response, error in
            
            let json = try? JSONSerialization.jsonObject(with: data!, options: [])
            
            var message = ""
            
            if let j = json as? [String:Any]{
                print(j)
                message = j["message"] as? String ?? ""
                if let success = j["success"] as? String{
                    if(success == "true"){
                        DispatchQueue.main.async {
                            waiting.dismiss(animated: true) {
                                self.theProtocol?.deleteAreaProject(row: self.row!)
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
    
    func deleteProject(_ title: String){
        
        let waiting = ViewPatternMethods.waitingDialog(controller: self)
        
        var params = [String:Any]()
        params["project"] = title
        HttpClientApi.instance().makeAPICall(url: URLS.DeleteAreaProject, headers: Dictionary<String, String>(), params: params, method: .POST) { data, response, error in
            
            let json = try? JSONSerialization.jsonObject(with: data!, options: [])
            
            var message = ""
            
            if let j = json as? [String:Any]{
                print(j)
                message = j["message"] as? String ?? ""
                if let success = j["success"] as? String{
                    if(success == "true"){
                        DispatchQueue.main.async {
                            waiting.dismiss(animated: true) {
                                self.theProtocol?.deleteAreaProject(row: self.row!)
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
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
