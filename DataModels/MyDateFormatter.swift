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
