//
//  LocationCTL.swift
//  Ninox
//
//  Created by saeed on 03/05/2023.
//

import UIKit

class LocationCTL: UIViewController {

    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        
    }
    
    
    
//    func getProjectAndAreaFromWeb(){
//        
//        let alter = ViewPatternMethods.waitingDialog(controller: self)
//        
//        let header = Dictionary<String, String>()
//        
//        HttpClientApi.instance().makeAPICall(url: URLS.PROJAREA, headers: header, params: nil, method: .GET) { data, response, error in
//            
//            DispatchQueue.main.async {
//                alter.dismiss(animated: true)
//            }
//            
//            let json = try? JSONSerialization.jsonObject(with: data!, options: [])
//            
//            if let j = json as? [String:Any]{
//                
//                print(j)
//                if let success = j["success"] as? String{
//                    DispatchQueue.main.async {
//                        let areasOPT = j["area"] as? [String]
//                        if let areas = areasOPT{
//                            for area in areas {
//                                self.allAreas.append(area)
//                            }
//                        }
//                        let projectsOPT = j["project"] as? [String]
//                        if let projects = projectsOPT{
//                            for project in projects {
//                                self.allProjects.append(project)
//                            }
//                        }
//                        
////                        self.initProjectAndAreaDropDown()
//                    }
//                }
//            }
//            
//        } failure: { data, response, error in
//            
//            DispatchQueue.main.async {
//                alter.dismiss(animated: true)
//            }
//            
//            print(data)
//            print(response)
//            print(error)
//        }
//    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
