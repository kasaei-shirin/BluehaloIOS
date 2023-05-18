//
//  CustomInfoDialog.swift
//  Ninox
//
//  Created by saeed on 13/05/2023.
//

import UIKit

class CustomInfoDialog: UIViewController {
    
    
    var customInfoProtocol: AddCustomInfoProtocol?
    
    
    @IBOutlet weak var txtFldTitle: UITextField!
    @IBOutlet weak var txtFldContent: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        txtFldTitle.delegate = self
        txtFldContent.delegate = self
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
    
    @IBAction func saveAction(_ sender: Any) {
        let theTitle = txtFldTitle.text
        let theContent = txtFldContent.text
        if let title = theTitle , let content = theContent{
            if(title.trimmingCharacters(in: .whitespacesAndNewlines) == "" || content.trimmingCharacters(in: .whitespacesAndNewlines) == ""){
                
                let _ = ViewPatternMethods.showAlert(controller: self, title: "Error", message: "Write title and info truly", handler: UIAlertAction(title: "OK", style: .destructive))
                
            }else{
                self.dismiss(animated: true)
                customInfoProtocol?.saveCustomInfo(title: title, Content: content)
            }
        }
    }
    
    @IBAction func cancleAction(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
    class func presentCustomInfoDialog(ViewController: UIViewController, customInfoProtocol: AddCustomInfoProtocol){
        
        let dialogStoryboard = UIStoryboard(name: "dialogStoryboard", bundle: nil)
        let dest = dialogStoryboard.instantiateViewController(withIdentifier: "dialogCustomInfo") as! CustomInfoDialog
        dest.customInfoProtocol = customInfoProtocol
        ViewController.present(dest, animated: true)
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

extension CustomInfoDialog: UITextFieldDelegate{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.endEditing(true)
    }
}
