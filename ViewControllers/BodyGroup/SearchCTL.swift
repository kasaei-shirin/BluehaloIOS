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
    
    @IBOutlet weak var lblLocationFilter: UILabel!
    
    @IBOutlet weak var lblFoundCount: UILabel!
    
    
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var tableView: UITableView!
    
//    @IBOutlet weak var btnScan: UIButton!
    @IBOutlet weak var viewParentScanBtn: RoundedCornerView!
    @IBOutlet weak var lblScanBtn: UILabel!
    
    @IBOutlet weak var imgViewScanBtn: UIImageView!
    
    
    @IBOutlet weak var imgViewShowMore: UIImageView!
    @IBOutlet weak var imgViewShowLess: UIImageView!
    @IBOutlet weak var imgViewSetting: UIImageView!
    @IBOutlet weak var imgViewRefresh: UIImageView!
    @IBOutlet weak var imgViewInfo: UIImageView!
    @IBOutlet weak var imgViewSearchFilter: UIImageView!
    
    var filterModel: SearchFilterModel?
    @IBOutlet weak var widthLblScanBtn: NSLayoutConstraint!
    
    
    enum ScanButtonStates{
        case open, close, opening, closing
    }
    
    var scanBtnState: ScanButtonStates = .open
    
    
//    var cellHeight
    
    var searchItemExpand = Dictionary<String,Bool>()
    var customInfoMoreExpand = Dictionary<String,Bool>()
    var serviceDateMoreExpand = Dictionary<String, Bool>()
    var CUSTOMTABLEMANAGERS = [String:CustomInfoTableManager]()
    var SERVICETABLEMANAGERS = [String:ServiceDateTableManager]()
    
    
    var peripherals:[CBPeripheral] = []

    var PPPs : [PeripheralWithRssiAndData] = []
    var manager:CBCentralManager? = nil
    
    var RSSILabels = Dictionary<String, UILabel>()
    var RSSISliders = Dictionary<String, UISlider>()
    
    var allTags = [TagModel]()
    var tags = [TagModel]()
    
    var inScanMode: Bool = false
    
    func setInScaMode(_ sm: Bool){
        self.prevScanMode = inScanMode
        inScanMode = sm
    }
    
    var prevScanMode: Bool = false
    
    override func viewDidAppear(_ animated: Bool) {
        if prevScanMode{
            self.scanBLEDevices()
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        if inScanMode{
            stopScanForBLEDevices()
        }else{
            //be in dalil sedash zadim chon ke vaghti safhe disappear shod bar gasht agar dar search mode nabood dobare naiad search ro shoroo kone.
            setInScaMode(false)
        }
    }
    
    
    func getTagsCountText()->String{
        if(tags.count == 0){
            return "000";
        }
        let countDDD = countDig(n: tags.count);
        if(countDDD == 1){
            return "00\(tags.count)";
        }else if(countDDD == 2){
            return "0\(tags.count)";
        }else if(countDDD == 3){
            return "\(tags.count)";
        }else{
            return "999";
        }
    }
    
    func countDig(n: Int)->Int
    {
        var nn = n
        var count = 0;
        while(nn != 0)
        {
            // removing the last digit of the number n
            nn = nn / 10;
            // increasing count by 1
            count = count + 1;
        }
        return count;
    }
    
    
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
        let locAreaTitle = getLocAreaTextMethod()
        lblLocationFilter.text = locAreaTitle
        
        let dateTime = MyDateFormatter().getCurrentDateTimeForSearchHistory()
        
        if(locAreaTitle.lowercased() != "all") {
            DBManager().insertSearchHistory(SL: SearchHistoryModel(theID: -1, title: locAreaTitle, dateTime: dateTime, isDeleted: false))
        }
        
        let scanTap = UITapGestureRecognizer(target: self, action: #selector(scanAction(_:)))
        viewParentScanBtn.isUserInteractionEnabled = true
        viewParentScanBtn.addGestureRecognizer(scanTap)
        
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
        let dialogStoryboard = UIStoryboard(name: "dialogStoryboard", bundle: nil)
        let filterCTL = dialogStoryboard.instantiateViewController(withIdentifier: "filterCTL") as! FilterCTL
        ///TODO set values for filter
        filterCTL.filterModel = self.filterModel
        filterCTL.fitlerProtocol = self
        self.present(filterCTL, animated: true)
    }
    @objc func infoTap(_ tap: UITapGestureRecognizer){
        
    }
    @objc func refreshTap(_ tap: UITapGestureRecognizer){
        PPPs.removeAll()
        peripherals.removeAll()
        allTags.removeAll()
        tags.removeAll()
        searchItemExpand.removeAll()
        tableView.reloadData()
        lblFoundCount.text = getTagsCountText()
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
        
        var indexP = -1
        var i = 0

        for item in PPPs{

            if item.periPheral.identifier.uuidString == peripheral.identifier.uuidString{
                indexP = i
                break
            }
            i+=1
        }
        
        if(indexP == -1) {
            
            //add peripheral 2 list
            let PPP = PeripheralWithRssiAndData(periPheral: peripheral, rssi: RSSI.intValue, data: advertisementData)
            PPPs.append(PPP)
            
            getFromWebThenInsertIntoList(PPP)

        }else{


            PPPs[indexP].rssi = RSSI.intValue
            PPPs[indexP].data = advertisementData
            
            indexP = -1
            i = 0
            for item in tags{
                
                if item.uuid == peripheral.identifier.uuidString{
                    indexP = i
                    break
                }
                i+=1
            }
            
            if indexP != -1{
                tags[indexP].rssi = RSSI.intValue
                if !self.filterModel!.tagAcceptByFilter(tag: tags[indexP]){
                    tags.remove(at: indexP)
                    self.removeTagAtPosition(indexP)
                }else{
                    self.editRSSIOnTabelView(row: indexP)
                }

            }else{
                i = 0
                for item in allTags{
                    if item.uuid == peripheral.identifier.uuidString{
                        indexP = i
                        break
                    }
                    i+=1
                }
                if indexP != -1{
                    allTags[indexP].rssi = RSSI.intValue
                    if self.filterModel!.tagAcceptByFilter(tag: allTags[indexP]){
                        self.tags.append(allTags[indexP])
                        insertRowIntoList()
                    }
                }
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
                            print("tag : \n\(t)")
                            let theTag = TagModel(json: t,rssi: ppp.rssi, uuidString: ppp.periPheral.identifier.uuidString)
//                            self.tags.append(theTag)
                            self.allTags.append(theTag)
                            if self.filterModel!.tagAcceptByFilter(tag: theTag){
                                self.tags.append(theTag)
                            }
                            DispatchQueue.main.async {
                                self.insertRowIntoList()
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
    
    func insertRowIntoList(){
        lblFoundCount.text = getTagsCountText()
        self.tableView.insertRows(at: [IndexPath(row: self.tags.count-1, section: 0)], with: .none)
    }
    
    func scanBLEDevices() {
        //manager?.scanForPeripherals(withServices: [CBUUID.init(string: parentView!.BLEService)], options: nil)
        
        //if you pass nil in the first parameter, then scanForPeriperals will look for any devices.
//        PPPs.removeAll()
//        peripherals.removeAll()
//        tags.removeAll()
//        tableView.reloadData()
        
        setInScaMode(true)
        
//        btnScan.setTitle("Stop", for: .normal)
        lblScanBtn.text = "Stop"
        imgViewScanBtn.tintColor = UIColor(named: "pattern_tint")
        
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
        self.setInScaMode(false)
        manager?.stopScan()
//        btnScan.setTitle("Start", for: .normal)
        lblScanBtn.text = "Start"
        imgViewScanBtn.tintColor = UIColor.lightGray
    }
    
    
    @objc func scanAction(_ sender:UITapGestureRecognizer){
        if(inScanMode){
            stopScanForBLEDevices()
        }else{
            scanBLEDevices()
        }
    }
    
//    @IBAction func scanAction(_ sender: Any) {
//        if(inScanMode){
//            stopScanForBLEDevices()
//        }else{
//            scanBLEDevices()
//        }
//    }
    
    
}

extension SearchCTL: UITableViewDelegate, UITableViewDataSource, FlagNoteProtocol{
    func flagNoteText(note: String, indexPath: IndexPath) {
        tags[indexPath.row].flagNote = note
        updateTableViewInRow(indexPath.row)
    }
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tags.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return CGFloat(getRowheight(tag: tags[indexPath.row]))
    }
    
    func getRowheight(tag: TagModel)->Int{
//        return 144+calculateBottomViewHeight(tag: tag)
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
            
            if let _ = self.serviceDateMoreExpand[tag.publicAddress]{
                theBottomHeight += 73 + (tag.targetServiceDates.count*35)
            }else{
                ///main height + one row of service date
                //73 + 35
                theBottomHeight += 108
            }
        }
        if tag.targetCustomInfos.count > 0{
            if let _ = self.customInfoMoreExpand[tag.publicAddress]{
                theBottomHeight += 73 + (tag.targetCustomInfos.count*35)
            }else{
                ///main height + one row of custom Info
                //73 + 35
                theBottomHeight += 108
            }
        }
        return theBottomHeight
    }
    
    func getValueFromRSSI(rssi: Int)->Float{
        if rssi <= -10 && rssi >= -50{
            return 100
        }else if rssi <= -51 && rssi >= -62{
            return 75
        }else if rssi <= -63 && rssi >= -70{
            return 50
        }else if rssi <= -71 && rssi >= -80{
            return 25
        }else{
            return 0
        }
    }
    
    
    func getLocAreaTextMethod()->String{
        var locArea = "All"
        if let filter = self.filterModel{
            if filter.project == nil && filter.area == nil{
                return locArea
            }
            if let pro = filter.project{
                locArea = pro
            }else{
                locArea = "All"
            }
            if let ar = filter.area{
                locArea += " / \(ar)"
            }else{
                locArea += " / All"
            }
            return locArea
        }else{
            return locArea
        }
    }
    
    func manageSearchItem(cell: SearchItem, tag: TagModel, indexPath: IndexPath)-> SearchItem{
        
        cell.btnYellowFlag.configuration = .plain()
        cell.btnOrangeFlag.configuration = .plain()
        cell.btnGreenFlag.configuration = .plain()
        cell.btnGreenFlag.setImage(UIImage(named: "flag_icon"), for: .normal)
        cell.btnYellowFlag.setImage(UIImage(named: "flag_icon"), for: .normal)
        cell.btnOrangeFlag.setImage(UIImage(named: "flag_icon"), for: .normal)
        
        
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
            if let _ = serviceDateMoreExpand[tag.publicAddress]{
                cell.serviceDateTableHeight.constant = CGFloat(tag.targetServiceDates.count*35)
            }else{
                cell.serviceDateTableHeight.constant = 35
            }
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
            print("custom info height is true")
            cell.customInfoTopBorderHeight.constant = 17
            cell.customInfoTitleHeight.constant = 20
            if let _ = customInfoMoreExpand[tag.publicAddress]{
                cell.tableViewCustomInfoHeight.constant = CGFloat(tag.targetCustomInfos.count*35)
            }else{
                cell.tableViewCustomInfoHeight.constant = 35
            }
            cell.tableViewCustomInfo.rowHeight = 35
            cell.tableViewCustomInfo.estimatedRowHeight = 35
            cell.customInfoMoreheight.constant = 20
            cell.customInfoTopBorder.isHidden = false
        }
        
        
        if let _ = self.searchItemExpand[tag.publicAddress]{
            cell.viewParentOfExpandination.isHidden = false
            cell.imgViewExpand.image = UIImage(systemName: "chevron.up")
            cell.lblAdvanced.text = "Basic"
        }else{
            cell.viewParentOfExpandination.isHidden = true
            cell.imgViewExpand.image = UIImage(systemName: "chevron.down")
            cell.lblAdvanced.text = "Advanced"
        }
        
        cell.viewExpandParent.isUserInteractionEnabled = true
        let expandTap = UITapGestureRecognizer(target: self, action: #selector(expandClicked(_:)))
        
        print("before sender row : \(indexPath.row)")
        cell.viewExpandParent.addGestureRecognizer(expandTap)
        expandTap.view!.tag = indexPath.row
        cell.topParent.layer.masksToBounds = true
        cell.topParent.layer.cornerRadius = 10.0
        
        
        cell.lblDeviceName.text = tag.deviceName
        cell.lblAlias.text = tag.alias
        cell.lblRSSI.text = "\(tag.rssi)"
        
        let myDF = MyDateFormatter()
        
        cell.sliderRSSI.setValue(getValueFromRSSI(rssi: tag.rssi), animated: false)
        let expireDate = myDF.getDateFromString(dateString: tag.targetExpireDate)
        cell.lblExpireDate.text = myDF.getDateByCompleteMonthName(date: expireDate)
        
        cell.tableViewCustomInfo.estimatedRowHeight = 35
        print("\(cell.tableViewCustomInfoHeight.constant) the height")

        cell.tableViewCustomInfo.separatorColor = UIColor.white
        
        if(tag.isOnGoing){
            cell.imgViewIsOnGoing.image = UIImage(named: "ongoing_true")
        }else{
            cell.imgViewIsOnGoing.image = UIImage(named: "ongoing_false")
        }
        
        cell.taviewViewServiceDate.separatorColor = UIColor.white
        
        if tag.flagType == 1 {
            cell.btnGreenFlag.configuration = .tinted()
            cell.btnGreenFlag.setImage(UIImage(named: "flag_icon"), for: .normal)
            cell.imgViewFlagType.tintColor = UIColor.systemGreen
        }
        else if tag.flagType == 2{
            cell.btnYellowFlag.configuration = .tinted()
            cell.btnYellowFlag.setImage(UIImage(named: "flag_icon"), for: .normal)
            cell.imgViewFlagType.tintColor = UIColor.systemYellow
        }
        else{
            cell.btnOrangeFlag.configuration = .tinted()
            cell.btnOrangeFlag.setImage(UIImage(named: "flag_icon"), for: .normal)
            cell.imgViewFlagType.tintColor = UIColor.systemOrange
        }
        
        
        cell.btnGreenFlag.tag = indexPath.row
        cell.btnYellowFlag.tag = indexPath.row
        cell.btnOrangeFlag.tag = indexPath.row
        
        cell.btnGreenFlag.addTarget(self, action: #selector(greenAction(_:)), for: .touchUpInside)
        
        cell.btnYellowFlag.addTarget(self, action: #selector(yellowAction(_:)), for: .touchUpInside)
        
        cell.btnOrangeFlag.addTarget(self, action: #selector(orangeAction(_:)), for: .touchUpInside)
        
        
        cell.lblMoreCustomInfo.isUserInteractionEnabled = true
        cell.lblMoreServiceDate.isUserInteractionEnabled = true
        
        let customInfoMoreTap = UITapGestureRecognizer(target: self, action: #selector(customInfoMoreTap(_:)))
        
        cell.lblMoreCustomInfo.addGestureRecognizer(customInfoMoreTap)
        customInfoMoreTap.view!.tag = indexPath.row
        
        let serviceDateMoreTap = UITapGestureRecognizer(target: self, action: #selector(serviceDateMoreTap(_:)))
        
        cell.lblMoreServiceDate.addGestureRecognizer(serviceDateMoreTap)
        serviceDateMoreTap.view!.tag = indexPath.row
        cell.lblFlagNote.isUserInteractionEnabled = true
        cell.lblFlagNote.text = tag.flagNote
        
        let flagNoteTap = UITapGestureRecognizer(target: self, action: #selector(flagNoteTap(_:)))
        
        cell.lblFlagNote.addGestureRecognizer(flagNoteTap)
        flagNoteTap.view!.tag = indexPath.row
        
        cell.btnEdit.addAction(UIAction(handler: { UIAction in

            let bodyStoryboard = UIStoryboard(name: "BodyStoryboard", bundle: nil)
            let dest = bodyStoryboard.instantiateViewController(withIdentifier: "ScanQRCTL") as! ScanQRCTL
            dest.fromWhere = "search"
            dest.targetJob = "edit"
            dest.tagIndexpath = indexPath
            dest.theTag = tag
            dest.editProtocol = self
            self.present(dest, animated: true)
        }), for: .touchUpInside)
        
        cell.imgViewIconType.image = IconTypeModel.getIconByCode(code: tag.iconType).getImage()
        
        return cell
    }
    
    @objc func greenAction(_ sender: UIButton){
        let tag = tags[sender.tag]
        self.sendFlagNote2Web(note: tag.flagNote, flagType: 1, publicAddress: tag.publicAddress, indexPath: IndexPath(row: sender.tag, section: 0))
    }
    
    @objc func yellowAction(_ sender: UIButton){
        let tag = tags[sender.tag]
        self.sendFlagNote2Web(note: tag.flagNote, flagType: 2, publicAddress: tag.publicAddress, indexPath: IndexPath(row: sender.tag, section: 0))
    }
    
    @objc func orangeAction(_ sender: UIButton){
        let tag = tags[sender.tag]
        self.sendFlagNote2Web(note: tag.flagNote, flagType: 3, publicAddress: tag.publicAddress, indexPath: IndexPath(row: sender.tag, section: 0))
    }
    
    func sendFlagNote2Web(note: String, flagType: Int, publicAddress: String, indexPath: IndexPath){
        print("flagType for change : \(flagType) and note : \(note) , publicAddress : \(publicAddress)")
        let waiting = ViewPatternMethods.waitingDialog(controller: self)
        var params = Dictionary<String,Any>()
        params["flagNote"] = note
        params["flagType"] = flagType
        params["publicAddress"] = publicAddress
        HttpClientApi.instance().makeAPICall(url: URLS.FlagURL, headers: Dictionary<String, String>(), params: params, method: .POST) { data, response, error in
            DispatchQueue.main.async {
                waiting.dismiss(animated: true) {
                    self.tags[indexPath.row].flagType = flagType
                    if !self.filterModel!.tagAcceptByFilter(tag: self.tags[indexPath.row]){
                        self.tags.remove(at: indexPath.row)
                        self.removeTagAtPosition(indexPath.row)
                    }else{
                        self.updateTableViewInRow(indexPath.row)
                    }
                }
            }
        } failure: { data, response, error in
            
            DispatchQueue.main.async {
                waiting.dismiss(animated: true) {
                    ViewPatternMethods.showAlert(controller: self, title: "Error", message: "Back Problem!!!", handler: UIAlertAction(title: "OK", style: .destructive))
                }
                
            }
            print(data)
            print(response)
            print(error)
        }

    }
    
    func removeTagAtPosition(_ row: Int){
        self.tableView.beginUpdates()
        self.tableView.deleteRows(at: [IndexPath(row: row, section: 0)], with: .fade)
        self.tableView.endUpdates()
    }

    @objc func flagNoteTap(_ sender: UITapGestureRecognizer){
        print( "indexPath clicked = \(sender.view?.tag)")
        let storyboard = UIStoryboard(name: "dialogStoryboard", bundle: nil)
        let flagNoteCTL = storyboard.instantiateViewController(withIdentifier: "FlagNoteCTL") as! FlagNoteController
        flagNoteCTL.flagNoteProtocol = self
        flagNoteCTL.indexPath = IndexPath(row: sender.view!.tag, section: 0)
        flagNoteCTL.publicAddress = tags[sender.view!.tag].publicAddress
        flagNoteCTL.flagType = tags[sender.view!.tag].flagType

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
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let SI = cell as! SearchItem
        let tag = tags[indexPath.row]
        SI.tableViewCustomInfo.register(UINib(nibName: "CustomInfoSPCell", bundle: nil), forCellReuseIdentifier: "customInfoCell")
        SI.taviewViewServiceDate.register(UINib(nibName: "ServiceDateSPCell", bundle: nil), forCellReuseIdentifier: "serviceDateCell")
        
        
        let customInfoM = CustomInfoTableManager(custInfos: tag.targetCustomInfos, tableView: SI.tableViewCustomInfo, showAll: self.customInfoMoreExpand[tag.publicAddress] != nil)
        let serviceDateM = ServiceDateTableManager(serviceDates: tag.targetServiceDates, tableView: SI.taviewViewServiceDate, showAll: self.serviceDateMoreExpand[tag.publicAddress] != nil)
        
//            customInfoM.buildTableItems()
        SI.tableViewCustomInfo.dataSource = customInfoM
        SI.tableViewCustomInfo.delegate = customInfoM
        
        SI.taviewViewServiceDate.dataSource = serviceDateM
        SI.taviewViewServiceDate.delegate = serviceDateM
        self.CUSTOMTABLEMANAGERS[tag.publicAddress] = customInfoM
//        self.CUSTOMTABLEMANAGERS.append(customInfoM)
        self.SERVICETABLEMANAGERS[tag.publicAddress] = serviceDateM
        
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
        print("the row of expand clicked : \(row)")
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "searchItem", for: indexPath) as! SearchItem
        let tag = tags[indexPath.row]
        
        return manageSearchItem(cell: cell, tag: tag, indexPath: indexPath)
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



extension SearchCTL: EditActionProtocol{
    func edited(tag: TagModel, indexPath: IndexPath) {
        self.tags[indexPath.row] = tag
        self.updateTableViewInRow(indexPath.row)
    }
    
}

extension SearchCTL: SearchFilterProtocol{
    func searchFiltered(filterModel: SearchFilterModel) {
        self.filterModel = filterModel
        filterAllList()
    }
    
    func filterAllList(){
        self.tags.removeAll()
        for item in allTags{
            if self.filterModel!.tagAcceptByFilter(tag: item){
                self.tags.append(item)
            }
        }
        self.tableView.reloadData()
    }
    
}


extension SearchCTL: UIScrollViewDelegate{
    
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let indexPathes = self.tableView.indexPathsForVisibleRows
        if let ips = indexPathes{
            print("\(ips[0].row) row of first visible item")
            if ips[0].row != 0 && self.scanBtnState == .open{
                print("the must be here.")
                self.scanBtnState = .closing
                self.closeBtnScanAnimationally()
            }
            if ips[0].row == 0 && self.scanBtnState == .close{
                self.scanBtnState = .opening
                self.openBtnScanAnimationally()
            }
        }
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        
        
    }
    
    func closeBtnScanAnimationally(){
        self.widthLblScanBtn.constant -= 66
        UIView.animate(withDuration: 0.25, animations: {
            self.viewParentScanBtn.layoutIfNeeded()
        }) { Bool in
            self.scanBtnState = .close
        }
    }
    
    func openBtnScanAnimationally(){
        self.widthLblScanBtn.constant += 66
        UIView.animate(withDuration: 0.25, animations: {
            self.viewParentScanBtn.layoutIfNeeded()
        }) { Bool in
            self.scanBtnState = .open
        }
    }
}
