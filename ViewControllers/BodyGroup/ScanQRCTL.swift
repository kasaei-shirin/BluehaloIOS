//
//  ScanQRCTL.swift
//  Ninox
//
//  Created by saeed on 11/05/2023.
//

import UIKit
import AVFoundation
import CoreBluetooth

class ScanQRCTL: UIViewController, AVCaptureMetadataOutputObjectsDelegate, CBCentralManagerDelegate {
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        print(central)
    }
    
    
    @IBOutlet weak var skipBtn: UIButton!
    
    @IBOutlet weak var scannerParentView: UIView!
    @IBOutlet weak var imgViewQR: UIImageView!
    
    @IBOutlet weak var btnScan: UIButton!
    
    @IBOutlet weak var backParentView: UIView!
    
    var targetJob: String?
    var fromWhere: String?
    
    var theTag: TagModel?
    var tagIndexpath: IndexPath?
    var editProtocol: EditActionProtocol?
    
    //send tag and indexpath for edit to here and also protocol to update list at last
    
    var ScannedQRCodePA: String?
    
    
    var captureSession: AVCaptureSession!
    var previewLayer: AVCaptureVideoPreviewLayer!
    
    
    
    var peripherals:[CBPeripheral] = []
//    var ADs : [[String:Any]] = []
    var PPPs : [PeripheralWithRssiAndData] = []
    var manager:CBCentralManager? = nil
    
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        
//        print("\(peripheral) + central : \(central.description)")
        var indexP = -1
        var i = 0
