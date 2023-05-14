//
//  UserModel.swift
//  Ninox
//
//  Created by saeed on 03/05/2023.
//

import Foundation
import UIKit

class UserModel{
    var email: String
    var token: String
    var userType: Int
    
    init(email: String, token: String, userType: Int) {
        self.email = email
        self.token = token
        self.userType = userType
    }
    
}

class SearchHistoryModel{

    var theID: Int
    
    var title: String
    var dateTime: String
    
    var isDeleted: Bool?
    
    init(theID: Int, title: String, dateTime: String, isDeleted: Bool? = nil) {
        self.theID = theID
        self.title = title
        self.dateTime = dateTime
        self.isDeleted = isDeleted
    }
    
}


class TagModel{
    var flagType: Int
    var flagNote: String
    var project: String
    var area: String
    var _id: String
    var decryptionCode: String
    var publicAddress: String
    var productName: String
    var deviceName: String
    var alias: String
    var email: String
    var manufactureID: String
    var tagBatteryExpireDate: String
    var activationDate: String
    var targetExpireDate: String
    var isOnGoing: Bool
    var cte: Bool
    var update: Bool
    var lastBatteryAmount: Float
    var lastFindingDate: String
    var advertisementInterval: Int
    var iconType: Int
    var batteryReplacementLimit: Int
    var txPower: Int
    var previousTagAssignments: [String]
    var tempratureEachConnection: [Temprature]
    var targetServiceDates: [TargetServiceDate]
    var targetCustomInfos: [TargetCustomInfo]
    
    var uuid: String
    
    var rssi: Int
    
    init(flagType: Int, flagNote: String, project: String, area: String, _id: String, decryptionCode: String, publicAddress: String, productName: String, deviceName: String, alias: String, email: String, manufactureID: String, tagBatteryExpireDate: String, activationDate: String, targetExpireDate: String, isOnGoing: Bool, cte: Bool, update: Bool, lastBatteryAmount: Float, lastFindingDate: String, advertisementInterval: Int, iconType: Int, batteryReplacementLimit: Int, txPower: Int, previousTagAssignments: [String], tempratureEachConnection: [Temprature], targetServiceDates: [TargetServiceDate], targetCustomInfos: [TargetCustomInfo], uuid: String) {
        self.flagType = flagType
        self.flagNote = flagNote
        self.project = project
        self.area = area
        self._id = _id
        self.decryptionCode = decryptionCode
        self.publicAddress = publicAddress
        self.productName = productName
        self.deviceName = deviceName
        self.alias = alias
        self.email = email
        self.manufactureID = manufactureID
        self.tagBatteryExpireDate = tagBatteryExpireDate
        self.activationDate = activationDate
        self.targetExpireDate = targetExpireDate
        self.isOnGoing = isOnGoing
        self.cte = cte
        self.update = update
        self.lastBatteryAmount = lastBatteryAmount
        self.lastFindingDate = lastFindingDate
        self.advertisementInterval = advertisementInterval
        self.iconType = iconType
        self.batteryReplacementLimit = batteryReplacementLimit
        self.txPower = txPower
        self.previousTagAssignments = previousTagAssignments
        self.tempratureEachConnection = tempratureEachConnection
        self.targetServiceDates = targetServiceDates
        self.targetCustomInfos = targetCustomInfos
        self.rssi = 0
        self.uuid = uuid
    }
    
    
    init(json: [String:Any], rssi: Int, uuidString: String){
        self.project = json["project"] as? String ?? ""
        self.area = json["area"] as? String ?? ""
        self._id = json["_id"] as? String ?? ""
        self.decryptionCode = json["decryptionCode"] as? String ?? ""
        self.publicAddress = json["publicAddress"] as? String ?? ""
        self.productName = json["productName"] as? String ?? ""
        self.deviceName = json["deviceName"] as? String ?? ""
        self.alias = json["alias"] as? String ?? ""
        self.email = json["email"] as? String ?? ""
        self.manufactureID = json["manufactureId"] as? String ?? ""
        self.tagBatteryExpireDate = json["tagBatteryExpireDate"] as? String ?? ""
        self.activationDate = json["activationDate"] as? String ?? ""
        self.targetExpireDate = json["targetExpireDate"] as? String ?? ""
        self.isOnGoing = json["isOnGoing"] as? Bool ?? false
        self.cte = json["cte"] as? Bool ?? false
        self.update = json["update"] as? Bool ?? false
        self.lastBatteryAmount = json["lastBatteryAmount"] as? Float ?? 0.0
        self.lastFindingDate = json["lastFindingDate"] as? String ?? ""
        self.advertisementInterval = json["advertisementInterval"] as? Int ?? 0
        self.iconType = json["iconType"] as? Int ?? 0
        self.batteryReplacementLimit = json["batteryReplacementLimit"] as? Int ?? 0
        self.txPower = json["txPower"] as? Int ?? 0
        self.flagType = json["flagType"] as? Int ?? 0
        self.flagNote = json["flagNote"] as? String  ?? ""
        self.previousTagAssignments = []
        let PTAs = json["previousTagAssignments"] as? [String] ?? []
        for item in PTAs{
            self.previousTagAssignments.append(item)
        }
        self.tempratureEachConnection = []
        let TECs = json["tempratureEachConnection"] as? [[String:Any]] ?? []
        for item in TECs{
            self.tempratureEachConnection.append(Temprature(json: item))
        }
        self.targetServiceDates = []
        let TSDs = json["targetServiceDates"] as? [[String:Any]] ?? []
        for item in TSDs{
            self.targetServiceDates.append(TargetServiceDate(json: item))
        }
        self.targetCustomInfos = []
        let TCIs = json["targetCustomInfo"] as? [[String:Any]] ?? []
        for item in TCIs{
            self.targetCustomInfos.append(TargetCustomInfo(json: item))
        }
        self.rssi = rssi
        self.uuid = uuidString
    }
    
    
}

