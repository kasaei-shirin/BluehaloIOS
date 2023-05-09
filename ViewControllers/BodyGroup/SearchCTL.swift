//
//  SearchCTL.swift
//  Ninox
//
//  Created by saeed on 09/05/2023.
//

import UIKit
import CoreBluetooth

class SearchCTL: UIViewController, CBCentralManagerDelegate {
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        print(central)
    }
    

    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var btnScan: UIButton!
    
    
    
    var peripherals:[CBPeripheral] = []

    var PPPs : [PeripheralWithRssiAndData] = []
    var manager:CBCentralManager? = nil
    
    
    var tags = [TagModel]()
    
    var inScanMode: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        tableView.register(UINib(nibName: "SearchItem", bundle: nil), forCellReuseIdentifier: "searchItem")
        
        let backTap = UITapGestureRecognizer(target: self, action: #selector(backTap(_:)))
        backView.isUserInteractionEnabled = true
        backView.addGestureRecognizer(backTap)
        
        
        tableView.delegate = self
        tableView.dataSource = self
        
        manager = CBCentralManager(delegate: self, queue: nil);
        
        
    }
    
    
    @objc func backTap(_ gest: UITapGestureRecognizer){
        self.dismiss(animated: true)
    }
    
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        
//        print("\(peripheral) + central : \(central.description)")
        var indexP = -1
        var i = 0
//        print("indexP before : \(indexP)")
        print("\(PPPs.count) p ")
        for item in PPPs{
            print("\(item.periPheral.identifier.uuidString) == \(peripheral.identifier.uuidString)")
            if item.periPheral.identifier.uuidString == peripheral.identifier.uuidString{
                indexP = i
            }
            i+=1
        }
        
        if(indexP == -1) {
            
            print("manfie 1 + \(PPPs.count)")
            
            //add peripheral 2 list
            let PPP = PeripheralWithRssiAndData(periPheral: peripheral, rssi: RSSI.intValue, data: advertisementData)
            PPPs.append(PPP)
            
            getFromWebThenInsertIntoList(PPP)
//            self.tableView.insertRows(at: [IndexPath(row: self.PPPs.count-1, section: 0)], with: .none)
            
        }else{

            print("before \(PPPs[indexP].rssi)")
            PPPs[indexP].rssi = RSSI.intValue
            PPPs[indexP].data = advertisementData
            
            
            self.tableView.beginUpdates()
            self.tableView.reloadRows(at: [IndexPath(row: indexP, section: 0)], with: .none)
            self.tableView.endUpdates()

        }
        
    }
    
    func getFromWebThenInsertIntoList(_ ppp: PeripheralWithRssiAndData){
        
//        HttpClientApi.instance().makeAPICall(url: URLS.SETUPTAG, headers: Dictionary<String,String>(), params: nil, method: .GET, success: { (data, response, error) in
//
//            let json = try? JSONSerialization.jsonObject(with: data!, options: [])
//
//
//
//        }) { (data, response, error) in
//            DispatchQueue.main.async {
//                if let WD = self.waitingDialog{
//                    WD.dismiss(animated: true)
//                }
//            }
//            print(data)
//            print(response)
//            print(error)
//        }
        
        let data = ppp.data["kCBAdvDataManufacturerData"] as? Data ?? Data()
        
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
//        print(dataString)
        
        
        
//        dataString.remove(at: <#T##String.Index#>)
        
//        - \(dataString) -
//        cell.textLabel?.text = "\(PFH.periPheral.name) + \(dataString)  + \(PFH.rssi)"
        
        var header = Dictionary<String, String>()
        header["Publicaddress"] = dataString
        
        HttpClientApi.instance().makeAPICall(url: URLS.SETUPTAG, headers: header, params: nil, method: .GET) { data, response, error in
            
            let json = try? JSONSerialization.jsonObject(with: data!, options: [])
            
            if let j = json as? [String:Any]{
                if let success = j["success"] as? String{
                    if(success == "true"){
                        if let t = j["tag"] as? [String:Any]{
                            self.tags.append(TagModel(json: t,rssi: ppp.rssi))
                            DispatchQueue.main.async {
                                self.tableView.insertRows(at: [IndexPath(row: self.tags.count-1, section: 0)], with: .none)
                            }
                        }
                    }
                }
            }
            
        } failure: { data, response, error in
            print(data)
            print(response)
            print(error)
        }

        
    }
    
    
    func scanBLEDevices() {
        //manager?.scanForPeripherals(withServices: [CBUUID.init(string: parentView!.BLEService)], options: nil)
        
        //if you pass nil in the first parameter, then scanForPeriperals will look for any devices.
        PPPs.removeAll()
        peripherals.removeAll()
        tableView.reloadData()
        
        inScanMode = true
        
        btnScan.setTitle("Stop", for: .normal)
        
        self.startForContinue()
        //stop scanning after 3 seconds
        
    }
    
    func startForContinue(){
        if(inScanMode){
            manager?.scanForPeripherals(withServices: nil, options: nil)
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.1) {
                self.stopForContinue()
            }
        }
    }
    
    func stopForContinue(){
        if(inScanMode){
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                self.startForContinue()
            }
        }
    }
    
    func stopScanForBLEDevices() {
        inScanMode = false
        manager?.stopScan()
        btnScan.setTitle("Start", for: .normal)
    }
    
    
    
    @IBAction func scanAction(_ sender: Any) {
        self.scanBLEDevices()
    }
    
    
}

extension SearchCTL: UITableViewDelegate, UITableViewDataSource{
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tags.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 144
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "searchItem", for: indexPath) as! SearchItem
        cell.topParent.layer.masksToBounds = true
        cell.topParent.layer.cornerRadius = 10.0
        
        let tag = tags[indexPath.row]
        cell.lblDeviceName.text = tag.deviceName
        cell.lblAlias.text = tag.alias
        
        return cell
    }
    
}
