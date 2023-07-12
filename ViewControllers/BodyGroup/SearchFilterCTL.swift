//
//  SearchFilterCTL.swift
//  Ninox
//
//  Created by saeed on 09/05/2023.
//

import UIKit

class SearchFilterCTL: MyViewController , DataSelection{
    
    var selectedArea: AreaModel?
    var selectedProject: ProjectModel?
    
    func DataSelected(selectedItemIndex: Int, targetAction: Int) {
        if targetAction == 1{
            //area
            self.lblAreas.text = allAreas[selectedItemIndex].name
            self.selectedArea = allAreas[selectedItemIndex]
        }
        else{
            //project
            self.lblProjects.text = allProjects[selectedItemIndex].name
            self.selectedProject = allProjects[selectedItemIndex]
            getAllAreasByID(theID: allProjects[selectedItemIndex]._id)
        }
    }
    
    @IBOutlet weak var refreshBtn: UIView!
    
    @IBOutlet weak var backView: UIView!
    
    var allAreas = [AreaModel]()
    var allProjects = [ProjectModel]()
    
    var searchHistories = [SearchHistoryModel]()
    
    @IBOutlet weak var historyTableView: UITableView!
    
    @IBOutlet weak var lblNoRecentItems: UILabel!
    
    @IBOutlet weak var areaParentView: RoundedCornerView!
    @IBOutlet weak var projectParentView: RoundedCornerView!
    @IBOutlet weak var lblProjects: UILabel!
    @IBOutlet weak var lblAreas: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.historyTableView.delegate = self
        self.historyTableView.dataSource = self
        
        let backTap = UITapGestureRecognizer(target: self, action: #selector(backTap(_:)))
        backView.isUserInteractionEnabled = true
        backView.addGestureRecognizer(backTap)
        
        
//        self.historyTableView.separatorStyle = .singleLine
//        self.historyTableView.separatorInset = .init(top: 5, left: 0, bottom: 5, right: 0)
        
//        self.historyTableView.contentSize = CGSize(width: .bitWidth, height: 50)
//        self.historyTableView.seprato
        
    }
    
    
    
    @objc func refreshTap(_ sender: UITapGestureRecognizer){
        lblAreas.text = "All"
        lblProjects.text = "All"
    }
    
    
    @objc func areaTap(_ sender: UITapGestureRecognizer){
        if allAreas.count > 0{
            var aras = [String]()
            for area in self.allAreas{
                aras.append(area.name)
            }
            DataPickerDialog.PresentDataPickerDialog(ViewController: self, titleOfDialog: "Areas", selectionProtocol: self, datas: aras, targetAction: 1)
        }
    }
    
