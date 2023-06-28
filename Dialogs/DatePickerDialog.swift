//
//  DatePickerDialog.swift
//  Ninox
//
//  Created by saeed on 11/05/2023.
//

import UIKit

class DatePickerDialog: MyViewController {

    
    @IBOutlet weak var datePicker: UIDatePicker!
    
    @IBOutlet weak var txtFldTitle: UITextField!
    
    var serviceDateSelection: ServiceDateSelection?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        txtFldTitle.delegate = self
        
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
    
    @IBAction func selectAction(_ sender: Any) {
        
        if let strTitle = txtFldTitle.text{
            let title = strTitle.trimmingCharacters(in: .whitespacesAndNewlines)
            if(title == ""){
                ViewPatternMethods.showAlert(controller: self, title: "Error", message: "Write title for service date.", handler: UIAlertAction(title: "OK", style: .destructive))
            }else{
                self.dismiss(animated: true)
                serviceDateSelection?.ServiceDateSelected(item: TargetServiceDate(title: title, date: datePicker.date, _id: ""))
            }
        }
        
    }
    
    @IBAction func cancelAction(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
    class func PresentDatePickerDialog(ViewController: UIViewController, serviceDateSelection: ServiceDateSelection){
        
        let dialogStoryboard = UIStoryboard(name: "dialogStoryboard", bundle: nil)
        let dest = dialogStoryboard.instantiateViewController(withIdentifier: "dialogDatePicker") as! DatePickerDialog
        dest.serviceDateSelection = serviceDateSelection
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

extension DatePickerDialog: UIPickerViewDelegate, UITextFieldDelegate{
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        view.endEditing(true)
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.endEditing(true)
    }
}
