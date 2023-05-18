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
    
    var searchItemExpand = Dictionary<String,Bool>()
    var customInfoMoreExpand = Dictionary<String,Bool>()
    var serviceDateMoreExpand = Dictionary<String, Bool>()
    
    
    var peripherals:[CBPeripheral] = []

    var PPPs : [PeripheralWithRssiAndData] = []
    var manager:CBCentralManager? = nil
    
    var customTables = [CustomInfoTableModel]()
    var serviceTables = [ServiceDateTableModel]()
    
    var RSSILabels = Dictionary<String, UILabel>()
    var RSSISliders = Dictionary<String, UISlider>()
    
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
        PPPs.removeAll()
        peripherals.removeAll()
        tags.removeAll()
        searchItemExpand.removeAll()
        tableView.reloadData()
        
    }
    @objc func collapseTap(_ tap: UITapGestureRecognizer){
        for item in self.tags{
            self.searchItemExpand.removeValue(forKey: item.publicAddress)
        }
        self.tableView.reloadData()
    }
    @objc func expandAllTap(_ tap: UITapGestureRecognizer){
        for item in self.tags{
            self.searchItemExpand[item.publicAddress] = true
        }
        self.tableView.reloadData()
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
            let PPP = PeripheralWithRssiAndData(periPheral: peripheral, rssi: RSSI.intValue, data: advertisementData)
            PPPs.append(PPP)
            
            getFromWebThenInsertIntoList(PPP)
//            self.tableView.insertRows(at: [IndexPath(row: self.PPPs.count-1, section: 0)], with: .none)
            
        }else{

//            print("before \(PPPs[indexP].rssi)")
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
                self.editRSSIOnTabelView(row: indexP)
//                self.tableView.beginUpdates()
//                self.tableView.reloadRows(at: [IndexPath(row: indexP, section: 0)], with: .none)
//                self.tableView.endUpdates()
            }

        }
        
    }
    
    func editRSSIOnTabelView(row: Int){
        var exists = false
        let indexess = self.tableView.indexPathsForVisibleRows
        if let indexes = indexess{
            for item in indexes{
                if item.row == row{
                    exists = true
                    break
                }
            }
        }
        
        if exists{
            let theTag = self.tags[row]
            self.RSSILabels[theTag.publicAddress]?.text = "\(theTag.rssi)"
            self.RSSISliders[theTag.publicAddress]?.setValue(self.getValueFromRSSI(rssi: theTag.rssi), animated: false)
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
//                print(j)
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

extension SearchCTL: UITableViewDelegate, UITableViewDataSource, FlagNoteProtocol{
    func flagNoteText(note: String, indexPath: IndexPath) {
        updateTableViewInRow(indexPath.row)
    }
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if tableView == self.tableView{
            return tags.count
        }
        
        if tableView.tag == 1{
            
            for item in self.serviceTables{
                if item.tableView == tableView{
                    print("return \(item.data.count) for service tables")
                    return item.data.count
                }
            }
            return 0
        }//tag 2 = tableview customInfo
        else {
            var i = 0
            for item in self.customTables{
                print("cus info \(i)")
                if item.tableView == tableView{
                    print("return \(item.data.count) for custom tables")
                    return item.data.count
                }
                i += 1
            }
            return 0
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if tableView == self.tableView{
            
            //20 is destination to bottom view
            //124 is top view height
            //bottom view must calculate with a method
            
            return CGFloat(getRowheight(tag: tags[indexPath.row]))
        }
        return 35
        //tag1 = tableView service dates
//        if tableView.tag == 1{
//            return 35
//        }
//        //tag 2 = tableview customInfo
//        else tableView.tag == 2{
//
//        }
    }
    
    func getRowheight(tag: TagModel)->Int{
        if let _ = self.searchItemExpand[tag.publicAddress]{
            return 144+calculateBottomViewHeight(tag: tag)
        }else{
            return 144
        }
    }
    
    func calculateBottomViewHeight(tag: TagModel)->Int{
        //350 is minimum height of bottom view height
        var theBottomHeight = 350
        
        //1 is top border
        //20 is (Service Date) Title
        //35 is every row height
        //20 is more> height
        //24 is vertical stack view space 4*8
//        1+20+tag.targetServiceDates.count * 35 + 20 + 32
        
        //the numbers of above formula will be 73
        
        
        if tag.targetServiceDates.count > 0{
            theBottomHeight += 73 + (tag.targetServiceDates.count*35)
        }
        if tag.targetCustomInfos.count > 0{
            theBottomHeight += 73 + (tag.targetCustomInfos.count*35)
        }
        return theBottomHeight
    }
    
    func getValueFromRSSI(rssi: Int)->Float{
        if rssi <= -10 && rssi >= -50{
//            cell.sliderRSSI.setValue(100, animated: false)
            return 100
        }else if rssi <= -51 && rssi >= -62{
//            cell.sliderRSSI.setValue(75, animated: false)
            return 75
        }else if rssi <= -63 && rssi >= -70{
//            cell.sliderRSSI.setValue(50, animated: false)
            return 50
        }else if rssi <= -71 && rssi >= -80{
//            cell.sliderRSSI.setValue(25, animated: false)
            return 25
        }else{
//            cell.sliderRSSI.setValue(0, animated: false)
            return 0
        }
    }
    
    
    func manageSearchItem(cell: SearchItem, tag: TagModel, indexPath: IndexPath)-> SearchItem{
        
        cell.sliderRSSI.isUserInteractionEnabled = false
        
        self.RSSILabels[tag.publicAddress] = cell.lblRSSI
        self.RSSISliders[tag.publicAddress] = cell.sliderRSSI
        
        if tag.targetServiceDates.count == 0{
            cell.serviceDateTopBorderHeight.constant = 0
            cell.serviceDateTitleHeight.constant = 0
            cell.serviceDateTableHeight.constant = 0
            cell.serviceDateMoreHeight.constant = 0
            cell.serviceDateTopBorder.isHidden = true
        }
        else{
            cell.serviceDateTopBorderHeight.constant = 17
            cell.serviceDateTitleHeight.constant = 20
            cell.serviceDateTableHeight.constant = CGFloat(tag.targetServiceDates.count*35)
            cell.serviceDateMoreHeight.constant = 20
            cell.serviceDateTopBorder.isHidden = false
        }
        if tag.targetCustomInfos.count == 0{
            cell.customInfoTopBorderHeight.constant = 0
            cell.customInfoTitleHeight.constant = 0
            cell.tableViewCustomInfoHeight.constant = 0
            cell.customInfoMoreheight.constant = 0
            cell.customInfoTopBorder.isHidden = true
        }else{
            cell.customInfoTopBorderHeight.constant = 17
            cell.customInfoTitleHeight.constant = 20
            cell.tableViewCustomInfoHeight.constant = CGFloat(tag.targetCustomInfos.count*35)
            cell.customInfoMoreheight.constant = 20
            cell.customInfoTopBorder.isHidden = false
        }
        
        
        if let _ = self.searchItemExpand[tag.publicAddress]{
            cell.viewParentOfExpandination.isHidden = false
        }else{
            cell.viewParentOfExpandination.isHidden = true
        }
        
        cell.viewExpandParent.isUserInteractionEnabled = true
        let expandTap = UITapGestureRecognizer(target: self, action: #selector(expandClicked(_:)))
        expandTap.view?.tag = indexPath.row
        cell.viewExpandParent.addGestureRecognizer(expandTap)
        
        cell.topParent.layer.masksToBounds = true
        cell.topParent.layer.cornerRadius = 10.0
        
        
        cell.lblDeviceName.text = tag.deviceName
        cell.lblAlias.text = tag.alias
        cell.lblRSSI.text = "\(tag.rssi)"
        
        
        cell.sliderRSSI.setValue(getValueFromRSSI(rssi: tag.rssi), animated: false)
        
        cell.taviewViewServiceDate.tag = 1
        cell.tableViewCustomInfo.tag = 2
        
//        cell.taviewViewServiceDate.register(UINib(nibName: "ServiceDateSPCell", bundle: nil), forCellReuseIdentifier: "serviceDateCell")
//        cell.tableViewCustomInfo.register(UINib(nibName: "CustomInfoSPCell", bundle: nil), forCellReuseIdentifier: "customInfoCell")
        
        print("RestID : \(cell.tableViewCustomInfo.restorationIdentifier) - \(tag.publicAddress)")
        
        
//        self.customTables.append()
//        self.serviceTables.append()
        
        cell.taviewViewServiceDate.separatorColor = UIColor.white
        cell.tableViewCustomInfo.separatorColor = UIColor.white
        
        if tag.flagType == 1 {
            cell.btnGreenFlag.configuration = .tinted()
            cell.btnGreenFlag.setImage(UIImage(named: "flag_icon"), for: .normal)
        }
        else if tag.flagType == 2{
            cell.btnYellowFlag.configuration = .tinted()
            cell.btnYellowFlag.setImage(UIImage(named: "flag_icon"), for: .normal)
        }
        else{
            cell.btnOrangeFlag.configuration = .tinted()
            cell.btnOrangeFlag.setImage(UIImage(named: "flag_icon"), for: .normal)
//            cell.btnOrangeFlag.backgroundColor = UIColor.orange
//            cell.btnOrangeFlag.layer.fillMode = true
        }
        
        
        cell.lblMoreCustomInfo.isUserInteractionEnabled = true
        cell.lblMoreServiceDate.isUserInteractionEnabled = true
        
        let customInfoMoreTap = UITapGestureRecognizer(target: self, action: #selector(customInfoMoreTap(_:)))
        customInfoMoreTap.view?.tag = indexPath.row
        ///TODO make it true (uncomment then)
//        cell.lblMoreCustomInfo.addGestureRecognizer(customInfoMoreTap)
        
        let serviceDateMoreTap = UITapGestureRecognizer(target: self, action: #selector(serviceDateMoreTap(_:)))
        serviceDateMoreTap.view?.tag = indexPath.row
        ///TODO make it true (uncomment then)
//        cell.lblMoreServiceDate.addGestureRecognizer(serviceDateMoreTap)
        
        cell.lblFlagNote.isUserInteractionEnabled = true
        cell.lblFlagNote.text = tag.flagNote
        
        let flagNoteTap = UITapGestureRecognizer(target: self, action: #selector(flagNoteTap(_:)))
        flagNoteTap.view?.tag = indexPath.row
        cell.lblFlagNote.addGestureRecognizer(flagNoteTap)
        
//        addCustomTableModel(CustomInfoTableModel(tableView: cell.tableViewCustomInfo, data: tag.targetCustomInfos, publicAddress: tag.publicAddress), cell: cell)
//        addServiceTableModel(ServiceDateTableModel(tableView: cell.taviewViewServiceDate, data: tag.targetServiceDates, publicAddress: tag.publicAddress), cell: cell)
        
        
//        cell.btnGreenFlag.addAction(UIAction(handler: { UIAction in
//            self.callFlagAPI(pa: tag.publicAddress, row: indexPath.row, flagType: 1)
//        }), for: .touchUpInside)
//        
//        cell.btnYellowFlag.addAction(UIAction(handler: { UIAction in
//            self.callFlagAPI(pa: tag.publicAddress, row: indexPath.row, flagType: 2)
//        }), for: .touchUpInside)
//        
//        cell.btnGreenFlag.addAction(UIAction(handler: { UIAction in
//            self.callFlagAPI(pa: tag.publicAddress, row: indexPath.row, flagType: 3)
//        }), for: .touchUpInside)
        
        return cell
    }
    
//    func callFlagAPI(
    
    
    func addCustomTableModel(_ customInfoTableModel: CustomInfoTableModel, cell: SearchItem){
        var check = true
        for item in self.customTables {
            if item.publicAddress == customInfoTableModel.publicAddress{
//                cell.tableViewCustomInfo.register(UINib(nibName: "CustomInfoSPCell", bundle: nil), forCellReuseIdentifier: "customInfoCell")
//                cell.tableViewCustomInfo.delegate = self
//                cell.tableViewCustomInfo.dataSource = self
//                cell.tableViewCustomInfo.reloadData()
                check = false
                break
            }
        }
        if check {
            self.customTables.append(customInfoTableModel)
            cell.tableViewCustomInfo.register(UINib(nibName: "CustomInfoSPCell", bundle: nil), forCellReuseIdentifier: "customInfoCell")
            cell.tableViewCustomInfo.delegate = self
            cell.tableViewCustomInfo.dataSource = self
            cell.tableViewCustomInfo.reloadData()
            print("here in reload custom table")
            
        }
    }
    
    func addServiceTableModel(_ serviceDateTableModel: ServiceDateTableModel, cell: SearchItem){
        var check = true
        for item in self.serviceTables{
            if item.publicAddress == serviceDateTableModel.publicAddress{
//                cell.taviewViewServiceDate.register(UINib(nibName: "ServiceDateSPCell", bundle: nil), forCellReuseIdentifier: "serviceDateCell")
//                cell.taviewViewServiceDate.delegate = self
//                cell.taviewViewServiceDate.dataSource = self
//                cell.taviewViewServiceDate.reloadData()
                check = false
                break
            }
        }
        if check {
            self.serviceTables.append(serviceDateTableModel)
            cell.taviewViewServiceDate.register(UINib(nibName: "ServiceDateSPCell", bundle: nil), forCellReuseIdentifier: "serviceDateCell")
            cell.taviewViewServiceDate.delegate = self
            cell.taviewViewServiceDate.dataSource = self
            cell.taviewViewServiceDate.reloadData()
            print("here in reload service date")
        }
    }
    
    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if tableView == self.tableView{
            let tag = tags[indexPath.row]
            let theCell = cell as! SearchItem
            addCustomTableModel(CustomInfoTableModel(tableView: theCell.tableViewCustomInfo, data: tag.targetCustomInfos, publicAddress: tag.publicAddress), cell: theCell)
            addServiceTableModel(ServiceDateTableModel(tableView: theCell.taviewViewServiceDate, data: tag.targetServiceDates, publicAddress: tag.publicAddress), cell: theCell)
        }
    }
    
    @objc func flagNoteTap(_ sender: UITapGestureRecognizer){
        print( "indexPath clicked = \(sender.view?.tag)")
        let storyboard = UIStoryboard(name: "dialogStoryboard", bundle: nil)
        let flagNoteCTL = storyboard.instantiateViewController(withIdentifier: "FlagNoteCTL") as! FlagNoteController
        flagNoteCTL.flagNoteProtocol = self
        flagNoteCTL.indexPath = IndexPath(row: sender.view!.tag, section: 0)
//        guard let splashCTL = storyboard.instantiateInitialViewController() else { return }
        self.present(flagNoteCTL, animated: true)
    }
    
    
    @objc func serviceDateMoreTap(_ sender: UITapGestureRecognizer){
        if let row = sender.view?.tag{
            let result = self.serviceDateMoreExpand[self.tags[row].publicAddress]
            if let _ = result{
                closeServiceDatesIn(row)
            }else{
                openServiceDatesIn(row)
            }
        }
    }
    
    
    @objc func customInfoMoreTap(_ sender: UITapGestureRecognizer){
        if let row = sender.view?.tag{
            let result = self.customInfoMoreExpand[self.tags[row].publicAddress]
            if let _ = result{
                closeCustomInfoIn(row)
            }else{
                openCustomInfoIn(row)
            }
        }
    }
    
    func closeServiceDatesIn(_ row: Int){
        self.serviceDateMoreExpand.removeValue(forKey: self.tags[row].publicAddress)
        updateTableViewInRow(row)
    }
    
    func updateTableViewInRow(_ row: Int){
        self.tableView.beginUpdates()
        self.tableView.reloadRows(at: [IndexPath(row: row, section: 0)], with: .none)
        self.tableView.endUpdates()
    }
    
    func openServiceDatesIn(_ row: Int){
        self.serviceDateMoreExpand[self.tags[row].publicAddress] = true
        updateTableViewInRow(row)
    }
    
    func closeCustomInfoIn(_ row: Int){
        self.customInfoMoreExpand.removeValue(forKey: self.tags[row].publicAddress)
        updateTableViewInRow(row)
    }
    
    func openCustomInfoIn(_ row: Int){
        self.customInfoMoreExpand[self.tags[row].publicAddress] = true
        updateTableViewInRow(row)
    }
    
    @objc func expandClicked(_ sender: UITapGestureRecognizer){
        let row = sender.view?.tag
        if let r = row{
            let isTagExpanded = self.searchItemExpand[self.tags[r].publicAddress] ?? false
            
            if !isTagExpanded{
                self.searchItemExpand[self.tags[r].publicAddress] = true
            }else{
                self.searchItemExpand.removeValue(forKey: self.tags[r].publicAddress)
            }
            
            self.tableView.beginUpdates()
            self.tableView.reloadRows(at: [IndexPath(row: r, section: 0)], with: .none)
            self.tableView.endUpdates()
        }
    }
    
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if tableView == self.tableView{
            let cell = tableView.dequeueReusableCell(withIdentifier: "searchItem", for: indexPath) as! SearchItem
            let tag = tags[indexPath.row]
            
            return manageSearchItem(cell: cell, tag: tag, indexPath: indexPath)
        }
        
        //tag1 = tableView service dates
        
        if tableView.tag == 1{
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "serviceDateCell", for: indexPath) as! ServiceDateSPCell
            
            for item in self.serviceTables{
                print(item.publicAddress)
                if item.tableView == tableView{
                    print("tableview ha barabar shod dar service date")
                    print("index path : \(indexPath.row)")
                    print(item.data[indexPath.row].title)
//                    print(item.data[indexPath.row].info)
                    let itemData = item.data[indexPath.row]
                    cell.lblTitle.text = itemData.title
                    cell.lblDate.text = MyDateFormatter().getDateByCompleteMonthName(date: itemData.date)
                    return cell
                }
            }
            
            return cell
        }//tag 2 = tableview customInfo
        else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "customInfoCell", for: indexPath) as! CustomInfoSPCell
            for item in self.customTables{
                print("countesh : \(item.data.count)")
                if item.tableView == tableView{
                    print("tableview ha barabar shod dar custom info")
                    let itemData = item.data[indexPath.row]
                    cell.lblTitle.text = itemData.headerName
                    cell.lblServiceDate.text = itemData.info
                    return cell
                }
            }
            return cell
        }
        
    }
    
}

class CustomInfoTableModel{
    let tableView: UITableView
    let data: [TargetCustomInfo]
    let publicAddress: String
    
    init(tableView: UITableView, data: [TargetCustomInfo], publicAddress: String){
        self.tableView = tableView
        self.data = data
        self.publicAddress = publicAddress
    }
}

class ServiceDateTableModel{
    let tableView: UITableView
    let data: [TargetServiceDate]
    let publicAddress: String
    
    init(tableView: UITableView, data: [TargetServiceDate], publicAddress: String){
        self.tableView = tableView
        self.data = data
        self.publicAddress = publicAddress
    }
}


//
//class ManageServiceDateTV{
//    let tableView: UITableView
//    let data: [TargetServiceDate]
//    init(tableView: UITableView, data: [TargetServiceDate]){
//        self.tableView = tableView
//        self.data = data
//    }
//}
//
//class ManageCustInfoTV{
//    let tableView: UITableView
//    let data: [TargetCustomInfo]
//    init(tableView: UITableView, data: [TargetCustomInfo]){
//        self.tableView = tableView
//        self.data = data
//    }
//}
