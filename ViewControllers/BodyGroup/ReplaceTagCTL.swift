//
//  ReplaceTagCTL.swift
//  Ninox
//
//  Created by saeed on 30/05/2023.
//

import UIKit
import CoreBluetooth

class ReplaceTagCTL: MyViewController, CBCentralManagerDelegate {

    var firstBluetooth = true
    @IBOutlet weak var imgViewBluetooth: UIImageView!
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        print(central)
        
        if central.state == .poweredOff{
            ViewPatternMethods.setBluetoothIconEnable(enable: true, imgViewBluetooth: imgViewBluetooth)
            
            
        }else{
            ViewPatternMethods.setBluetoothIconEnable(enable: false, imgViewBluetooth: imgViewBluetooth)
        }
        
//        if firstBluetooth{
//            firstBluetooth = false
//            return
//        }
//        if central.state == .poweredOff{
//
//                let action = UIAlertController(title: "Info", message: "Turn on bluetooth", preferredStyle: .alert)
//                action.addAction(UIAlertAction(title: "Yes", style: .default, handler: { UIAlertAction in
//                    let url = URL(string: "App-Prefs:root=General")
//                    let app = UIApplication.shared
//                    app.open(url!, options: [:], completionHandler: nil)
//                }))
//                action.addAction(UIAlertAction(title: "No", style: .destructive))
//                self.present(action, animated: true)
//
//        }
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
        
