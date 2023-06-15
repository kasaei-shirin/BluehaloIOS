//
//  AppDelegate.swift
//  Ninox
//
//  Created by saeed on 20/04/2023.
//

import UIKit


func going2SplashFrom(controller: UIViewController, withClearingDB: Bool){
    if(withClearingDB){
        DBManager().deleteUser()
    }
    let storyboard = UIStoryboard(name: "main", bundle: nil)
    guard let splashCTL = storyboard.instantiateInitialViewController() else { return }
    controller.present(splashCTL, animated: true)
}

 @main
class AppDelegate: UIResponder, UIApplicationDelegate {



    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
//        UIApplication.shared.statusBarView?.backgroundColor = UIColor.red
        
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }


}


class MyViewController: UIViewController{
    override var preferredStatusBarStyle: UIStatusBarStyle {
          return .lightContent
    }
    
    override func viewDidLoad() {
        
    }
    
    
    func getUserInfo(){
        HttpClientApi.instance().makeAPICall(url: URLS.USERINFO, headers: Dictionary<String, String>(), params: nil, method: .GET) { data, response, error in
            
            let json = try? JSONSerialization.jsonObject(with: data!, options: [])
            
            var message = ""
            
            DispatchQueue.main.async {
                if let j = json as? [String:Any]{
                    message = j["message"] as? String ?? ""
                    if let success = j["success"] as? String{
                        if(success == "true"){
                            return
                        }
                    }
                }
                DBManager().deleteUser()
                let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
                let dest = mainStoryboard.instantiateInitialViewController()
                self.present(dest!, animated: true)
            }
            
            
        } failure: { data, response, error in
            print(data)
            print(response)
            print(error)
        }

    }
}
