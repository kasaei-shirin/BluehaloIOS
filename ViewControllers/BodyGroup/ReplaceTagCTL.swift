//
//  ReplaceTagCTL.swift
//  Ninox
//
//  Created by saeed on 30/05/2023.
//

import UIKit
import CoreBluetooth

class ReplaceTagCTL: UIViewController, CBCentralManagerDelegate {

    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        print(central)
    }
    
    var bluetoothChecked: Bool = false
    var qrCodeChecked: Bool = false
    
    var level: Int = 1
    
    var publicAddress2Change: String?
    var targetPublicAddress: String?
    
    @IBOutlet weak var viewBackParent: UIView!
    @IBOutlet weak var viewParentCamera: RoundedCornerView!
    @IBOutlet weak var lblQRCode: UILabel!
    @IBOutlet weak var btnContinue: UIButton!
    
    
    var peripherals:[CBPeripheral] = []
//    var ADs : [[String:Any]] = []
    var PPPs : [PeripheralWithRssiAndData] = []
    var manager:CBCentralManager? = nil
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewBackParent.isUserInteractionEnabled = true
        
        let backTap = UITapGestureRecognizer(target: self, action: #selector(backTap(_:)))
        
        viewBackParent.addGestureRecognizer(backTap)
        
        setViewPropsByLevel()
        
        manager = CBCentralManager(delegate: self, queue: nil)
        
    }
    
    func setViewPropsByLevel(){
        if level == 1{
            btnContinue.setTitle("Continue", for: .normal)
        }else{
            btnContinue.setTitle("Replace", for: .normal)
        }
    }
    
    @objc func backTap(_ sender: UITapGestureRecognizer){
        self.dismiss(animated: true)
    }
    
    @IBAction func btnContinueAction(_ sender: Any) {
        
        if !qrCodeChecked{
            ViewPatternMethods.showAlert(controller: self, title: "Error", message: "Scan your target qr code first!", handler: UIAlertAction(title: "OK", style: .destructive))
            return
        }
        
        if !bluetoothChecked{
            ViewPatternMethods.showAlert(controller: self, title: "Error", message: "The ble not found yet!", handler: UIAlertAction(title: "OK", style: .destructive))
            return
        }
        btnContinue.isUserInteractionEnabled = false
        if level == 1{
            continueWithLevel1()
        }else{
            continueWithLevel2()
        }
    }
    
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        

        var indexP = -1
        var i = 0

        for item in PPPs{

            if item.periPheral.identifier.uuidString == peripheral.identifier.uuidString{
                indexP = i
            }
            i+=1
        }
        
        if(indexP == -1) {
            

            
            PPPs.append(PeripheralWithRssiAndData(periPheral: peripheral, rssi: RSSI.intValue, data: advertisementData))
            
            let data = advertisementData["kCBAdvDataManufacturerData"] as? Data ?? Data()
            
            var dataString = data.hexEncodedString()
            if(dataString.count > 5){
                dataString.removeFirst(4)
            }
            
            if(!dataString.starts(with: "06")){
                return
            }
            
            dataString = dataString.uppercased()
            var i = 0
            var theString = ""
            for char in dataString{
                if( i % 2 == 0 && i != 0){
                    theString += ":"
                }
                theString += String(char)
                i += 1
            }
            print(theString)
//            print("SQ \(ScannedQRCodePA)")
            if let SQ = self.lblQRCode.text{
                let sq = SQ.uppercased()
                if theString == sq{
                    DispatchQueue.main.async {
                        self.manager?.stopScan()
//                        self.getPAFromWeb(theString: sq)
                        self.bluetoothChecked = true
                        ViewPatternMethods.showAlert(controller: self, title: "Info", message: "BLE Found, now you can Continue!", handler: UIAlertAction(title: "OK", style: .destructive))
                    }
                }
            }
        }
        
    }
    
    func startScanForPrepheral(){
        manager?.scanForPeripherals(withServices: nil, options: nil)
        DispatchQueue.main.asyncAfter(deadline: .now() + 4.0) {
            self.manager?.stopScan()
            ///TODO check if not found
            ///
            if !self.bluetoothChecked{
                let _ = ViewPatternMethods.showAlert(controller: self, title: "Warning", message: "The BLE Device that scanned, not exists in your prepheral.", handler: UIAlertAction(title: "OK", style: .destructive))
            }
        }
    }
    
    
    func continueWithLevel1(){
        let replaceStoryboard = UIStoryboard(name: "ReplaceStoryboard", bundle: nil)
        let dest = replaceStoryboard.instantiateInitialViewController() as! ReplaceTagCTL
        dest.level = 2
        dest.publicAddress2Change = lblQRCode.text
        self.present(dest, animated: true, completion: nil)
    }
    
    func continueWithLevel2(){
        self.sendChange2Web(PA1: self.publicAddress2Change!, targetPA: targetPublicAddress!)
    }
    
    func sendChange2Web(PA1: String, targetPA: String){
        
        let waiting = ViewPatternMethods.waitingDialog(controller: self)
        
        var params = [String:Any]()
        params["publicAddress"] = targetPA
        params["update"] = true
        
        var headers = [String:String]()
        headers["Publicaddress"] = PA1
        
        HttpClientApi.instance().makeAPICall(url: URLS.SETUPTAG, headers: headers, params: params, method: .POST) { data, response, error in
            
            
            
            let json = try? JSONSerialization.jsonObject(with: data!, options: [])
            DispatchQueue.main.async {
                waiting.dismiss(animated: true) {
                    if let j = json as? [String:Any]{
                        print(j)
                        let message = j["message"] as? String ?? ""
                        if let success = j["success"] as? String{
                        
                            if(success == "true"){
                                ViewPatternMethods.showAlert(controller: self, title: "Info", message: "Tag successfully changed!", handler: UIAlertAction(title: "OK", style: .destructive))
                                return
                            }
                        
                        }
                        ViewPatternMethods.showAlert(controller: self, title: "Error", message: message, handler: UIAlertAction(title: "OK", style: .destructive))
                    }
                    ViewPatternMethods.showAlert(controller: self, title: "Error", message: "Problem in connection after response!", handler: UIAlertAction(title: "OK", style: .destructive))
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
    
}

extension ReplaceTagCTL: TagFindProtocol{
    func tagFinded(publicAddress: String, find: Bool) {
        
        if find{
            self.qrCodeChecked = true
            if level == 1{
                self.lblQRCode.text = publicAddress
                self.startScanForPrepheral()
            }else{
                self.lblQRCode.text = publicAddress
                self.targetPublicAddress = publicAddress
                self.startScanForPrepheral()
            }
        }else{
            ViewPatternMethods.showAlert(controller: self, title: "Warning", message: publicAddress, handler: UIAlertAction(title: "OK", style: .destructive))
        }
    }
}
