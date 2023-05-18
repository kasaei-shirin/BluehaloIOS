//
//  SetupEditCTL.swift
//  Ninox
//
//  Created by saeed on 11/05/2023.
//

import UIKit
import iOSDropDown

class SetupEditCTL: UIViewController, UIScrollViewDelegate, IconTypeSelection, DataSelection, AddCustomInfoProtocol, ServiceDateSelection{
    
    
    func ServiceDateSelected(item: TargetServiceDate) {
        self.serviceDates.append(item)
        self.updateServiceDateTableView()
    }
    
    func updateServiceDateTableView(){
        //set tableViewHeight
        //reload data to tableview
        serviceDateHeight.constant = CGFloat((serviceDates.count*75) + 10)
        
        self.tableViewTargetServiceDate.reloadData()
    }
    
    func updateCustomInfoTableView(){
        customInfoheight.constant = CGFloat((customInfos.count*75)+10)
        self.tableViewCustomInfo.reloadData()
        //setTableViewHeight
        //reload tableView data
    }
    
    func saveCustomInfo(title: String, Content: String) {
        customInfos.append(TargetCustomInfo(headerName: title, info: Content, _id: ""))
        self.updateCustomInfoTableView()
    }
    
    
    func DataSelected(selectedItemIndex: Int, targetAction: Int) {
        if targetAction == 1{
            //area
            txtFldArea.text = allAreas[selectedItemIndex]
        }else if targetAction == 2{
            txtFldProject.text = allProjects[selectedItemIndex]
        }
    }
    
    
    func IconTypeSelected(item: IconTypeModel) {
        //todo : do any thing after selection
        self.iconTypeModel = item
        self.imgViewIconType.image = item.getImage()
    }
    
    
    
    var targetExpireDate: Date?
    var serviceDates = [TargetServiceDate]()
    var customInfos = [TargetCustomInfo]()
    var iconTypeModel: IconTypeModel?
    
    var selectedArea: String?
    var selectedProject: String?
    
    
    
    @IBOutlet weak var serviceDateHeight: NSLayoutConstraint!
    
    @IBOutlet weak var customInfoheight: NSLayoutConstraint!
    
    
    @IBOutlet weak var lblTitleOfPage: UILabel!
    
    @IBOutlet weak var backParentView: UIView!
    
    @IBOutlet weak var lblPublicAddress: UILabel!
    @IBOutlet weak var txtFldTargetName: UITextField!
    @IBOutlet weak var txtFldAlias: UITextField!
    
    @IBOutlet weak var txtFldProject: UITextField!
    @IBOutlet weak var txtFldArea: UITextField!
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var isOnGoingSwitch: UISwitch!
    
    @IBOutlet weak var lblBatteryExpireDate: UILabel!
    @IBOutlet weak var lblActivationDate: UILabel!
    @IBOutlet weak var lblLastSearch: UILabel!
    
    var allAreas = [String]()
    var allProjects = [String]()
    
    var targetJob: String?
    var fromWhere: String?
    var publicAddress: String?
    
    
    @IBOutlet weak var parentOfSpaceTopTagInfo: UIView!
    @IBOutlet weak var constraintSpaceTopTagInfo: NSLayoutConstraint!
    @IBOutlet weak var constraintBatteryExpireDate: NSLayoutConstraint!
    @IBOutlet weak var constraintActivationDate: NSLayoutConstraint!
    @IBOutlet weak var constraintLastSearch: NSLayoutConstraint!
    
    @IBOutlet weak var imgViewIconType: UIImageView!
    
    @IBOutlet weak var tableViewTargetServiceDate: UITableView!
    
