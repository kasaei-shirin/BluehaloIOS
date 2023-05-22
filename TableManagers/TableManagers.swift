//
//  TableManagers.swift
//  Ninox
//
//  Created by saeed on 21/05/2023.
//

import UIKit


class ServiceDateTableManager:NSObject, UITableViewDelegate, UITableViewDataSource{
    
    var serviceDates: [TargetServiceDate]
    var tableView: UITableView
    var showAll: Bool
    
    init(serviceDates: [TargetServiceDate], tableView: UITableView, showAll: Bool) {
        
        self.serviceDates = serviceDates
        self.tableView = tableView
        
        self.showAll = showAll

    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 35
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("countesh dar custmanager : \(serviceDates.count)")
        if showAll{
            return serviceDates.count
        }
        if(serviceDates.count > 0){
            return 1
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        print("the heght called")
        return 35
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "serviceDateCell", for: indexPath) as! ServiceDateSPCell
        
        let SD = self.serviceDates[indexPath.row]
        cell.lblTitle.text = SD.title
        cell.lblDate.text = MyDateFormatter().getDateByCompleteMonthName(date: SD.date)
        return cell
    }
    
    
}


class CustomInfoTableManager:NSObject, UITableViewDelegate, UITableViewDataSource{
    
    var custInfos: [TargetCustomInfo]
    var tableView: UITableView
    var showAll: Bool
    
    init(custInfos: [TargetCustomInfo], tableView: UITableView, showAll: Bool) {
        
        self.custInfos = custInfos
        self.tableView = tableView
        self.showAll = showAll

    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 35
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("countesh dar custmanager : \(custInfos.count)")
        if showAll {
            return custInfos.count
        }
        if custInfos.count > 0{
            return 1
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        print("the heght called")
        return 35
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        print("does it comes here0")
        let cell = tableView.dequeueReusableCell(withIdentifier: "customInfoCell", for: indexPath) as! CustomInfoSPCell
        
        print("does it comes here")
        let CI = custInfos[indexPath.row]
        cell.lblTitle.text = CI.headerName
        cell.lblInfo.text = CI.info
        
        print("\(indexPath.row) in this row with title : \(CI.headerName)")
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        print("will display custom \(indexPath.row)")
    }
    
}
