//
//  SingupCTL.swift
//  Ninox
//
//  Created by saeed on 07/05/2023.
//

import UIKit

class SingupCTL: MyViewController {

    
    @IBOutlet weak var txtFldEmail: UITextField!
    @IBOutlet weak var txtFldPassword: UITextField!
    @IBOutlet weak var txtFldConfPass: UITextField!
    @IBOutlet weak var txtFldToken: UITextField!
    
    @IBOutlet weak var backParentView: UIView!
    
    var waitingAlert: UIAlertController?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        let backTap = UITapGestureRecognizer(target: self, action: #selector(backTap(_:)))
        backParentView.isUserInteractionEnabled = true
        backParentView.addGestureRecognizer(backTap)
    }
    
    @objc func backTap(_ gest: UITapGestureRecognizer){
        self.dismiss(animated: true)
    }
    
    @IBAction func signupAction(_ sender: Any) {
        signupRequest(email: txtFldEmail.text!, password: txtFldPassword.text!, confPass: txtFldConfPass.text!, token: txtFldToken.text!)
    }
    
    func signupRequest(email: String, password: String, confPass: String, token:String){
        
        
        
        var params = Dictionary<String,Any>()
        params["email"] = email
        params["password"] = password
        params["confirmPassword"] = confPass
        params["regToken"] = token
        params["useCase"] = -1
        
//        json.put("email", email);
//        json.put("password", pass);
//        json.put("confirmPassword", confPass);
//        json.put("regToken", token);
//        json.put("useCase", -1);
        
        HttpClientApi.instance().makeAPICall(url: URLS.REGISTER, headers: Dictionary<String, String>(), params: params, method: .POST) { data, response, error in
            
            DispatchQueue.main.async {
                if let WA = self.waitingAlert{
                    WA.dismiss(animated: true)
                }
            }
            
            let json = try? JSONSerialization.jsonObject(with: data!, options: [])
            if let j = json as? [String:Any]{
                print(j)
                if let success = j["Sucess"] as? String {
                    if(success == "true"){
                        ViewPatternMethods.showAlert(controller: self, title: "Info", message: "You successfully registered.", handler: UIAlertAction(title: "OK", style: .destructive))
                    }
                }
            }
            
        } failure: { data, response, error in
            
            DispatchQueue.main.async {
                if let WA = self.waitingAlert{
                    WA.dismiss(animated: true)
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