    @IBOutlet weak var tableViewCustomInfo: UITableView!
    
    
    
    
    @IBAction func expireDateAction(_ sender: UIDatePicker) {
        
        self.targetExpireDate = sender.date
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        scrollView.delegate = self
        
        if targetJob == "setup"{
            lblTitleOfPage.text = "SetupTag"
        }else{
            lblTitleOfPage.text = "EditTag"
        }
        
        lblPublicAddress.text = self.publicAddress
        
        let backTap = UITapGestureRecognizer(target: self, action: #selector(backTap(_:)))
        backParentView.isUserInteractionEnabled = true
        backParentView.addGestureRecognizer(backTap)
        
        getProjectAndAreaFromWeb()
        
        
        //TODO must check to work
        txtFldArea.delegate = self
        txtFldProject.delegate = self
        
        
        self.tableViewTargetServiceDate.delegate = self
        self.tableViewTargetServiceDate.dataSource = self
        self.tableViewCustomInfo.delegate = self
        self.tableViewCustomInfo.dataSource = self
        
        
        let areaTap = UITapGestureRecognizer(target: self, action: #selector(areaTap(_:)))
        txtFldArea.addGestureRecognizer(areaTap)
        
        let projectTap = UITapGestureRecognizer(target: self, action: #selector(projectTap(_:)))
        txtFldProject.addGestureRecognizer(projectTap)
        
        
        let iconTypeTap = UITapGestureRecognizer(target: self, action: #selector(iconTypeTap(_:)))
        self.imgViewIconType.isUserInteractionEnabled = true
        self.imgViewIconType.addGestureRecognizer(iconTypeTap)
        
        if targetJob == "setup"{
            let item = IconTypeModel.getIconTypes()[0]
            self.iconTypeModel = item
            
            self.imgViewIconType.image = item.getImage()
            
        }
        
    }
    
    @objc func iconTypeTap(_ sender: UITapGestureRecognizer){
        IconTypeDialog.PresentIconTypeDialog(ViewController: self, iconTypeSelection: self, iconTypes: IconTypeModel.getIconTypes())
    }
    
    
    
    @objc func projectTap(_ sender: UITapGestureRecognizer){
        DataPickerDialog.PresentDataPickerDialog(ViewController: self, titleOfDialog: "Add Project", selectionProtocol: self, datas: self.allProjects, targetAction: 2)
    }
    
    @objc func areaTap(_ sender: UITapGestureRecognizer){
        DataPickerDialog.PresentDataPickerDialog(ViewController: self, titleOfDialog: "Add Area", selectionProtocol: self, datas: self.allAreas, targetAction: 1)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        makeHeights0OfSetupingAction()
    }
    
    func makeHeights0OfSetupingAction(){
        constraintSpaceTopTagInfo.constant = 0
        constraintBatteryExpireDate.constant = 0
        constraintActivationDate.constant = 0
        constraintLastSearch.constant = 0
        parentOfSpaceTopTagInfo.isHidden = true
        
        updateServiceDateTableView()
        updateCustomInfoTableView()
        
    }
    
    @objc func backTap(_ sender: UITapGestureRecognizer){
        self.dismiss(animated: true)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        dismissKeyboard()
    }
    
    @objc func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    
//    JSONArray jsonAreas = response.optJSONArray("area");
//    for (int i = 0; i < jsonAreas.length(); i++) {
//        areas.add(jsonAreas.optString(i));
//    }
//    JSONArray jsonProjs = response.optJSONArray("project");
//    for (int i = 0; i < jsonProjs.length(); i++) {
//        projects.add(jsonProjs.optString(i));
//    }
    
    func getProjectAndAreaFromWeb(){
        
        let alter = ViewPatternMethods.waitingDialog(controller: self)
        
        let header = Dictionary<String, String>()
        
        HttpClientApi.instance().makeAPICall(url: URLS.PROJAREA, headers: header, params: nil, method: .GET) { data, response, error in
            
            DispatchQueue.main.async {
                alter.dismiss(animated: true) {
                    let json = try? JSONSerialization.jsonObject(with: data!, options: [])
                    
                    DispatchQueue.main.async {
                        alter.dismiss(animated: true)
                    }
                    
                    if let j = json as? [String:Any]{
                        
                        print(j)
                        if let success = j["success"] as? String{
                            DispatchQueue.main.async {
                                let areasOPT = j["area"] as? [String]
                                if let areas = areasOPT{
                                    for area in areas {
                                        self.allAreas.append(area)
                                    }
                                }
                                let projectsOPT = j["project"] as? [String]
                                if let projects = projectsOPT{
                                    for project in projects {
                                        self.allProjects.append(project)
                                    }
                                }
                                
        //                        self.initProjectAndAreaDropDown()
                            }
                        }
                    }
                }
            }
            
            
            
        } failure: { data, response, error in
            
            DispatchQueue.main.async {
                alter.dismiss(animated: true)
            }
            
            print(data)
            print(response)
            print(error)
        }
    }
    
//    func initProjectAndAreaDropDown(){
//        initProjectDropDown()
//        initAreaDropDown()
//    }
//
//    func initProjectDropDown(){
//
//    }
//
////    - (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
////    {
////        return textField != _yourReadOnlyTextField;
////    }
////
//    func initAreaDropDown(){
//
//    }
    
    @IBAction func addTargetServiceDateAction(_ sender: Any) {
        
        DatePickerDialog.PresentDatePickerDialog(ViewController: self, serviceDateSelection: self)
        
    }
    
    
    
    @IBAction func submitAction(_ sender: Any) {
        if self.targetJob == "setup"{
            self.sendSetupDatas2Web()
        }else if self.targetJob == "edit"{
            
        }
    }
    
    func sendSetupDatas2Web(){

        let waitingAlert = ViewPatternMethods.waitingDialog(controller: self)
        
        var params = Dictionary<String, Any>()
        params["publicAddress"] = self.publicAddress
        params["update"] = true
        params["productName"] = "" //get from scan qr
        params["alias"] = txtFldAlias.text
        params["deviceName"] = txtFldTargetName.text
        params["iconType"] = self.iconTypeModel?.code
        params["isOnGoing"] = self.isOnGoingSwitch.isOn
        params["advertisementInterval"] = ""//get from scan qr
        params["txPower"] = "" //get from scan qr
        params["manufactureId"] = ""//get fro scan qr
        params["cte"] = false
        params["batteryReplacementLimit"] = 30
        params["project"] = self.txtFldProject.text
        params["area"] = self.txtFldArea.text
        params["lastBatteryAmount"] = 3
        params["targetExpireDate"] = MyDateFormatter().getDateFromDatePickerForSend(datee: self.targetExpireDate)
        
        sendCustInfosAndServiceDates()
        
        HttpClientApi.instance().makeAPICall(url: URLS.SETUPTAG, headers: Dictionary<String,String>(), params: params, method: .POST) { data, response, error in
            
            
            DispatchQueue.main.async {
                waitingAlert.dismiss(animated: true) {
                    let json = try? JSONSerialization.jsonObject(with: data!, options: [])
                    
                    if let j = json as? [String:Any]{
                        print(j)
                        if let success = j["success"] as? String{
                            DispatchQueue.main.async {
                                let message = j["message"] as? String ?? ""
                                if(success == "true"){
                                    let alertCTL = UIAlertController(title: "Info", message: message, preferredStyle: .actionSheet)
                                    alertCTL.addAction(UIAlertAction(title: "Cancle", style: .cancel, handler: { UIAlertAction in
                                        alertCTL.dismiss(animated: true)
                                    }))
                                    alertCTL.addAction(UIAlertAction(title: "OK", style: .default, handler: { UIAlertAction in
                                        alertCTL.dismiss(animated: true) {
                                            self.dismiss(animated: true)
                                        } 
                                    }))
                                    self.present(alertCTL, animated: true)
                                }else{
                                    let alertCTL = UIAlertController(title: "Info", message: message, preferredStyle: .actionSheet)
                                    alertCTL.addAction(UIAlertAction(title: "Cancle", style: .cancel, handler: { UIAlertAction in
                                        alertCTL.dismiss(animated: true)
                                    }))
        //                            alertCTL.addAction(UIAlertAction(title: "OK", style: .default, handler: { UIAlertAction in
        //                                alertCTL.dismiss(animated: false)
        //                                self.dismiss(animated: true)
        //                            }))
                                    self.present(alertCTL, animated: true)
                                }
                            }
                        }
                    }
                }
            }
            
        } failure: { data, response, error in
            DispatchQueue.main.async {
                waitingAlert.dismiss(animated: true)
            }
            print(data)
            print(response)
            print(error)
        }

    }
    
    
    
    func sendCustInfosAndServiceDates(){
        for item in self.serviceDates{
            sendServiceDate2Web(serviceDate: item)
        }
        for item in self.customInfos{
            sendCustInfo2Web(custInfo: item)
        }
    }
    
    func sendCustInfo2Web(custInfo: TargetCustomInfo){
//        json.put("publicAddress", PA);
//        json.put("update", true);
//        json.put("targetCustomInfo", targetCustomInfo.getJsonToSend());
        
//        let waitingAlert = ViewPatternMethods.waitingDialog(controller: self)
        
        var params = Dictionary<String, Any>()
        params["publicAddress"] = self.publicAddress
        params["update"] = true
        params["targetCustomInfo"] = custInfo.getJSON()
        
        HttpClientApi.instance().makeAPICall(url: URLS.SETUPTAG, headers: Dictionary<String,String>(), params: params, method: .POST) { data, response, error in
            
        } failure: { data, response, error in
            
            print(data)
            print(response)
            print(error)
        }
        
    }
    
    func sendServiceDate2Web(serviceDate: TargetServiceDate){
        var params = Dictionary<String, Any>()
        params["publicAddress"] = self.publicAddress
        params["update"] = true
        params["targetServiceDates"] = serviceDate.getJSON()
        
        HttpClientApi.instance().makeAPICall(url: URLS.SETUPTAG, headers: Dictionary<String,String>(), params: params, method: .POST) { data, response, error in
            
        } failure: { data, response, error in
            
            print(data)
            print(response)
            print(error)
        }
    }
    
    
    func sendEditDatas2Web(){
        //after sending check whereComeFrom to choose where to go
    }
    
    
    @IBAction func addTargetCustomInfoAction(_ sender: Any) {
        CustomInfoDialog.presentCustomInfoDialog(ViewController: self, customInfoProtocol: self)
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

extension SetupEditCTL: UITextFieldDelegate{
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        return !(textField == self.txtFldArea || textField == self.txtFldProject)
    }
}


extension SetupEditCTL: UITableViewDelegate, UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == self.tableViewTargetServiceDate{
            return serviceDates.count
        }else{
            return customInfos.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == self.tableViewTargetServiceDate{
            let SD = serviceDates[indexPath.row]
            let cell = tableView.dequeueReusableCell(withIdentifier: "serviceDateCell", for: indexPath) as! ServiceDateCell
            cell.lblTitle.text = SD.title
            cell.lblContent.text = MyDateFormatter().getDateByCompleteMonthName(date: SD.date)
            return cell
        }else{
            let CI = customInfos[indexPath.row]
            let cell = tableView.dequeueReusableCell(withIdentifier: "customInfoCell", for: indexPath) as! CustomInfoCell
            cell.lblTitle.text = CI.headerName
            cell.lblContent.text = CI.info
            return cell
        }
        
    }
    
    
}


