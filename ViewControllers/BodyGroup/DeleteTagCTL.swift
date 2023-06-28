//
//  DeleteTagCTL.swift
//  Ninox
//
//  Created by saeed on 29/05/2023.
//

import UIKit

class DeleteTagCTL: MyViewController {

    @IBOutlet weak var viewback: UIView!
    
    let deleteReasons = ["none", "No longer needed", "Broken or damaged", "Replaced by a newer device", "security concerns", "Upgraded or updated hardware", "Software compatibility issues", "Lost or stolen", "excess inventory", "Device reached end-of-life", "User requested removal"]
    
    @IBOutlet weak var btnDelete: UIButton!
    
    @IBOutlet weak var imgViewIconType: UIImageView!
    
    @IBOutlet weak var lblTargetName: UILabel!
    @IBOutlet weak var lblAlias: UILabel!
    
    
    @IBOutlet weak var lblProject: UILabel!
    @IBOutlet weak var lblArea: UILabel!
    
    @IBOutlet weak var switchIsOnGoing: UISwitch!
    
    @IBOutlet weak var lblActivationDate: UILabel!
    @IBOutlet weak var lblEstimatedBatteryLife: UILabel!
    
    @IBOutlet weak var lblPublicAddress: UILabel!
    
    
    @IBOutlet weak var viewParentDeleteReason: RoundedCornerView!
    
    @IBOutlet weak var lblDeleteReason: UILabel!
    
    var deleteActionProtocol: DeleteActionProtocol?
    
    var indexPath: IndexPath?
    
    var theTag: TagModel?
    var targetJob: String?
    var fromWhere: String?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewback.isUserInteractionEnabled = true
        let backTap = UITapGestureRecognizer(target: self, action: #selector(backTap(_:)))
        viewback.addGestureRecognizer(backTap)
        
        setProps()
        
        viewParentDeleteReason.isUserInteractionEnabled = true
        let deleteReasonTap = UITapGestureRecognizer(target: self, action: #selector(deleteReasonTap(_:)))
        viewParentDeleteReason.addGestureRecognizer(deleteReasonTap)
        
    }
    
    @objc func deleteReasonTap(_ sender: UITapGestureRecognizer)
    {
        DataPickerDialog.PresentDataPickerDialog(ViewController: self, titleOfDialog: "Delete Reason", selectionProtocol: self, datas: deleteReasons, targetAction: 1)
    }
    
    
    @objc func backTap(_ sender: UITapGestureRecognizer){
        self.dismiss(animated: true)
    }
    
    @IBAction func deleteAction(_ sender: Any) {
        if let dlreson = lblDeleteReason.text{
            if dlreson.trimmingCharacters(in: .whitespacesAndNewlines) != ""{
                buildFirstDialog()
                return
            }
        }
        
    }
    
    func sendDelete2Web(){
        var headers = [String:String]()
        headers["Publicaddress"] = self.theTag!.publicAddress
        
        var params = [String:Any]()
        if let DReason = self.lblDeleteReason.text{
            params["deleteReason"] = DReason
        }
        params["update"] = true
        
        let waiting = ViewPatternMethods.waitingDialog(controller: self)
        
        HttpClientApi.instance().makeAPICall(url: URLS.deleteTag, headers: headers, params: params, method: .POST) { data, response, error in
            
            DispatchQueue.main.async {
                waiting.dismiss(animated: true) {
                    let json = try? JSONSerialization.jsonObject(with: data!, options: [])
                    
                    if let j = json as? [String:Any]{
                        let message = j["message"] as? String ?? ""
                        if let success = j["success"] as? String{
                            if(success == "true"){
                                self.dismiss(animated: true) {
                                    if let ip = self.indexPath{
                                        self.deleteActionProtocol?.deleted(tag: self.theTag!, indexPath: ip)
                                    }
                                }
                            }
                        }
//                        let _ = ViewPatternMethods.showAlert(controller: self, title: "Info", message: message, handler: UIAlertAction(title: "OK", style: .destructive))
                    }
                }
            }
            
        } failure: { data, response, error in
            
            DispatchQueue.main.async {
                waiting.dismiss(animated: true)
            }
            
            print(data)
            print(response)
            print(error)
            
        }

    }
    
    func buildFirstDialog(){
        var checkAnsCTL = UIAlertController(title: "Info", message: "You are about to delete tag\n\(theTag!.deviceName).\nAre you sure?", preferredStyle: .actionSheet)
        checkAnsCTL.addAction(UIAlertAction(title: "Yes", style: .default, handler: { UIAlertAction in
            checkAnsCTL.dismiss(animated: true) {
                self.showSecondDialog()
            }
        }))
        checkAnsCTL.addAction(UIAlertAction(title: "Cancle", style: .destructive))
        self.present(checkAnsCTL, animated: true)
    }
    
    func showSecondDialog(){
        var checkAnsCTL = UIAlertController(title: "Info", message: "Your tag with public address\n\(theTag!.publicAddress).\nwill permanently delete.\nAre you sure?", preferredStyle: .actionSheet)
        checkAnsCTL.addAction(UIAlertAction(title: "Yes", style: .default, handler: { UIAlertAction in
            checkAnsCTL.dismiss(animated: true) {
                self.sendDelete2Web()
            }
        }))
        checkAnsCTL.addAction(UIAlertAction(title: "Cancle", style: .destructive))
        self.present(checkAnsCTL, animated: true)
    }
    
    func setProps(){
        if let tag = theTag{
            self.lblProject.text = tag.project
            self.lblTargetName.text = tag.deviceName
            self.lblArea.text = tag.area
            self.lblAlias.text = tag.alias
            self.lblPublicAddress.text = tag.publicAddress
            let MDF = MyDateFormatter()
            let activationDate = MDF.getDateFromServerDate(dateString: tag.activationDate)
            self.lblActivationDate.text = MDF.getDateByCompleteMonthName(date: activationDate ?? Date())
            self.lblEstimatedBatteryLife.text = tag.tagBatteryExpireDate
            self.lblDeleteReason.text = "none"
            if tag.isOnGoing{
                self.switchIsOnGoing.setOn(true, animated: true)
            }else{
                self.switchIsOnGoing.setOn(false, animated: true)
            }
            self.switchIsOnGoing.isUserInteractionEnabled = false
        }
    }
    
}


extension DeleteTagCTL: DataSelection{
    func DataSelected(selectedItemIndex: Int, targetAction: Int) {
        self.lblDeleteReason.text = self.deleteReasons[selectedItemIndex]
    }
}
