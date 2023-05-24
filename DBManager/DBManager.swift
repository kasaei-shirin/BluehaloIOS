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
    let UT_USERTYPE = Expression<Int>("roll")
    
    
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
        let createUserTable = self.USERTABLE.create { (table) in
            table.column(self.UT_ID, primaryKey: true)
            table.column(self.UT_EMAIL)
            table.column(self.UT_TOKEN)
            table.column(self.UT_USERTYPE)
        }
        
        let createLastSearchTable = self.LASTSEARCHTABLE.create{(table)in
            table.column(self.LST_ID, primaryKey: .autoincrement)
            table.column(self.LST_PROJECTAREA)
            table.column(self.LST_DATETIME)
        }
        do{
            try self.database.run(createUserTable)
            try self.database.run(createLastSearchTable)
            print("tables table created")
        }catch{
            print("in build user table")
            print(error)
        }
    }
    
    func insertOrUpdate(theUser : UserModel) {
       let userModel = self.getUserFromDB()
       if userModel != nil{
           updateUser(userModel: theUser)
       }else{
           insertUser(userModel: theUser)
       }
    }
    
    func updateUser(userModel: UserModel) {
     print("update user")
        let result = USERTABLE.filter(UT_ID == 1)
        do{
         try self.database.run(result.update(self.UT_ID <- 1, self.UT_EMAIL <- userModel.email, self.UT_TOKEN <- userModel.token, self.UT_USERTYPE <- userModel.userType))
            print("user updated")
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
             let LSTs = try self.database.prepare(self.LASTSEARCHTABLE)
         
             for lst in LSTs{
                 let theID = lst[self.LST_ID]
                 let title = lst[self.LST_PROJECTAREA]
                 let dateTime = lst[self.LST_DATETIME]
                 
                 SHMs.append(SearchHistoryModel(theID: theID, title: title, dateTime: dateTime))
             }
            
        }catch{
            print("error when getting inserted users")
            print(error)
        }
        return SHMs
    }
    
    
    func insertUser(userModel : UserModel){
        print("insert fucking user")
        let insUser = self.USERTABLE.insert(self.UT_ID <- 1, self.UT_EMAIL <- userModel.email, self.UT_TOKEN <- userModel.token, self.UT_USERTYPE <- userModel.userType)
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
                 let roll = u[self.UT_USERTYPE]
                 
                return UserModel(email: email, token: token, userType: roll)
                
            }
        }catch{
            print("error when getting inserted users")
            print(error)
            return nil
        }
        return nil
    }
    
}
