//
//  AppDelegate.swift
//  Ninox
//
//  Created by saeed on 20/04/2023.
//

import UIKit
import Network


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
//        self.title = self.
    }
    
    override func viewDidAppear(_ animated: Bool) {
//        userReachability()
        getUserInfo(TRY: 1)
        
        print("VC : \(self)")
    }
    
    
//    func userReachability(){
//        do {
//            print("try")
//            try Network.reachability = Reachability(hostname: "https://saaiota.ca/")
////            monitorNetwork()
//        }
//        catch {
//            switch error as? Network.Error {
//            case let .failedToCreateWith(hostname)?:
//                print("Network error:\nFailed to create reachability object With host named:", hostname)
//            case let .failedToInitializeWith(address)?:
//                print("Network error:\nFailed to initialize reachability object With address:", address)
//            case .failedToSetCallout?:
//                print("Network error:\nFailed to set callout")
//            case .failedToSetDispatchQueue?:
//                print("Network error:\nFailed to set DispatchQueue")
//            case .none:
//                print(error)
//            }
//        }
//    }
    
    func getUserInfo(TRY: Int){
        HttpClientApi.instance().makeAPICall(viewController: self, refreshReq: false, url: URLSV2.ME, headers: Dictionary<String, String>(), params: nil, method: .GET) { data, response, error in
            
            let json = try? JSONSerialization.jsonObject(with: data!, options: [])
            
            DispatchQueue.main.async {
                
                
                self.monitorNetwork()
//
//
//                if let j = json as? [String:Any]{
//                    message = j["message"] as? String ?? ""
//                    if let success = j["success"] as? String{
//                        if(success == "true"){
//                            return
//                        }
//                    }
//                }
//                DBManager().deleteUser()
//                let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
//                let dest = mainStoryboard.instantiateInitialViewController()
//                self.present(dest!, animated: true)
            }
            
            
        } failure: { data, response, error in
            
            DispatchQueue.main.async {
                if TRY < 3{
                    self.getUserInfo(TRY: TRY+1)
                }else{
                    self.showNetworkProblemPopup()
                }
            }
            
            print(data)
            print(response)
            print(error)
        }

    }
    
    var theAlert: UIAlertController?
    var monitor: NWPathMonitor?
    
    func monitorNetwork(){
        self.monitor = NWPathMonitor()
        self.monitor?.pathUpdateHandler = {
            path in
            
            switch path.status{
            case .satisfied:
                print("network satisfied!")
//                self.getUserInfo(TRY: 1)
            case .requiresConnection:
                print("network requiresConnection!")
            case .unsatisfied:
                print("network unsatisfied!")
            }
            
            if path.status != .satisfied{
                DispatchQueue.main.async {
                    if self.theAlert == nil{
                        
                        self.showNetworkProblemPopup()
                    }
                }
            }
            else{
                if let alert = self.theAlert{
                    DispatchQueue.main.async {
                        alert.dismiss(animated: true)
                        self.theAlert = nil
                    }
                }
                print("network satisfied")
            }
        }
        let queue = DispatchQueue(label: "Network")
        self.monitor?.start(queue: queue)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        print("disappear \(self)")
        
        monitor?.cancel()
    }
    
    func showNetworkProblemPopup(){
        self.theAlert = ViewPatternMethods.showAlert(controller: self, title: "Network", message: "Check your network connection!!!", handler: UIAlertAction(title: "OK", style: .default, handler: { UIAlertAction in
            let url = URL(string: "App-Prefs:root=General")
            let app = UIApplication.shared
            app.open(url!, options: [:], completionHandler: nil)
        }))
//        self.theAlert?.dismiss(animated: true, completion: {
//            self.present(self.theAlert!, animated: true)
//        })
    }

}
