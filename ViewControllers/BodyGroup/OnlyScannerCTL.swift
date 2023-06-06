//
//  OnlyScannerCTL.swift
//  Ninox
//
//  Created by saeed on 01/06/2023.
//

import UIKit
import AVFoundation

class OnlyScannerCTL: MyViewController, AVCaptureMetadataOutputObjectsDelegate{

    @IBOutlet weak var viewParentBack: UIView!
    @IBOutlet weak var viewParentScanner: UIView!
    
    var captureSession: AVCaptureSession!
    var previewLayer: AVCaptureVideoPreviewLayer!
    
    var findTag: TagFindProtocol?
    
    
    class func presentOnlyScanner(viewController: UIViewController, findTagProtocol: TagFindProtocol){
        let replaceStoryboard = UIStoryboard(name: "ReplaceStoryboard", bundle: nil)
        let dest = replaceStoryboard.instantiateViewController(withIdentifier: "onlyScannerCTL") as! OnlyScannerCTL
        dest.findTag = findTagProtocol
        viewController.present(dest, animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewParentBack.isUserInteractionEnabled = true
        let backTap = UIGestureRecognizer(target: self, action: #selector(backTap(_:)))
        viewParentBack.addGestureRecognizer(backTap)
    }
    
    @objc func backTap(_ sender:UITapGestureRecognizer){
        self.dismiss(animated: true)
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
        previewLayer.frame = viewParentScanner.layer.bounds
        previewLayer.videoGravity = .resizeAspectFill
        viewParentScanner.layer.addSublayer(previewLayer)
        
//
//        scannerParentView.bringSubviewToFront(imgViewQR)
    }
    
    func failed() {
     
        let ac = UIAlertController(title: "Scanning not supported", message: "Your device does not support scanning a code from an item. Please use a device with a camera.", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .destructive, handler: { UIAlertAction in
            ac.dismiss(animated: true) {
                self.dismiss(animated: true)
            }
        }))
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
    
    func found(code: String) {
//        print(code)
        let scanResult = convertToDictionary(text: code.trimmingCharacters(in: .whitespacesAndNewlines))
        if let SR = scanResult{
            if let thePA = SR["PA"] as? String{
                print("get pa as string : \(thePA)")
                if thePA != ""{
                    
                    self.dismiss(animated: true) {
                        self.findTag?.tagFinded(publicAddress: thePA, find: true)
                    }
                    return
                }
            }
        }
        
        self.dismiss(animated: true) {
            self.findTag?.tagFinded(publicAddress: "The Tag is not our company tag!", find: false)
        }
    }
    

}
