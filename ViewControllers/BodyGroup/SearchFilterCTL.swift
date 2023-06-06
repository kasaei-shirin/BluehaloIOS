//
//  SearchFilterCTL.swift
//  Ninox
//
//  Created by saeed on 09/05/2023.
//

import UIKit

class SearchFilterCTL: MyViewController , DataSelection{
    func DataSelected(selectedItemIndex: Int, targetAction: Int) {
        if targetAction == 1{
            //area
            self.lblAreas.text = allAreas[selectedItemIndex]
        }
        else{
            //project
            self.lblProjects.text = allProjects[selectedItemIndex]
        }
    }
    
    @IBOutlet weak var refreshBtn: UIView!
    
    @IBOutlet weak var backView: UIView!
    
    var allAreas = [String]()
    var allProjects = [String]()
    
    var searchHistories = [SearchHistoryModel]()
    
    @IBOutlet weak var historyTableView: UITableView!
    
    @IBOutlet weak var areaParentView: RoundedCornerView!
    @IBOutlet weak var projectParentView: RoundedCornerView!
    @IBOutlet weak var lblProjects: UILabel!
    @IBOutlet weak var lblAreas: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let backTap = UITapGestureRecognizer(target: self, action: #selector(backTap(_:)))
        backView.isUserInteractionEnabled = true
        backView.addGestureRecognizer(backTap)
        
        
        self.historyTableView.delegate = self
        self.historyTableView.dataSource = self
        
        
        self.areaParentView.isUserInteractionEnabled = true
        self.projectParentView.isUserInteractionEnabled = true
        
        let areaTap = UITapGestureRecognizer(target: self, action: #selector(areaTap(_:)))
        areaParentView.addGestureRecognizer(areaTap)
        
        let projectTap = UITapGestureRecognizer(target: self, action: #selector(projectTap(_:)))
        projectParentView.addGestureRecognizer(projectTap)
        
        
        refreshBtn.isUserInteractionEnabled = true
        let refreshTap = UITapGestureRecognizer(target: self, action: #selector(refreshTap(_:)))
        refreshBtn.addGestureRecognizer(refreshTap)
        
    }
    
    @objc func refreshTap(_ sender: UITapGestureRecognizer){
        lblAreas.text = "All"
        lblProjects.text = "All"
    }
    
    
    @objc func areaTap(_ sender: UITapGestureRecognizer){
        if allAreas.count > 0{
            DataPickerDialog.PresentDataPickerDialog(ViewController: self, titleOfDialog: "Areas", selectionProtocol: self, datas: allAreas, targetAction: 1)
        }
    }
    
    @objc func projectTap(_ sender: UITapGestureRecognizer){
        if allProjects.count > 0{
            DataPickerDialog.PresentDataPickerDialog(ViewController: self, titleOfDialog: "Projects", selectionProtocol: self, datas: allProjects, targetAction: 2)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.searchHistories = DBManager().getLastSearchHistories()
        getProjectAndAreaFromWeb()
        
    }
    
    
    func getProjectAndAreaFromWeb(){
        
        let alter = ViewPatternMethods.waitingDialog(controller: self)
        
        let header = Dictionary<String, String>()
        
        allAreas.append("All")
        allProjects.append("All")
        
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
                                self.checkAllHistories()
                                self.historyTableView.reloadData()
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
    
    

    
    @objc func backTap(_ gest: UITapGestureRecognizer){
        self.dismiss(animated: true)
    }
    
    @IBAction func nextAction(_ sender: Any) {
        performSegue(withIdentifier: "location2search", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "location2search"{
            let dest = segue.destination as! SearchCTL
            dest.filterModel = SearchFilterModel(area: lblAreas.text ?? "All", project: lblProjects.text ?? "All")
        }
    }
    
    func checkAllHistories(){
        for item in self.searchHistories{
            if !(isSHInAreaAndProject(SH: item, projects: self.allProjects, areas: self.allAreas)){
                item.isDeleted = true
            }
        }
    }
    
    func isSHInAreaAndProject(SH: SearchHistoryModel, projects: [String], areas: [String])->Bool{

        let PAs = SH.title.split(separator: "/")
        ///TODO
        if(isSHInArea(area: String(PAs[1]), areas: areas)) && isSHInProjects(project: String(PAs[0]), projects: projects){
            return true
        }
        return false
        
    }
    
    func isSHInArea(area: String, areas: [String])->Bool{

        for item in areas{
            if item.trimmingCharacters(in: .whitespacesAndNewlines) == area.trimmingCharacters(in: .whitespacesAndNewlines){
                return true
            }
        }
        return false
    }
    
    func isSHInProjects(project: String, projects: [String])->Bool{
        for item in projects{
            if item.trimmingCharacters(in: .whitespacesAndNewlines) == project.trimmingCharacters(in: .whitespacesAndNewlines){
                return true
            }
        }
        return false
    }
    
   
}

extension SearchFilterCTL: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchHistories.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        print("\(indexPath.row) row edition")
        if (editingStyle == .delete){
            DBManager().deleteSearchHistoryBy(title: searchHistories[indexPath.row].title)
            searchHistories.remove(at: indexPath.row)
            tableView.beginUpdates()
            tableView.deleteRows(at: [indexPath], with: .fade)
            tableView.endUpdates()
            
        }
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
        let SH = self.searchHistories[indexPath.row]
        let seprates = SH.title.split(separator: "/")
        self.lblProjects.text = String(seprates[0]).trimmingCharacters(in: .whitespacesAndNewlines)
        self.lblAreas.text = String(seprates[1]).trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
}
