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
    var ADs : [[String:Any]] = []
    var manager:CBCentralManager? = nil
    
    
    @IBOutlet weak var tableView: UITableView!
    
    
    
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
        scanBLEDevices()
        
    }
    
    func scanBLEDevices() {
        //manager?.scanForPeripherals(withServices: [CBUUID.init(string: parentView!.BLEService)], options: nil)
        
        //if you pass nil in the first parameter, then scanForPeriperals will look for any devices.
        manager?.scanForPeripherals(withServices: nil, options: nil)
        
        //stop scanning after 3 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            self.stopScanForBLEDevices()
        }
    }
    
    func stopScanForBLEDevices() {
        manager?.stopScan()
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        
        print("-------------------------")
        
        print(" in service : ")
    
        print(service.characteristics)
        
        print(service.description)
        
        print("-------------------------")
    }
    
    
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        
        
        
        if(!peripherals.contains(peripheral)) {
            peripherals.append(peripheral)
            ADs.append(advertisementData)
            
            print("----------------------------")
            
            
            print("\(peripheral.identifier) --- \(RSSI)")
            
            print(advertisementData["kCBAdvDataManufacturerData"])
            
            
            
            
            print("----------------------------")
            
            self.tableView.reloadData()
            
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
    
        
        let AD = ADs[indexPath.row]
        
        let data = AD["kCBAdvDataManufacturerData"] as? Data ?? Data()
        
        var dataString = data.hexEncodedString()
        
        cell.textLabel?.text = "\(peripheral.name)  - \(dataString)"
        
    
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
