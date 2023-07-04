//
//  URLS.swift
//  Ninox
//
//  Created by saeed on 08/05/2023.
//

import Foundation


class URLS{
    static let BASEURL = "https://siaxinc.ca/"
    
    static let SIGNIN = BASEURL+"api/login"
    static let REGISTER = BASEURL+"api/register"
    static let USERINFO = BASEURL+"api/userinfo"
    static let SETUPTAG = BASEURL+"api/tagsetup"
    static let PROJAREA = BASEURL+"api/userprojectarea"
    static let AddArea = BASEURL+"api/adduserarea"
    static let AddProject = BASEURL+"api/adduserproject"
    static let DeleteAreaProject = BASEURL+"api/deleteuserprojectarea"
    static let EDITPROJECT = BASEURL+"api/edituserproject"
    static let EDITAREA = BASEURL+"api/edituserarea"
    static let batteryAlert = BASEURL+"api/battreyrange"
    static let FlagURL = BASEURL+"api/flagtype"
    static let deleteTag = BASEURL+"api/tagdelete"
    static let targetInfoDelete = BASEURL+"api/targetinfodelete"
}


class URLSV2{
    static let BASEURL = "https://saaiota.ca/api"
    
    static let SIGNIN = BASEURL+"/auth/sign-in"
    static let REFRESHTOKEN = BASEURL+"/auth/refreshToken"
    static let ME = BASEURL+"/users/me"
    static let COMPANYPROJECT = BASEURL+"/company-projects"
    static let PROJECTAREAS = BASEURL+"/project-areas"
    static let TAGS = BASEURL+"/tags"
    static let MOVETAG = BASEURL+"/moved-tags"
}
