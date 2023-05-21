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
    
    var flagType: Int?
    
    var publicAddress: String?
    
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
                sendFlagNote2Web(note: fn)
            }
        }
        
    }
    
    func sendFlagNote2Web(note: String){
        let waiting = ViewPatternMethods.waitingDialog(controller: self)
        var params = Dictionary<String,Any>()
        params["flagNote"] = note
        params["flagType"] = flagType
        params["publicAddress"] = publicAddress
        HttpClientApi.instance().makeAPICall(url: URLS.FlagURL, headers: Dictionary<String, String>(), params: params, method: .POST) { data, response, error in
            
            DispatchQueue.main.async {
                waiting.dismiss(animated: true) {
                    self.dismiss(animated: true) {
                        self.flagNoteProtocol?.flagNoteText(note: note, indexPath: self.indexPath!)
                    }
                }
                
            }
            
        } failure: { data, response, error in
            
            DispatchQueue.main.async {
                waiting.dismiss(animated: true) {
                    ViewPatternMethods.showAlert(controller: self, title: "Error", message: "Back Problem!!!", handler: UIAlertAction(title: "OK", style: .destructive))
                }
                
            }
            print(data)
            print(response)
            print(error)
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