//        print("indexP before : \(indexP)")
//        print("\(PPPs.count) p ")
        for item in PPPs{
//            print("\(item.periPheral.identifier.uuidString) == \(peripheral.identifier.uuidString)")
            if item.periPheral.identifier.uuidString == peripheral.identifier.uuidString{
                indexP = i
            }
            i+=1
        }
        
        if(indexP == -1) {
            
//            print("manfie 1 + \(PPPs.count)")
            
            //add peripheral 2 list
            
            PPPs.append(PeripheralWithRssiAndData(periPheral: peripheral, rssi: RSSI.intValue, data: advertisementData))
            
            let data = advertisementData["kCBAdvDataManufacturerData"] as? Data ?? Data()
            
            var dataString = data.hexEncodedString()
            if(dataString.count > 5){
                dataString.removeFirst(4)
            }
            
            if(!dataString.starts(with: "06")){
                return
            }
            
//            print(dataString)
            
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
            print("SQ \(ScannedQRCodePA)")
            if let SQ = ScannedQRCodePA{
                let sq = SQ.uppercased()
                if theString == sq{
                    DispatchQueue.main.async {
                        self.manager?.stopScan()
                        self.getPAFromWeb(theString: sq)
                    }
                }
            }
        }
        
    }
    
    func getPAFromWeb(theString: String){
        
        
//        let waitingAlert = ViewPatternMethods.waitingDialog(controller: self)
        
        var header = Dictionary<String, String>()
        header["Publicaddress"] = theString
        
        HttpClientApi.instance().makeAPICall(url: URLS.SETUPTAG, headers: header, params: nil, method: .GET) { data, response, error in
            
//            DispatchQueue.main.async {
//                waitingAlert.dismiss(animated: false)
//            }
            
            let json = try? JSONSerialization.jsonObject(with: data!, options: [])
            
            if let j = json as? [String:Any]{
                print(j)
                if let success = j["success"] as? String{
                    DispatchQueue.main.async {
                        if(success == "true"){
                            if let t = j["tag"] as? [String:Any]{
                                self.chooseActionAfterFetchEveryData(tagExists: true)
                            }else{
                                ViewPatternMethods.showAlert(controller: self, title: "Error", message: "This is not your tag!", handler: UIAlertAction(title: "OK", style: .destructive))
                            }
                        }else{
                            self.chooseActionAfterFetchEveryData(tagExists: false)
                        }
                    }
                    
                }
            }
            
        } failure: { data, response, error in
            DispatchQueue.main.async {
//                waitingAlert.dismiss(animated: true)
                ViewPatternMethods.showAlert(controller: self, title: "Warning", message: "Check your Internet connection!!!", handler: UIAlertAction(title: "OK", style: .destructive))
            }
            print(data)
            print(response)
            print(error)
        }

    }
    
    func chooseActionAfterFetchEveryData(tagExists: Bool){
        print("tagExists : \(tagExists)")
        if targetJob == "setup" && self.fromWhere == "home"{
            if(tagExists){
                let alertCTL = UIAlertController(title: "Info", message: "The Tag Doesn't Exists Do You Want To Going To Setup Page?", preferredStyle: .actionSheet)
                alertCTL.addAction(UIAlertAction(title: "Cancle", style: .cancel, handler: { UIAlertAction in
                    alertCTL.dismiss(animated: false)
                }))
                alertCTL.addAction(UIAlertAction(title: "OK", style: .default, handler: { UIAlertAction in
                    alertCTL.dismiss(animated: false)
                    //it is scan to edit (because we want to show dialog we implement this part like this
                    self.performSegue(withIdentifier: "scan2setup", sender: self)
                }))
                self.present(alertCTL, animated: true)
                  
            }else{
                self.performSegue(withIdentifier: "scan2setup", sender: self)
            }
        }
        else if targetJob == "edit" && self.fromWhere == "home"{
            if(tagExists){
                //the below is scan2edit too
                self.performSegue(withIdentifier: "scan2setup", sender: self)
            }else{
                let alertCTL = UIAlertController(title: "Info", message: "The Tag Doesn't Exists Do You Want To Going To Setup Page?", preferredStyle: .actionSheet)
                alertCTL.addAction(UIAlertAction(title: "Cancle", style: .cancel, handler: { UIAlertAction in
                    alertCTL.dismiss(animated: false)
                }))
                alertCTL.addAction(UIAlertAction(title: "OK", style: .default, handler: { UIAlertAction in
                    alertCTL.dismiss(animated: false)
                    self.performSegue(withIdentifier: "scan2setup", sender: self)
                }))
                self.present(alertCTL, animated: true)
                //showDialog2Going2Setup()
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "scan2setup"{
            let dest = segue.destination as! SetupEditCTL
            dest.fromWhere = self.fromWhere
            dest.targetJob = self.targetJob
            dest.publicAddress = self.ScannedQRCodePA
            if let tag = theTag{
                dest.publicAddress = tag.publicAddress
                dest.theTag = tag
                dest.indexPath = self.tagIndexpath
                dest.editProtocol = self
            }
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        manager = CBCentralManager(delegate: self, queue: nil)
        
        
        let backTap = UITapGestureRecognizer(target: self, action: #selector(backTap(_:)))
        backParentView.isUserInteractionEnabled = true
        backParentView.addGestureRecognizer(backTap)
        
        if fromWhere == "search"{
            skipBtn.isHidden = false
        }else{
            skipBtn.isHidden = true
        }
        
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        buildQRScanner()
    }
    
    func buildQRScanner(){
        captureSession = AVCaptureSession()

        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else { return }
        let videoInput: AVCaptureDeviceInput

        do {
            videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
        } catch {
            return
        }

        if (captureSession.canAddInput(videoInput)) {
            captureSession.addInput(videoInput)
        } else {
            failed()
            return
        }

        let metadataOutput = AVCaptureMetadataOutput()

        if (captureSession.canAddOutput(metadataOutput)) {
            captureSession.addOutput(metadataOutput)

            metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            metadataOutput.metadataObjectTypes = [.qr]
        } else {
            failed()
            return
        }

        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = scannerParentView.layer.bounds
        previewLayer.videoGravity = .resizeAspectFill
        scannerParentView.layer.addSublayer(previewLayer)
        

        scannerParentView.bringSubviewToFront(imgViewQR)
    }
    
    
    func failed() {
     
        let ac = UIAlertController(title: "Scanning not supported", message: "Your device does not support scanning a code from an item. Please use a device with a camera.", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        present(ac, animated: true)
        captureSession = nil
    }

    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        captureSession.stopRunning()

        if let metadataObject = metadataObjects.first {
            guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject else { return }
            guard let stringValue = readableObject.stringValue else { return }
            AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
//            dismiss(animated: true, completion: nil)
         //if founding code this method will be call
            found(code: stringValue)
        }
        
    }
    
    func going2EditAction(){
        performSegue(withIdentifier: "scan2setup", sender: self)
    }
    
    
    func found(code: String) {
        print(code)
        
        
        
        imgViewQR.image = UIImage(systemName: "qrcode")
        previewLayer.isHidden = true
        
        let scanResult = convertToDictionary(text: code.trimmingCharacters(in: .whitespacesAndNewlines))
        
        
        if let SR = scanResult{
            if let thePA = SR["PA"] as? String{
                print("get pa as string : \(thePA)")
                if thePA != ""{
//                    getPAFromWeb(theString: thePA)
                    if fromWhere == "home"{
                        self.ScannedQRCodePA = thePA
                        self.startScanForPrepheral()
                    }
                    else{
                        if thePA == theTag?.publicAddress{
                            going2EditAction()
                        }else{
                            ViewPatternMethods.showAlert(controller: self, title: "Error", message: "Your Target tag PublicAddress is diffrence from what you scanned!", handler: UIAlertAction(title: "OK", style: .destructive))
                        }
                    }
                }
                else{
                    let _ = ViewPatternMethods.showAlert(controller: self, title: "Warning", message: "QRCode problem!!!", handler: UIAlertAction(title: "OK", style: .destructive))
                }
            }
        }else{
            let _ = ViewPatternMethods.showAlert(controller: self, title: "Warning", message: "It's not our TAG QRCode.", handler: UIAlertAction(title: "OK", style: .destructive))
        }
        
        
     
    }
    
    func startScanForPrepheral(){
        manager?.scanForPeripherals(withServices: nil, options: nil)
        DispatchQueue.main.asyncAfter(deadline: .now() + 4.0) {
            self.manager?.stopScan()
            let _ = ViewPatternMethods.showAlert(controller: self, title: "Warning", message: "The BLE Device that scanned, not exists in your prepheral.", handler: UIAlertAction(title: "OK", style: .destructive))
        }
    }
    
    
    func convertToDictionary(text: String) -> [String: Any]? {
        if let data = text.data(using: .utf8) {
            do {
//                let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String:AnyObject]
                let value = try JSONSerialization.jsonObject(with: data, options: [.json5Allowed]) as? [String: Any]
                print(value)
                return value
            } catch {
                print("in catch")
                print(error.localizedDescription)
            }
        }
        return nil
    }

    
    
    @objc func backTap(_ sender: UITapGestureRecognizer){
        self.dismiss(animated: true)
    }
    
    @IBAction func skipAction(_ sender: Any) {
        going2EditAction()
    }
    
    @IBAction func scanAction(_ sender: Any) {
        
//        performSegue(withIdentifier: "scan2setup", sender: self)
        
        imgViewQR.image = UIImage.gifImageWithName("qr_code_scan_gif")
        previewLayer.isHidden = false
        captureSession.startRunning()
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    
    override func viewWillDisappear(_ animated: Bool) {
        self.manager?.stopScan()
    }

}

extension ScanQRCTL: EditActionProtocol{
    func edited(tag: TagModel, indexPath: IndexPath) {
        self.editProtocol?.edited(tag: tag, indexPath: indexPath)
        self.dismiss(animated: true)
    }
}
