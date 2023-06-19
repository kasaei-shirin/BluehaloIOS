//
//  SigninCTL.swift
//  Ninox
//
//  Created by saeed on 07/05/2023.
//

import UIKit

class SigninCTL: UIViewController {

    override var preferredStatusBarStyle: UIStatusBarStyle {
          return .lightContent
    }
    
    @IBOutlet weak var txtFldEmail: UITextField!
    @IBOutlet weak var txtFldPassword: UITextField!
    
    var waitingDialog: UIAlertController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    @IBAction func singinAction(_ sender: Any) {
        let email = txtFldEmail.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        let password = txtFldPassword.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if(password!.count <= 6)
        {
            ViewPatternMethods.showAlert(controller: self, title: "Error", message: "Password must be greater than 6 characters.", handler: UIAlertAction(title: "OK", style: .destructive))
        }else{
            self.waitingDialog = ViewPatternMethods.waitingDialog(controller: self)
            signInWebRequest(email!, password!)
        }
        
    }
    
    func signInWebRequest(_ email: String, _ password: String){
        
        
        var params = Dictionary<String,Any>()
        params["email"] = email
        params["password"] = password
        
        
        HttpClientApi.instance().makeAPICall(url: URLS.SIGNIN, headers: Dictionary<String,String>(), params: params, method: .POST, success: { (data, response, error) in
            
            let json = try? JSONSerialization.jsonObject(with: data!, options: [])
            DispatchQueue.main.async {
                if let WD = self.waitingDialog{
                    WD.dismiss(animated: true) {
                        if let j = json as? [String:Any]{
                            print(j)
            //                print(j["success"] as)
                            if let success = j["success"] as? String{
                                print("in success")
                                if(success == "true"){
                                    let token = j["token"] as! String
                                    let user = UserModel(email: email, token: token, userType: 1)
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                                        
                                        DBManager().insertUser(userModel: user)
            //                            self.checkUserFirstLogin()
                                        self.performSegue(withIdentifier: "signin2main", sender: self)
                                        
                                    }
                                    
                                    
            //                        DispatchQueue.main.async {
            //                            self.performSegue(withIdentifier: "signin2main", sender: self)
            //                        }
                                }
                            }
                        }
                    }
                }
            }
            
            
            
            
        }) { (data, response, error) in
            DispatchQueue.main.async {
                if let WD = self.waitingDialog{
                    WD.dismiss(animated: true)
                }
            }
            print(data)
            print(response)
            print(error)
        }
        
       
        
//        HttpClientApi.instance().makeAPICall(url: URLS.SIGNIN, headers: Dictionary<String, String>(), params: nil, method: .POST) { (data, response, error) in
//
//            let json = try? JSONSerialization.jsonObject(with: data!, options: [])
//            if let j = json[String:Any]{
//                print(j)
//            }
//
//        } failure: { (data, response, error in
//            print(data);
//            print(response)
//            print(error)
//        }

    }
    
    func checkUserFirstLogin(){
        
        HttpClientApi.instance().makeAPICall(url: URLS.SIGNIN, headers: Dictionary<String,String>(), params: nil, method: .POST, success: { (data, response, error) in
            
            
        }) { (data, response, error) in
            DispatchQueue.main.async {
                if let WD = self.waitingDialog{
                    WD.dismiss(animated: true)
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
