//
//  FlagNoteController.swift
//  Ninox
//
//  Created by saeed on 18/05/2023.
//

import UIKit

class FlagNoteController: UIViewController {

    var flagNoteProtocol: FlagNoteProtocol?
    var indexPath: IndexPath?
    
    @IBOutlet weak var txtFldFlagNote: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    @IBAction func cancleAction(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
    @IBAction func btnSave(_ sender: Any) {
        
        let flagNoteStr = txtFldFlagNote.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        if let fn = flagNoteStr {
            if fn == ""{
                ViewPatternMethods.showAlert(controller: self, title: "Error", message: "You should write a flag note.", handler: UIAlertAction(title: "OK", style: .destructive))
            }else{
                flagNoteProtocol?.flagNoteText(note: fn, indexPath: indexPath!)
            }
        }
        
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
