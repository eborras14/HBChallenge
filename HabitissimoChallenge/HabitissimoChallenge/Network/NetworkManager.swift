//
//  NetworkManager.swift
//  HabitissimoChallenge
//
//  Created by Eduard Borras Ruiz on 26/4/21.
//

import UIKit
import AFNetworking
import ObjectMapper

class NetworkManager: NSObject {
    
    static let shared = NetworkManager()
    
    private override init(){}
    
    func GETListRequest<T: Mappable>(_ url: String,
                    headers: [String: String]?,
                    parameters: [String: Any]?,
                    model: T.Type,
                    success: @escaping (_ modelList: [T]) -> (),
                    failure: @escaping (_ error: Error) -> ()){
        
        let manager: AFHTTPSessionManager = AFHTTPSessionManager()
        manager.requestSerializer = AFHTTPRequestSerializer()
        manager.get(url, parameters: parameters, headers: headers, progress: nil) { (task, responseObject) in
            
            var objects: [T] = []
            let jsonResult = responseObject as? Array<Dictionary <String, AnyObject>>

            if let jsonResult = jsonResult {
                
                for jsonDict in jsonResult
                {
                    let modelParsed = model.init(JSON: jsonDict)
                    if let modelParsed = modelParsed {
                        objects.append(modelParsed)
                    }
                }
                
                success(objects)
            }
        } failure: { (operation, error) in
            failure(error)
        }

    }
    
    //TODO: Rest of methods for send and receive data

}
