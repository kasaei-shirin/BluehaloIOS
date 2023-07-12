//
//  CheckReplaceInfoCTL.swift
//  Ninox
//
//  Created by saeed on 10/06/2023.
//

import UIKit

class CheckReplaceInfoCTL: MyViewController {

    var theTag: TagModel?
    var publicAddress2Change: String?
    
    @IBOutlet weak var txtFldProject: UITextField!
    @IBOutlet weak var txtFldArea: UITextField!
    @IBOutlet weak var txtFldTargetname: UITextField!
    
    @IBOutlet weak var txtFldActivationDate: UITextField!
    @IBOutlet weak var txtFldLastSearch: UITextField!
    @IBOutlet weak var txtFldBatteryLife: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        txtFldProject.text = theTag?.project.name
        txtFldArea.text = theTag?.area.name
        txtFldTargetname.text = theTag?.deviceName
        
        var activationDateString = ""
        let myDF = MyDateFormatter()
        let AD = myDF.getDateFromServerDate(dateString: theTag!.activationDate)
        if let activeDate = AD{
            activationDateString = myDF.getDateByCompleteMonthName(date: activeDate)
        }
        txtFldActivationDate.text = activationDateString
        txtFldLastSearch.text = theTag?.lastFindingDate
        txtFldBatteryLife.text = theTag?.tagBatteryExpireDate
        
    }
    
    @IBAction func transferDataAction(_ sender: Any) {
        sendChange2Web(PA1: self.publicAddress2Change!, targetPA: self.theTag!.publicAddress)
    }
    
    func sendChange2Web(PA1: String, targetPA: String){
        
        let waiting = ViewPatternMethods.waitingDialog(controller: self)
        
        var params = [String:Any]()
        params["activeTag"] = targetPA
        params["inactiveTag"] = PA1
        
        var headers = [String:String]()
        
        
        HttpClientApi.instance().makeAPICall(viewController: self, refreshReq: false, url: URLS.test, headers: headers, params: params, method: .POST) { data, response, error in
            
            
            
            let json = try? JSONSerialization.jsonObject(with: data!, options: [])
            DispatchQueue.main.async {
                waiting.dismiss(animated: true) {
                    let actionCTL = UIAlertController(title: "Info", message: "Tag successfully chnaged!", preferredStyle: .alert)
                    actionCTL.addAction(UIAlertAction(title: "OK", style: .default, handler: { UIAlertAction in
                        actionCTL.dismiss(animated: true) {
                            let replaceStoryboard = UIStoryboard(name: "BodyStoryboard", bundle: nil)
                            let dest = replaceStoryboard.instantiateInitialViewController()
                            self.present(dest!, animated: true, completion: nil)
                        }
                    }))
//                    if let j = json as? [String:Any]{
//                        print(j)
//                        let message = j["message"] as? String ?? ""
//                        if let success = j["success"] as? String{
//
//                            if(success == "true"){
//
//                                let actionCTL = UIAlertController(title: "Info", message: "Tag successfully chnaged!", preferredStyle: .alert)
//                                actionCTL.addAction(UIAlertAction(title: "OK", style: .default, handler: { UIAlertAction in
//                                    actionCTL.dismiss(animated: true) {
//                                        let replaceStoryboard = UIStoryboard(name: "BodyStoryboard", bundle: nil)
//                                        let dest = replaceStoryboard.instantiateInitialViewController()
//                                        self.present(dest!, animated: true, completion: nil)
//                                    }
//                                }))
//                                return
//                            }
//
//                        }
//                        ViewPatternMethods.showAlert(controller: self, title: "Error", message: message, handler: UIAlertAction(title: "OK", style: .destructive))
//                    }
//                    ViewPatternMethods.showAlert(controller: self, title: "Error", message: "Problem in connection after response!", handler: UIAlertAction(title: "OK", style: .destructive))
                }
            }
            
            
            
            
        } failure: { data, response, error in
            DispatchQueue.main.async {
                waiting.dismiss(animated: true) {
                    ViewPatternMethods.showAlert(controller: self, title: "Error", message: "Problem in connection!", handler: UIAlertAction(title: "OK", style: .destructive))
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