        let bluetoothTap = UITapGestureRecognizer(target: self, action: #selector(bluetoothTap(_:)))
        imgViewBluetooth.addGestureRecognizer(bluetoothTap)
        
        
        viewParentCamera.isUserInteractionEnabled = true
        let cameraTap = UITapGestureRecognizer(target: self, action: #selector(cameraTap(_:)))
        viewParentCamera.addGestureRecognizer(cameraTap)
        
    }
    
    @objc func cameraTap(_ sender: UITapGestureRecognizer){
//        let replaceSB = UIStoryboard(name: "ReplaceStoryboard", bundle: nil)
//        let dest = replaceSB.instantiateViewController(withIdentifier: "onlyScannerCTL") as! OnlyScannerCTL
//        dest.findTag = self
//        present(dest, animated: true)
        OnlyScannerCTL.presentOnlyScanner(viewController: self, findTagProtocol: self)
    }
    
    @objc func bluetoothTap(_ sender: UITapGestureRecognizer){
        let url = URL(string: "App-Prefs:root=General")
        let app = UIApplication.shared
        app.open(url!, options: [:], completionHandler: nil)
        
//        let action = UIAlertController(title: "Info", message: "Turn on bluetooth", preferredStyle: .alert)
//        action.addAction(UIAlertAction(title: "Yes", style: .default, handler: { UIAlertAction in
//
//        }))
//        action.addAction(UIAlertAction(title: "No", style: .destructive))
//        self.present(action, animated: true)
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
                        self.getTagFromWeb(publicAddress: theString)
                    }
                }
            }
        }
        
    }
    
    func getTagFromWeb(publicAddress: String){
//        ViewPatternMethods.showAlert(controller: self, title: "Info", message: "BLE Found, now you can Continue!", handler: UIAlertAction(title: "OK", style: .destructive))
        
        let waiting = ViewPatternMethods.waitingDialog(controller: self)
        var header = Dictionary<String, String>()
        header["Publicaddress"] = publicAddress
        
        HttpClientApi.instance().makeAPICall(url: URLS.SETUPTAG, headers: header, params: nil, method: .GET) { data, response, error in
            
//            DispatchQueue.main.async {
//                waitingAlert.dismiss(animated: false)
//            }
            
            let json = try? JSONSerialization.jsonObject(with: data!, options: [])
            
            DispatchQueue.main.async {
                waiting.dismiss(animated: true) {
                    if let j = json as? [String:Any]{
                        print(j)
                        let message = j["message"] as? String ?? ""
                        if let success = j["success"] as? String{
                            if(success == "true"){
                                if let t = j["tag"] as? [String:Any]{
                                    let theTag = TagModel(json: t, rssi: 0, uuidString: "")
                                    self.handleTagByLevel(tag: theTag)
                                }else{
                                    let _ = ViewPatternMethods.showAlert(controller: self, title: "Error", message: "This is not your tag!", handler: UIAlertAction(title: "OK", style: .destructive))
                                }
                            }else{
                                ViewPatternMethods.showAlert(controller: self, title: "Error", message: message, handler: UIAlertAction(title: "OK", style: .destructive))
                            }
                            
                        }
                    }
                }
            }
            
            
        } failure: { data, response, error in
            DispatchQueue.main.async {
//                waitingAlert.dismiss(animated: true)
                waiting.dismiss(animated: true) {
                    ViewPatternMethods.showAlert(controller: self, title: "Warning", message: "Check your Internet connection!!!", handler: UIAlertAction(title: "OK", style: .destructive))
                }
            }
            print(data)
            print(response)
            print(error)
        }

        
    }
    
    func tagNotUseSomeWhereElseDialog(){
        ViewPatternMethods.showAlert(controller: self, title: "Warning", message: "This Tag not use any where else, if you want to setup it go to setup page!", handler: UIAlertAction(title: "OK", style: .destructive))
    }
    
    func tagUseSomewhereElseDialog(tag: TagModel){
//        ViewPatternMethods.showAlert(controller: self, title: "Registered Tag", message: "QR: \()", handler: <#T##UIAlertAction#>)
        
//        QR code: 10001255500
//        Target Name: Manitor 100s
//        Rigeterd Date: 2022/10/10
//        Battery life : 70%
//        1 year. 3 months  & 23 days
        var activationDateString = ""
        let myDF = MyDateFormatter()
        let AD = myDF.getDateFromServerDate(dateString: tag.activationDate)
        if let activeDate = AD{
            activationDateString = myDF.getDateByCompleteMonthName(date: activeDate)
        }
        
        let actionController = UIAlertController(title: "Registered Tag", message: "QRCode: \(tag.publicAddress)\nTarget Name: \(tag.deviceName)\nRegistered Date: \(activationDateString)\nBattery life: \(tag.tagBatteryExpireDate)\nDo You Want To Override The Tag?", preferredStyle: .actionSheet)
        actionController.addAction(UIAlertAction(title: "YES", style: .default, handler: { UIAlertAction in
            self.checkTag = tag
            self.continueWithLevel2()
        }))
        actionController.addAction(UIAlertAction(title: "No", style: .destructive))
        self.present(actionController, animated: true, completion: nil)
    }
    
    var checkTag :TagModel?
    
//    func going2CheckInfoPage(){
//        self.performSegue(withIdentifier: "replace2checking", sender: self)
//    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "replace2checking"{
            let dest = segue.destination as! CheckReplaceInfoCTL
            dest.theTag = checkTag
            dest.publicAddress2Change = self.publicAddress2Change
        }
    }
    
    func handleTagByLevel(tag: TagModel){
        if tag.deviceName == ""{
            if level == 1{
                tagNotUseSomeWhereElseDialog()
            }
            else if level == 2{
                self.continueWithLevel2()
            }
            //TODO if we are in level 1 tell user this tag not use any where else, if we are in level 2 do routine thing
        }else{
            //TODO if level 1 routine thing, if level 2 we should show message this tag use somewhere else get ok and then keep on
            if level == 1{
                continueWithLevel1()
            }
            else if level == 2{
                self.tagUseSomewhereElseDialog(tag: tag)
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
//        self.sendChange2Web(PA1: self.publicAddress2Change!, targetPA: targetPublicAddress!)
        performSegue(withIdentifier: "replace2checking", sender: self)
        
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
