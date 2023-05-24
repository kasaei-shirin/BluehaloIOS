//
//  MyDateFormatter.swift
//  Ninox
//
//  Created by saeed on 12/05/2023.
//

import Foundation

//import Foundation
//import UIKit
//
class MyDateFormatter{
    
    func getDateFromDatePickerForSend(datee: Date?)->String{
        if let date = datee{
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            return formatter.string(from: date)
        }else{
            return ""
        }
    }
    
    func getCurrentDateTimeForSearchHistory()->String{
        let dt = Date()
        let df = DateFormatter()
        df.dateFormat = "yyyy MMM dd hh:mmaa"
        return df.string(from: dt)
    }
    
    func getSearchHistoryDateModelFromString(dateSTR: String)->Date{
        let df = DateFormatter()
        df.dateFormat = "yyyy MMM dd hh:mmaa"
        return df.date(from: dateSTR)!
    }
    
    func getYearForSearchHistory(dateSTR: String)->String{
        let date = getSearchHistoryDateModelFromString(dateSTR: dateSTR)
        let df = DateFormatter()
        df.dateFormat = "yyyy"
        return df.string(from: date)
    }
    
    func getMonthAndDayForSearchHistory(dateSTR: String)->String{
        let date = getSearchHistoryDateModelFromString(dateSTR: dateSTR)
        let df = DateFormatter()
        df.dateFormat = "dd, MMM"
        return df.string(from: date)
    }
    
    func getHourForSearchHistory(dateSTR: String)->String{
        let date = getSearchHistoryDateModelFromString(dateSTR: dateSTR)
        let df = DateFormatter()
        df.dateFormat = "hh:mmaa"
        return df.string(from: date)
    }
    
    func getDateFromServerDate(dateString: String)->Date?{
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        return formatter.date(from: dateString)
    }
    
    func getDateByCompleteMonthName(date: Date)->String{
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM dd, yyyy"
        return formatter.string(from: date)
    }
    
    func getDateFromString(dateString: String)->Date{
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.date(from: dateString) ?? Date()
    }
}