class Temprature{
    var _id: String
    var date: String
    var temprature: Int
    
    init(_id: String, date: String, temprature: Int) {
        self._id = _id
        self.date = date
        self.temprature = temprature
    }
    
    init(json: [String:Any]){
        self.temprature = json["temprature"] as? Int ?? 0
        self.date = json["date"] as? String ?? ""
        self._id = json["_id"] as? String ?? ""
    }
}

class TargetServiceDate{
    var title: String
    var date: Date
    var _id: String
    
    init(title: String, date: Date, _id: String) {
        self.title = title
        self.date = date
        self._id = _id
    }
    
    init(json: [String:Any]){
        
        let dateString = json["date"] as? String ?? ""
        if dateString != ""{
            let formatter = DateFormatter()
            self.date = MyDateFormatter().getDateFromString(dateString: dateString)
        }else{
            self.date = Date()
        }
        
        self.title = json["title"] as? String ?? ""
        self._id = json["_id"] as? String ?? ""
    }
    
    func getJSON()->[String:Any]{
        var params = [String:Any]()
        params["title"] = self.title
        params["date"] = MyDateFormatter().getDateFromDatePickerForSend(datee: self.date)
        return params
    }
    
}

class TargetCustomInfo{
    
    var headerName: String
    var info: String
    var _id: String
    
    init(headerName: String, info: String, _id: String) {
        self.headerName = headerName
        self.info = info
        self._id = _id
    }
    
    init(json: [String:Any]){
        self.headerName = json["headerName"] as? String ?? ""
        self.info = json["info"] as? String ?? ""
        self._id = json["_id"] as? String ?? ""
    }
    
    func getJSON()->[String:Any]{
        var params = [String:Any]()
        params["headerName"] = headerName
        params["info"] = info
        return params
    }

}


class IconTypeModel{
    
    var code: Int
    var title: String
    var resourceName: String
    
    init(code: Int, title: String, resourceName: String) {
        self.code = code
        self.title = title
        self.resourceName = resourceName
    }
    
    func getImage()->UIImage?{
        return UIImage(named: self.resourceName)
    }
    
    func getIconByCode(code: Int)->IconTypeModel{
        let ITs = IconTypeModel.getIconTypes()
        for item in ITs{
            if item.code == code{
                return item
            }
        }
        return ITs[0]
    }
    
    class func getIconTypes() -> [IconTypeModel]{
        var iconTypes = [IconTypeModel]()
        iconTypes.append(IconTypeModel(code: 0, title: "VacuumCleaner", resourceName: "icontype_vacuum"))
        iconTypes.append(IconTypeModel(code: 1, title: "Bag", resourceName: "icontype_bag"))
        iconTypes.append(IconTypeModel(code: 2, title: "Fan", resourceName: "icontype_fan"))
        iconTypes.append(IconTypeModel(code: 3, title: "Guitar", resourceName: "icontype_guitar"))
        iconTypes.append(IconTypeModel(code: 4, title: "Laptop", resourceName: "icontype_laptop"))
        iconTypes.append(IconTypeModel(code: 5, title: "Monitor", resourceName: "icontype_monitor"))
        iconTypes.append(IconTypeModel(code: 6, title: "Mouse", resourceName: "icontype_mouse"))
        iconTypes.append(IconTypeModel(code: 7, title: "PC", resourceName: "icontype_pc"))
        iconTypes.append(IconTypeModel(code: 8, title: "TV", resourceName: "icontype_tv"))
        iconTypes.append(IconTypeModel(code: 9, title: "Watch", resourceName: "icontype_watch"))
        return iconTypes
    }
    
}
