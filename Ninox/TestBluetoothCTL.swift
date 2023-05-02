//
//  TestBluetoothCTL.swift
//  Ninox
//
//  Created by saeed on 25/04/2023.
//

import UIKit
import CoreBluetooth

class TestBluetoothCTL: UIViewController, CBCentralManagerDelegate {
    
    var peripherals:[CBPeripheral] = []
//    var ADs : [[String:Any]] = []
    var PPPs : [PeripheralWithRssiAndData] = []
    var manager:CBCentralManager? = nil
    
    var labels = [Int:UILabel?]()
    
    var inScanMode: Bool = false
    
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var btnScan: UIButton!
    
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        print(central.state)
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()

        manager = CBCentralManager(delegate: self, queue: nil);
        
        tableView.delegate = self
        tableView.dataSource = self
        // Do any additional setup after loading the view.
        
    }
    
    
    @IBAction func scanAction(_ sender: Any) {
        if(inScanMode){
            stopScanForBLEDevices()
        }else{
            scanBLEDevices()
        }
    }
    
    func scanBLEDevices() {
        //manager?.scanForPeripherals(withServices: [CBUUID.init(string: parentView!.BLEService)], options: nil)
        
        //if you pass nil in the first parameter, then scanForPeriperals will look for any devices.
        inScanMode = true
        
        btnScan.setTitle("Stop", for: .normal)
        
        self.startForContinue()
        //stop scanning after 3 seconds
        
    }
    
    func startForContinue(){
        if(inScanMode){
            manager?.scanForPeripherals(withServices: nil, options: nil)
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                self.stopForContinue()
            }
        }
    }
    
    func stopForContinue(){
        if(inScanMode){
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.startForContinue()
            }
        }
    }
    
    func stopScanForBLEDevices() {
        inScanMode = false
        manager?.stopScan()
        btnScan.setTitle("Start", for: .normal)
    }
    
//    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
//
//        print("-------------------------")
//
//        print(" in service : ")
//
//        print(service.characteristics)
//
//        print(service.description)
//
//        print("-------------------------")
//    }
    
    
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        
        
        var indexP = -1
        var i = -1
        print("indexP before : \(indexP)")
        for item in PPPs{
            if item.periPheral.identifier.uuidString == peripheral.identifier.uuidString{
                indexP = i
            }
            i+=1
        }
        
        if(indexP == -1) {
            
            //add peripheral 2 list
            
            peripherals.append(peripheral)
            PPPs.append(PeripheralWithRssiAndData(periPheral: peripheral, rssi: Int(RSSI), data: advertisementData))
            
            
            
//            print("----------------------------")
//
//
//            print("\(peripheral.identifier) --- \(RSSI)")
//
//            print(advertisementData["kCBAdvDataManufacturerData"])
//
//
//
//
//            print("----------------------------")
            
//            self.tableView.insertRows(at: [IndexPath()], with: <#T##UITableView.RowAnimation#>)
//            DispatchQueue.main.async {
//
//            }
            self.tableView.beginUpdates()
            self.tableView.insertRows(at: [IndexPath(row: self.PPPs.count-1, section: 0)], with: .none)
            self.tableView.endUpdates()
            
        }else{
//            let indexP = peripherals.firstIndex(of: peripheral)!
            
            
            
            print("indexP update : \(indexP)")
            
            if(indexP != -1){
                print("before \(PPPs[indexP].rssi)")
                PPPs[indexP].rssi = Int(RSSI)
                print("after \(PPPs[indexP].rssi)")
                let visibles = self.tableView.indexPathsForVisibleRows
                //            for item in visibles!{
                //
                //            }
                
                self.tableView.beginUpdates()
                
                self.tableView.reloadRows(at: [IndexPath(row: indexP, section: 0)], with: .none)
                self.tableView.endUpdates()
//                DispatchQueue.main.async {
//
//                }
            }
            
            
            // update rssi
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


extension TestBluetoothCTL: UITableViewDelegate, UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return peripherals.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "scanTableCell", for: indexPath)
        let peripheral = peripherals[indexPath.row]
    
        
        
        let PFH = PPPs[indexPath.row]
        
        let data = PFH.data["kCBAdvDataManufacturerData"] as? Data ?? Data()
        
        var dataString = data.hexEncodedString()
        
        print("update indexPath \(indexPath.row)")
        
//        - \(dataString) -
        cell.textLabel?.text = "\(PFH.periPheral.name)  + \(PFH.rssi)"
        
        labels[indexPath.row] = cell.textLabel
    
//        cell.textLabel?.numberOfLines = 8
        
        return cell
        
    }
    
    
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    
}


extension Data {
    struct HexEncodingOptions: OptionSet {
        let rawValue: Int
        static let upperCase = HexEncodingOptions(rawValue: 1 << 0)
    }

    func hexEncodedString(options: HexEncodingOptions = []) -> String {
        let format = options.contains(.upperCase) ? "%02hhX" : "%02hhx"
        return self.map { String(format: format, $0) }.joined()
    }
}


class PeripheralWithRssiAndData{
    
    var periPheral: CBPeripheral
    var rssi: Int
    var data: [String:Any]
    
    init(periPheral: CBPeripheral, rssi: Int, data: [String:Any]) {
        self.periPheral = periPheral
        self.rssi = rssi
        self.data = data
    }
}
