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
    
    @IBOutlet weak var imgViewShowMore: UIImageView!
    @IBOutlet weak var imgViewShowLess: UIImageView!
    @IBOutlet weak var imgViewSetting: UIImageView!
    @IBOutlet weak var imgViewRefresh: UIImageView!
    @IBOutlet weak var imgViewInfo: UIImageView!
    @IBOutlet weak var imgViewSearchFilter: UIImageView!
    
    
//    var cellHeight
    
    
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
        
        
        setClickListenersForTopItems()
        
    }
    
    func setClickListenersForTopItems(){
        
        imgViewShowLess.isUserInteractionEnabled = true
        imgViewShowMore.isUserInteractionEnabled = true
        imgViewInfo.isUserInteractionEnabled = true
        imgViewRefresh.isUserInteractionEnabled = true
        imgViewSetting.isUserInteractionEnabled = true
        imgViewSearchFilter.isUserInteractionEnabled = true
        
        var tap = UITapGestureRecognizer(target: self, action: #selector(collapseTap(_:)))
        imgViewShowLess.addGestureRecognizer(tap)
        
        
        tap = UITapGestureRecognizer(target: self, action: #selector(expandAllTap(_:)))
        imgViewShowMore.addGestureRecognizer(tap);
        
        tap = UITapGestureRecognizer(target: self, action: #selector(settingsTap(_:)))
        imgViewSetting.addGestureRecognizer(tap)
        
        tap = UITapGestureRecognizer(target: self, action: #selector(refreshTap(_:)))
        imgViewRefresh.addGestureRecognizer(tap)
        
        tap = UITapGestureRecognizer(target: self, action: #selector(infoTap(_:)))
        imgViewInfo.addGestureRecognizer(tap)
        
        tap = UITapGestureRecognizer(target: self, action: #selector(searchFilter(_:)))
        imgViewSearchFilter.addGestureRecognizer(tap)
    }
    
    @objc func searchFilter(_ tap: UITapGestureRecognizer){
        
    }
    @objc func infoTap(_ tap: UITapGestureRecognizer){
        
    }
    @objc func refreshTap(_ tap: UITapGestureRecognizer){
        
    }
    @objc func collapseTap(_ tap: UITapGestureRecognizer){
        
    }
    @objc func expandAllTap(_ tap: UITapGestureRecognizer){
        
    }
    @objc func settingsTap(_ tap: UITapGestureRecognizer){
        
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
            
            indexP = -1
            i = 0
            for item in tags{
                
                if item.uuid == peripheral.identifier.uuidString{
                    indexP = i
                }
                i+=1
            }
            
            if indexP != -1{
                tags[indexP].rssi = RSSI.intValue
                self.tableView.beginUpdates()
                self.tableView.reloadRows(at: [IndexPath(row: indexP, section: 0)], with: .none)
                self.tableView.endUpdates()
            }

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
        header["Publicaddress"] = theString
        
        HttpClientApi.instance().makeAPICall(url: URLS.SETUPTAG, headers: header, params: nil, method: .GET) { data, response, error in
            
            let json = try? JSONSerialization.jsonObject(with: data!, options: [])
            
            if let j = json as? [String:Any]{
                print(j)
                if let success = j["success"] as? String{
                    if(success == "true"){
                        if let t = j["tag"] as? [String:Any]{
                            self.tags.append(TagModel(json: t,rssi: ppp.rssi, uuidString: ppp.periPheral.identifier.uuidString))
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
        tags.removeAll()
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
        if(inScanMode){
            stopScanForBLEDevices()
        }else{
            scanBLEDevices()
        }
    }
    
    
}

extension SearchCTL: UITableViewDelegate, UITableViewDataSource{
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tags.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 124 + 20
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "searchItem", for: indexPath) as! SearchItem
        cell.topParent.layer.masksToBounds = true
        cell.topParent.layer.cornerRadius = 10.0
        
        let tag = tags[indexPath.row]
        cell.lblDeviceName.text = tag.deviceName
        cell.lblAlias.text = tag.alias
        cell.lblRSSI.text = "\(tag.rssi)"
        
        if tag.rssi <= -10 && tag.rssi >= -50{
            cell.sliderRSSI.setValue(100, animated: false)
        }else if tag.rssi <= -51 && tag.rssi >= -62{
            cell.sliderRSSI.setValue(75, animated: false)
        }else if tag.rssi <= -63 && tag.rssi >= -70{
            cell.sliderRSSI.setValue(50, animated: false)
        }else if tag.rssi <= -71 && tag.rssi >= -80{
            cell.sliderRSSI.setValue(25, animated: false)
        }else{
            cell.sliderRSSI.setValue(0, animated: false)
        }
        
        return cell
    }
    
}