    @objc func projectTap(_ sender: UITapGestureRecognizer){
        if allProjects.count > 0{
            var projs = [String]()
            for proj in self.allProjects{
                projs.append(proj.name)
            }
            DataPickerDialog.PresentDataPickerDialog(ViewController: self, titleOfDialog: "Projects", selectionProtocol: self, datas: projs, targetAction: 2)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        super.viewDidAppear(animated)
        
        print("view did appear")
        
        
        self.areaParentView.isUserInteractionEnabled = true
        self.projectParentView.isUserInteractionEnabled = true
        
        let areaTap = UITapGestureRecognizer(target: self, action: #selector(areaTap(_:)))
        areaParentView.addGestureRecognizer(areaTap)
        
        let projectTap = UITapGestureRecognizer(target: self, action: #selector(projectTap(_:)))
        projectParentView.addGestureRecognizer(projectTap)
        
        
        refreshBtn.isUserInteractionEnabled = true
        let refreshTap = UITapGestureRecognizer(target: self, action: #selector(refreshTap(_:)))
        refreshBtn.addGestureRecognizer(refreshTap)
        
        self.historyTableView.rowHeight = 60
        
        
        getProjectFromWeb(TRY: 1)
        
    }
    
    
    func getProjectFromWeb(TRY: Int){
        
        let alter = ViewPatternMethods.waitingDialog(controller: self)
        
        let header = Dictionary<String, String>()
        
        allProjects.removeAll()
        
        allProjects.append(ProjectModel(_id: "-1", name: "All"))
        
        HttpClientApi.instance().makeAPICall(viewController: self, refreshReq: false, url: URLSV2.COMPANYPROJECT, headers: header, params: nil, method: .GET) { data, response, error in
            
            DispatchQueue.main.async {
                self.searchHistories = DBManager().getLastSearchHistories()
                alter.dismiss(animated: true) {
                    let json = try? JSONSerialization.jsonObject(with: data!, options: [])
                    
                    DispatchQueue.main.async {
                        alter.dismiss(animated: true)
                    }
                    
                    if let j = json as? [String:Any]{
                        
                        let projectOPT = j["items"] as? [[String:Any]]
                        if let projects = projectOPT{
                            for project in projects {
                                self.allProjects.append(ProjectModel(json: project))
                            }
                        }
                    }
                    DispatchQueue.main.async{
                        self.getAllAreas()
                    }
//                    if let j = json as? [String:Any]{
//
//                        print(j)
//                        if let success = j["success"] as? String{
//                            DispatchQueue.main.async {
//                                let areasOPT = j["area"] as? [String]
//                                if let areas = areasOPT{
//                                    for area in areas {
//                                        self.allAreas.append(area)
//                                    }
//                                }
//                                let projectsOPT = j["project"] as? [String]
//                                if let projects = projectsOPT{
//                                    for project in projects {
//                                        self.allProjects.append(project)
//                                    }
//                                }
//                                self.checkAllHistories()
//                                self.historyTableView.reloadData()
//                            }
//                        }
//                    }
                }
            }
            
            
            
        } failure: { data, response, error in
            
            DispatchQueue.main.async {
                alter.dismiss(animated: true) {
                    if TRY < 4{
                        self.getProjectFromWeb(TRY: TRY+1)
                    }
                }
            }
            
            print(data)
            print(response)
            print(error)
        }
    }
    
    func getAllAreasByID(theID: String){
        
        allAreas.removeAll()
        allAreas.append(AreaModel(_id: "-1", name: "All", project: "-1"))
        
        let alter = ViewPatternMethods.waitingDialog(controller: self)
        let url = URLSV2.PROJECTAREAS+"?filter={\"project\": \"" + theID + "\"}"
        HttpClientApi.instance().makeAPICall(viewController: self, refreshReq: false, url: url, headers: Dictionary<String, String>(), params: nil, method: .GET) { data, response, error in
            
            DispatchQueue.main.async {
                alter.dismiss(animated: true) {
                    let json = try? JSONSerialization.jsonObject(with: data!, options: [])
                    
                    DispatchQueue.main.async {
                        alter.dismiss(animated: true)
                    }
                    if let j = json as? [String:Any]{
                        let areaOPT = j["items"] as? [[String:Any]]
                        if let areas = areaOPT{
                            for area in areas {
                                self.allAreas.append(AreaModel(json: area))
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
    
    func getAllAreas(){
        allAreas.removeAll()
        allAreas.append(AreaModel(_id: "-1", name: "All", project: "-1"))
        let alter = ViewPatternMethods.waitingDialog(controller: self)
        let url = URLSV2.PROJECTAREAS
        HttpClientApi.instance().makeAPICall(viewController: self, refreshReq: false, url: url, headers: Dictionary<String, String>(), params: nil, method: .GET) { data, response, error in
            
            DispatchQueue.main.async {
                alter.dismiss(animated: true) {
                    let json = try? JSONSerialization.jsonObject(with: data!, options: [])
                    
                    
                    alter.dismiss(animated: true)
                    
                    if let j = json as? [String:Any]{
                        let areaOPT = j["items"] as? [[String:Any]]
                        if let areas = areaOPT{
                            for area in areas {
                                self.allAreas.append(AreaModel(json: area))
                            }
                        }
                    }
                    self.checkAllHistories()
                    self.historyTableView.reloadData()
                }
            }
            
            
        } failure: { data, response, error in
            print(data)
            print(response)
            print(error)
        }
    }
    

    
    @objc func backTap(_ gest: UITapGestureRecognizer){
        self.dismiss(animated: true)
    }
    
    @IBAction func nextAction(_ sender: Any) {
        performSegue(withIdentifier: "location2search", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "location2search"{
            let dest = segue.destination as! SearchCTL
            dest.filterModel = SearchFilterModel(area: selectedArea ?? AreaModel(_id: "-1", name: "All", project: "-1"), project: selectedProject ?? ProjectModel(_id: "-1", name: "All"))
        }
    }
    
    func checkAllHistories(){
        for item in self.searchHistories{
            if !(isSHInAreaAndProject(SH: item, projects: self.allProjects, areas: self.allAreas)){
                item.isDeleted = true
            }
        }
    }
    
    func isSHInAreaAndProject(SH: SearchHistoryModel, projects: [ProjectModel], areas: [AreaModel])->Bool{

        let PAs = SH.title.split(separator: "/")
        ///TODO
        if(isSHInArea(area: String(PAs[1]), areas: areas)) && isSHInProjects(project: String(PAs[0]), projects: projects){
            return true
        }
        return false
        
    }
    
    func isSHInArea(area: String, areas: [AreaModel])->Bool{

        for item in areas{
            if item.name.trimmingCharacters(in: .whitespacesAndNewlines) == area.trimmingCharacters(in: .whitespacesAndNewlines){
                return true
            }
        }
        return false
    }
    
    func isSHInProjects(project: String, projects: [ProjectModel])->Bool{
        for item in projects{
            if item.name.trimmingCharacters(in: .whitespacesAndNewlines) == project.trimmingCharacters(in: .whitespacesAndNewlines){
                return true
            }
        }
        return false
    }
    
   
}

extension SearchFilterCTL: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchHistories.count == 0{
            self.lblNoRecentItems.isHidden = false
            self.historyTableView.layer.borderWidth = 1
            self.historyTableView.layer.borderColor = UIColor(red: 245.0/255.0, green: 245.0/255.0, blue: 245.0/255.0, alpha: 0.25).cgColor
            self.historyTableView.layer.cornerRadius = 8
        }else{
            self.lblNoRecentItems.isHidden = true
            self.historyTableView.layer.borderWidth = 0
            self.historyTableView.layer.cornerRadius = 0
        }
        return searchHistories.count
    }
    
//    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        return 50
//    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
//        print("\(indexPath.row) row edition")
//        if (editingStyle == .delete){
//            DBManager().deleteSearchHistoryBy(title: searchHistories[indexPath.row].title)
//            searchHistories.remove(at: indexPath.row)
//            tableView.beginUpdates()
//            tableView.deleteRows(at: [indexPath], with: .fade)
//            tableView.endUpdates()
//
//        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.historyTableView.dequeueReusableCell(withIdentifier: "searchHistoryCell", for: indexPath) as! SearchHistoryCell
        let HM = self.searchHistories[indexPath.row]
        let mdFD = MyDateFormatter()
        cell.lblTime.text = mdFD.getHourForSearchHistory(dateSTR: HM.dateTime)
        cell.lblMonthDay.text = mdFD.getMonthAndDayForSearchHistory(dateSTR: HM.dateTime)
        cell.lblYear.text = mdFD.getYearForSearchHistory(dateSTR: HM.dateTime)
        cell.lblTitle.text = HM.title
        if(HM.isDeleted){
            cell.lblDeleteItem.isHidden = false
        }else{
            cell.lblDeleteItem.isHidden = true
        }
//        cell.lbl
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //TODO set selection into labels
//        let cell = tableView.dequeueReusableCell(withIdentifier: "searchHistoryCell", for: indexPath) as! SearchHistoryCell
        let HM = self.searchHistories[indexPath.row]
        if HM.isDeleted{
            print("check is delete")
            return
        }
        let SH = self.searchHistories[indexPath.row]
        let seprates = SH.title.split(separator: "/")
        self.lblProjects.text = String(seprates[0]).trimmingCharacters(in: .whitespacesAndNewlines)
        self.lblAreas.text = String(seprates[1]).trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath)
            -> UISwipeActionsConfiguration? {
                let deleteAction = UIContextualAction(style: .normal, title: nil) { (_, _, completionHandler) in
                    DBManager().deleteSearchHistoryBy(title: self.searchHistories[indexPath.row].title)
                    self.searchHistories.remove(at: indexPath.row)
                    tableView.beginUpdates()
                    tableView.deleteRows(at: [indexPath], with: .fade)
                    tableView.endUpdates()
                    completionHandler(true)
                }
                deleteAction.image = UIImage(systemName: "trash")
                deleteAction.backgroundColor = UIColor(named: "main_background")
                
                let configuration = UISwipeActionsConfiguration(actions: [deleteAction])
                
                return configuration
    }
    
}


