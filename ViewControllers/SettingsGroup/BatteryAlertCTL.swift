//
//  BatteryAlertCTL.swift
//  Ninox
//
//  Created by saeed on 11/06/2023.
//

import UIKit

class BatteryAlertCTL: MyViewController {

    
    @IBOutlet weak var backParentVie: UIView!
    @IBOutlet weak var tableView: UITableView!
    
    
    var choosedBatteryRange = 30
    let alertsTime = [30, 25, 20, 15, 10, 5]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        backParentVie.isUserInteractionEnabled = true
        let backtap = UITapGestureRecognizer(target: self, action: #selector(backTap(_:)))
        backParentVie.addGestureRecognizer(backtap)
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        getCurrentRange()
        // Do any additional setup after loading the view.
    }
    
    @objc func backTap(_ sender: UITapGestureRecognizer){
        self.dismiss(animated: true)
    }
    
    func getCurrentRange(){
        let waiting = ViewPatternMethods.waitingDialog(controller: self)
        
        HttpClientApi.instance().makeAPICall(url: URLS.batteryAlert, headers: Dictionary<String, String>(), params: nil, method: .GET) { data, response, error in
            
            let json = try? JSONSerialization.jsonObject(with: data!, options: [])
            
            var message = ""
            
            DispatchQueue.main.async{
                waiting.dismiss(animated: true) {
                    if let j = json as? [String:Any]{
                        message = j["message"] as? String ?? ""
                        if let success = j["success"] as? String{
                            if(success == "true"){
                                self.choosedBatteryRange = j["battreyAlertRange"] as? Int ?? 30
                                self.tableView.reloadData()
                            }
                        }
                    }
                    ViewPatternMethods.showAlert(controller: self, title: "Error", message: message, handler: UIAlertAction(title: "OK", style: .destructive))
                }
            }
            
        } failure: { data, response, error in
            
            DispatchQueue.main.async {
                waiting.dismiss(animated: true) {
                    ViewPatternMethods.showAlert(controller: self, title: "Error", message: "Connection problem!!!", handler: UIAlertAction(title: "OK", style: .destructive))
                }
            }
            
            
            print(data)
            print(response)
            print(error)
        }

    }

}

extension BatteryAlertCTL: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return alertsTime.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 40
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "alertCell", for: indexPath) as! AlertCell
//        Less than "+alertsTime.get(position)+" percent
        cell.lblTitle.text = "Less than \(alertsTime[indexPath.row]) percent"
        cell.imgViewCheck.isHidden = true
        if alertsTime[indexPath.row] == choosedBatteryRange{
            cell.imgViewCheck.isHidden = false
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        sendBatteryAlert2Web(range: self.alertsTime[indexPath.row])
    }
    
    func sendBatteryAlert2Web(range: Int){
        var params = [String:Any]()
        params["battreyAlertRange"] = range
        
        let waiting = ViewPatternMethods.waitingDialog(controller: self)
        
        HttpClientApi.instance().makeAPICall(url: URLS.batteryAlert, headers: Dictionary<String, String>(), params: params, method: .POST) { data, response, error in
            
            let json = try? JSONSerialization.jsonObject(with: data!, options: [])
            
            var message = ""
            
            DispatchQueue.main.async{
                waiting.dismiss(animated: true) {
                    if let j = json as? [String:Any]{
                        message = j["message"] as? String ?? ""
                        if let success = j["success"] as? String{
                            if(success == "true"){
                                self.tableView.reloadData()
                            }
                        }
                    }
                    ViewPatternMethods.showAlert(controller: self, title: "Error", message: message, handler: UIAlertAction(title: "OK", style: .destructive))
                }
            }
        } failure: { data, response, error in
            
            DispatchQueue.main.async {
                waiting.dismiss(animated: true) {
                    ViewPatternMethods.showAlert(controller: self, title: "Error", message: "Connection problem!", handler: UIAlertAction(title: "OK", style: .destructive))
                }
            }
            
            print(data)
            print(response)
            print(error)
        }

    }
    
}
