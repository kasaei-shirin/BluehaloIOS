//
//  DBManager.swift
//  Ninox
//
//  Created by saeed on 03/05/2023.
//

import Foundation
import SQLite

class DBManager:NSObject{
    
    var database : Connection!
    
//    String THEID = "_id";
//    String EMAIL = "email";
//    String TOKEN = "token";
//    String USERTYPE = "type";
    
    //user table columns
    let USERTABLE = Table("usertable")
   
    let UT_ID = Expression<Int>("user_id")
    let UT_EMAIL = Expression<String>("email")
    let UT_TOKEN = Expression<String>("token")
    let UT_ROLE = Expression<String>("role")
    let UT_REFRESHTOKEN = Expression<String>("refreshToken")
    let UT_NAME = Expression<String>("name")
    let UT_LASTNAME = Expression<String>("lastname")
    let UT_PHONE = Expression<String>("Phone")
    
    
//    String TABLENAME = "lastsearchtable";
//
//    String THEID = "_id";
//    String PROJECTAREA = "projectarea";
//    String DATETIME = "datetime";
    
    let LASTSEARCHTABLE = Table("lastsearchtable")
    
    let LST_ID = Expression<Int>("last_id")
    let LST_PROJECTAREA = Expression<String>("projectarea")
    let LST_DATETIME = Expression<String>("datetime")
    
    override init() {
       super.init()
       self.buildSQLiteDatabase()
       self.buildTables()
    }
    
    func buildSQLiteDatabase(){
        do{
            let documentDirectory = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
                let fileUrl = documentDirectory.appendingPathComponent("user").appendingPathExtension("sqlite3")
                let database = try Connection(fileUrl.path)
                self.database = database
        } catch{
            print(error)
        }
        
    }
    
    
    func buildTables(){
        
        print("\(self.database.userVersion) e rezo")
        print("\(self.database.sqliteVersion.major) check the major")
        print("\(self.database.sqliteVersion.minor) check the minor")
        print("\(self.database.sqliteVersion.point) check the point")
        print("\(self.database.sqliteVersion) check the versions")
        
        let createUserTable = self.USERTABLE.create { (table) in
            table.column(self.UT_ID, primaryKey: true)
            table.column(self.UT_EMAIL)
            table.column(self.UT_TOKEN)
            table.column(self.UT_ROLE)
            table.column(self.UT_REFRESHTOKEN)
            table.column(self.UT_NAME)
            table.column(self.UT_LASTNAME)
            table.column(self.UT_PHONE)
        }
        
        let createLastSearchTable = self.LASTSEARCHTABLE.create{(table)in
            table.column(self.LST_ID, primaryKey: .autoincrement)
            table.column(self.LST_PROJECTAREA)
            table.column(self.LST_DATETIME)
        }
        do{
            try self.database.run(createUserTable)
            try self.database.run(createLastSearchTable)
            print("\(self.database.sqliteVersion) check the versions")
            print("tables table created")
        }catch{
            print("in build user table")
            print(error)
        }
    }
    
    func insertOrUpdate(theUser : UserModel) {
       let userModel = self.getUserFromDB()
       if userModel != nil{
           updateUser(UM: theUser)
       }else{
           insertUser(userModel: theUser)
       }
    }
    
    func updateUser(UM: UserModel) {
     print("update user")
        let result = USERTABLE.filter(UT_ID == 1)
        do{
            
            var userModel = UM
            if userModel.token.trimmingCharacters(in: .whitespacesAndNewlines) == ""{
                let theUser = getUserFromDB()
                userModel.token = theUser!.token
                userModel.refreshToken = theUser!.refreshToken
            }
            
            try self.database.run(result.update(self.UT_ID <- 1, self.UT_EMAIL <- userModel.email, self.UT_TOKEN <- userModel.token, self.UT_ROLE <- userModel.role, self.UT_REFRESHTOKEN <- userModel.refreshToken, self.UT_NAME <- userModel.name, self.UT_LASTNAME <- userModel.lastname, self.UT_PHONE <- userModel.phoneNum))
            print("user updated")
        }catch{
            print(error)
        }
    }
       
    func deleteSearchHistoryBy(title: String){
        let filtered = LASTSEARCHTABLE.filter(LST_PROJECTAREA == title)
        do{
            try database.run(filtered.delete())
        }catch{
            print(error)
        }
    }
    
    func deleteSearchHistory(){
        do{
            try database.run(LASTSEARCHTABLE.delete())
        }catch{
            print(error)
        }
    }
        
    func deleteUser(){
        do{
            try database.run(USERTABLE.delete())
        }catch{
            print(error)
        }
    }
    
    func insertSearchHistory(SL: SearchHistoryModel){
        let result = self.LASTSEARCHTABLE.filter(self.LST_PROJECTAREA == SL.title)
        do{
            try self.database.run(result.delete())
        }catch{
            print(error)
        }
        let insSH = self.LASTSEARCHTABLE.insert(self.LST_PROJECTAREA<-SL.title, self.LST_DATETIME<-SL.dateTime)
        do{
            try self.database.run(insSH)
            print("search history inserted")
        }catch{
            print(error)
        }
    }
    
    
    func getLastSearchHistories() -> [SearchHistoryModel]{
        var SHMs = [SearchHistoryModel]()
        do{
            let LSTs = try self.database.prepare(self.LASTSEARCHTABLE.order(LST_ID.desc))
         
             for lst in LSTs{
                 let theID = lst[self.LST_ID]
                 let title = lst[self.LST_PROJECTAREA]
                 let dateTime = lst[self.LST_DATETIME]
                 
                 SHMs.append(SearchHistoryModel(theID: theID, title: title, dateTime: dateTime, isDeleted: false))
             }
            
        }catch{
            print("error when getting inserted users")
            print(error)
        }
        return SHMs
    }
    
    
    func insertUser(userModel : UserModel){
        print("insert fucking user")
        let insUser = self.USERTABLE.insert(self.UT_ID <- 1, self.UT_EMAIL <- userModel.email, self.UT_TOKEN <- userModel.token, self.UT_ROLE <- userModel.role, self.UT_REFRESHTOKEN <- userModel.refreshToken, self.UT_NAME <- userModel.name, self.UT_LASTNAME <- userModel.lastname, self.UT_PHONE <- userModel.phoneNum)
        do{
            try self.database.run(insUser)
            print("datas inserted")
        }catch{
            print(error)
        }
        
    }
    
    func getUserFromDB() -> UserModel? {
        do{
            let user = try self.database.prepare(self.USERTABLE)
         
             for u in user{
                 let email = u[self.UT_EMAIL]
                 let token = u[self.UT_TOKEN]
                 let role = u[self.UT_ROLE]
                 let refreshToken = u[self.UT_REFRESHTOKEN]
                 let name = u[self.UT_NAME]
                 let lastname = u[self.UT_LASTNAME]
                 let phone = u[self.UT_PHONE]
                 
                 return UserModel(email: email, token: token, refreshToken: refreshToken, name: name, lastname: lastname, phoneNum: phone, role: role)
                
            }
        }catch{
            print("error when getting inserted users")
            print(error)
            return nil
        }
        return nil
    }
    
}
