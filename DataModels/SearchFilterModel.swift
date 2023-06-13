//
//  SearchFilterModel.swift
//  Ninox
//
//  Created by saeed on 23/05/2023.
//

import Foundation

class SearchFilterModel{

    var area: String?
    var project: String?
    
    var rssiRange: Int?
    var flagType: Int?
    
    var cautionEnabled: Bool?
    var batteryWarning: Bool?
    var isOnGoing: Bool?
    
    init(area: String, project: String){
        if area.lowercased() != "all"{
            print("lowerd casesh all nabood")
            self.area = area
        }
        if project.lowercased() != "all"{
            self.project = project
        }
    }
    
    func getRangeByRssi(rssi: Int)->Int{
        if rssi <= RSSIModel.RSSI1 && rssi >= RSSIModel.RSSI2{
            return 4
        }else if rssi < RSSIModel.RSSI2 && rssi >= RSSIModel.RSSI3{
            return 3
        }else if rssi < RSSIModel.RSSI3 && rssi >= RSSIModel.RSSI4{
            return 2
        }else if rssi < RSSIModel.RSSI4 && rssi >= RSSIModel.RSSI5{
            return 1
        }else{
            return 0
        }
    }
    
    func tagAcceptByFilter(tag: TagModel)->Bool{

        if let ar = self.area{
            if tag.area != ar && area != ""{
                print("areaFalse")
                return false
            }
        }
        if let pro = self.project{
            if tag.project == pro && pro != ""{
                print("project false")
                return false
            }
        }
        if let RR = rssiRange{
            if RR > getRangeByRssi(rssi: tag.rssi){
                print("rssi false")
                return false
            }
        }
        if let FT = flagType{
            if FT != tag.flagType && FT != 0{
                print("flag type false")
                return false
            }
        }
        if let IOG = isOnGoing{
            
            if tag.isOnGoing == false && IOG{
                print("is on going false")
                return false
            }
        }
        return true
    }
    
    
}
