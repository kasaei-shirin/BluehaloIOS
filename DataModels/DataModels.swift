//
//  UserModel.swift
//  Ninox
//
//  Created by saeed on 03/05/2023.
//

import Foundation

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
