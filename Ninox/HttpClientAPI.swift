//
//  HttpClientAPI.swift
//  Ninox
//
//  Created by saeed on 08/05/2023.
//

//HTTP Methods
import Foundation
import UIKit

enum HttpMethod : String {
    case  GET
    case  POST
    case  DELETE
    case  PUT
}



///most HttpClientApi call form this class except that requests that explained


class HttpClientApi: NSObject{
    
    //TODO: remove app transport security arbitary constant from info.plist file once we get API's
    var request : URLRequest?
    var session : URLSession?
    
    static func instance() ->  HttpClientApi{
        
        return HttpClientApi()
    }
    
    
    
    func makeAPICall(url: String, headers hs: Dictionary<String, String>,params: Dictionary<String, Any>?, method: HttpMethod, success:@escaping ( Data? ,HTTPURLResponse?  , NSError? ) -> Void, failure: @escaping ( Data? ,HTTPURLResponse?  , NSError? )-> Void) {
        
        
        print(url)
        let encoded = url.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed)
        
        request = URLRequest(url: URL(string: encoded!)!)
        
        //        logging.print("URL = \(url)")
        
        

        
        if let param = params {
            
            
            let  jsonData = try? JSONSerialization.data(withJSONObject: param, options: [])
            let jsonString = NSString(data: jsonData!, encoding: String.Encoding.utf8.rawValue)! as String
            print(jsonString)
            request?.httpBody = jsonString.data(using: .utf8)!//?.base64EncodedData()
            
            
            //paramString.data(using: String.Encoding.utf8)
        }
        print(request?.httpBody)
        
        request?.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request?.setValue("MOBILE", forHTTPHeaderField: "Targetdevice")
        let db = DBManager()
        let user = db.getUserFromDB()
        var headers = hs
        if let u = user{
        
            //todo baiad token beshe dobare token na in strigne maskhare azizaam
            print(u.token)
//                headers["Authorization"] = "Bearer "+token
            headers["Authorization"] = u.token

            
        }
//        headers["Authorization"] = "Bearer "+"eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1bmlxdWVfbmFtZSI6Ijg4ZjdlNWY4LWNlNmEtNGI4Ni1iZTdlLWZmYTU5NDEzZTdkMSIsIm5iZiI6MTU4MjM1ODE4MywiZXhwIjoxNTgyMzYxNzgzLCJpYXQiOjE1ODIzNTgxODN9.9SjVzaLZRRw3yhW1n1i2FtHlXmkDwwi-PZ2-NI-G-wk"
//        print("authorization : ")
//        print(headers["Authorization"])
        
        
        for (key, value) in headers {
            //                    print("\(key) -> \(value)")
            request?.setValue(value, forHTTPHeaderField: key)
        }
    
        
        
        request?.httpMethod = method.rawValue
        
        
        let configuration = URLSessionConfiguration.default
        
        configuration.timeoutIntervalForRequest = 30
        configuration.timeoutIntervalForResource = 30
        
        session = URLSession(configuration: configuration)
        //session?.configuration.timeoutIntervalForResource = 5
        //session?.configuration.timeoutIntervalForRequest = 5
        
        session?.dataTask(with: request! as URLRequest) { (data, response, error) -> Void in
            
            if let data = data {
                
                if let response = response as? HTTPURLResponse, 200...299 ~= response.statusCode {
                    success(data , response , error as? NSError)
                } else {
                    failure(data , response as? HTTPURLResponse, error as? NSError)
                }
            }else {
                
                failure(data , response as? HTTPURLResponse, error as? NSError)
                
            }
            }.resume()
        
    }
    
    /// Create request
    ///
    /// - parameter userid:   The userid to be passed to web service
    /// - parameter password: The password to be passed to web service
    /// - parameter email:    The email address to be passed to web service
    ///
    /// - returns:            The `URLRequest` that was created
    
    func sendImageWithMultipart(img: UIImage?, params: [String:String]?, url: String, success:@escaping ( Data? ,HTTPURLResponse?  , NSError? ) -> Void, failure: @escaping ( Data? ,HTTPURLResponse?  , NSError? )-> Void)->Void{
        
        let boundary = generateBoundaryString()
        
        let url = URL(string: url)!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        let db = DBManager()
        let user = db.getUserFromDB()
//        if let u = user{
//            if let token = u.token{
//                //todo baiad token beshe dobare token na in strigne maskhare azizaam
//                request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
//
//                 print("fuckin here")
//                 print(token)
//
//            }
//        }
        
        request.httpBody = createBody(with: params, boundary: boundary, image: img)
        
        
        let configuration = URLSessionConfiguration.default
        
        configuration.timeoutIntervalForRequest = 200
        configuration.timeoutIntervalForResource = 200
        
        session = URLSession(configuration: configuration)
        
        
        session?.dataTask(with: request as URLRequest) { (data, response, error) -> Void in
            
            if let data = data {
                
                if let response = response as? HTTPURLResponse, 200...299 ~= response.statusCode {
                    success(data , response , error as? NSError)
                } else {
                    failure(data , response as? HTTPURLResponse, error as? NSError)
                }
            }else {
                
                failure(data , response as? HTTPURLResponse, error as? NSError)
                
            }
            }.resume()
    }
    
    
    
    /// Create body of the `multipart/form-data` request
    ///
    /// - parameter parameters:   The optional dictionary containing keys and values to be passed to web service
    /// - parameter filePathKey:  The optional field name to be used when uploading files. If you supply paths, you must supply filePathKey, too.
    /// - parameter paths:        The optional array of file paths of the files to be uploaded
    /// - parameter boundary:     The `multipart/form-data` boundary
    ///
    /// - returns:                The `Data` of the body of the request
    
    private func createBody(with parameters: [String: String]?, boundary: String, image: UIImage?)->Data {
        var body = Data()
        
        if parameters != nil {
            for (key, value) in parameters! {
                body.append("--\(boundary)\r\n".data(using: .utf8)!)
                body.append("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n".data(using: .utf8)!)
                body.append("\(value)\r\n".data(using: .utf8)!)
            }
        }
        
        
        if let img = image{
            let mimetype = "image/jpeg"
            let filename = UUID().uuidString+".jpg"
            
            let imageData = img.jpegData(compressionQuality: 1.0)
            body.append("--\(boundary)\r\n".data(using: .utf8)!)
            body.append("Content-Disposition: form-data; name=\"file\"; filename=\"\(filename)\"\r\n".data(using: .utf8)!)
            body.append("Content-Type: \(mimetype)\r\n\r\n".data(using: .utf8)!)
            body.append(imageData!)
            body.append("\r\n".data(using: .utf8)!)
        }
        
        //        for path in paths {
        //            let url = URL(fileURLWithPath: path)
        //            let filename = url.lastPathComponent
        //            let data = try Data(contentsOf: url)
        //            let mimetype = mimeType(for: path)
        
        //        }
        
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        return body
    }
    
    /// Create boundary string for multipart/form-data request
    ///
    /// - returns:            The boundary string that consists of "Boundary-" followed by a UUID string.
    
    private func generateBoundaryString() -> String {
        return "Boundary-\(UUID().uuidString)"
    }
    
}
