//
//  SearchFilterCTL.swift
//  Ninox
//
//  Created by saeed on 09/05/2023.
//

import UIKit

class SearchFilterCTL: UIViewController , DataSelection{
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
        
        self.searchHistories = DBManager().getLastSearchHistories()
        
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
        
        getProjectAndAreaFromWeb()
    }
    
    @objc func refreshTap(_ sender: UITapGestureRecognizer){
        lblAreas.text = "All"
        lblProjects.text = "All"
    }
    
    
    @objc func areaTap(_ sender: UITapGestureRecognizer){
        DataPickerDialog.PresentDataPickerDialog(ViewController: self, titleOfDialog: "Areas", selectionProtocol: self, datas: allAreas, targetAction: 1)
    }
    
    @objc func projectTap(_ sender: UITapGestureRecognizer){
        DataPickerDialog.PresentDataPickerDialog(ViewController: self, titleOfDialog: "Projects", selectionProtocol: self, datas: allProjects, targetAction: 2)
    }
    
    
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
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension SearchFilterCTL: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchHistories.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.historyTableView.dequeueReusableCell(withIdentifier: "", for: indexPath)
        return cell
    }
    
    
}
