//
//  APIManager.swift
//  TaipeiParkProject
//
//  Created by Hsiao Wind on 2018/6/10.
//  Copyright © 2018年 Hsiao. All rights reserved.
//

import Foundation

enum HttpMethod {
    static let get = "GET"
    static let post = "POST"
    static let put = "PUT"
    static let delete = "DELETE"
}

let apiURL = "http://beta.data.taipei/opendata/datalist/apiAccess"

typealias getListDataCompletionHandler = (GetListResult?, APIError?) -> Void

class APIManager {
    static let shared = APIManager()
    private let session:URLSession
    private let operationQueue:OperationQueue
    
    private init() {
        let sessionConfig = URLSessionConfiguration.ephemeral
        sessionConfig.timeoutIntervalForRequest = 5.0
        
        self.operationQueue = OperationQueue()
        self.session = URLSession(configuration: sessionConfig, delegate: nil, delegateQueue: self.operationQueue)
    }
    
    func getListDataWithPage(_ page: Int, _ completionHandler : @escaping getListDataCompletionHandler) {
        let requestData = GetListRequest(offset: page)
        let request = createNormalGetRequest(from: requestData, path: "")
    
        let task = self.session.dataTask(with: request, completionHandler: { (data: Data?, response: URLResponse?, error: Error?) -> Void in
            
            guard error == nil else {
                /***
                 Network & Http error
                 ***/
                if let error = error as NSError? {
                    if error.code == NSURLErrorCancelled {
                        let error = APIError.operationCanceled
                        completionHandler(nil,error)
                    } else {
                        let error = APIError.networkError
                        completionHandler(nil,error)
                    }
                    return
                } else {
                    let error = APIError.unknown
                    completionHandler(nil,error)
                    return
                }
            }
            
            guard data != nil else {
                /***
                 ResponseData error
                 ***/
                let error = APIError.responseDataNil
                completionHandler(nil,error)
                return
            }
            
            let decoder = JSONDecoder()
            do {
                let response = try decoder.decode(GetListResult.self, from: data!)
                /***
                 Success
                 ***/
//                if (response.status == 1){
//                    completionHandler(response,nil)
//                } else {
//                    let wiError = WIError.init(status:response.status!)
//                    completionHandler(nil,wiError)
//                }
                completionHandler(response, nil)
            } catch {
                /***
                 Cannot parse json, or key is missing
                 ***/
                let error = APIError.JSONConvertFail
                completionHandler(nil,error)
                return
            }
        })
        task.resume()
    }
    
    /***
     normal api
     ***/
    final private func createNormalGetRequest(from object: DictionaryEncodable, path:String) -> URLRequest {
        var urlString = apiURL + path
        if object.dictionary()?.count != 0 {
            object.dictionary()?.enumerated().forEach {
                switch $0.offset {
                case 0:
                    urlString.append("?\($0.element.key)=\($0.element.value)")
                default:
                    urlString.append("&\($0.element.key)=\($0.element.value)")
                }
            }
        }
        print("urlString = \(urlString)")
        var request = URLRequest(url: URL(string: urlString)!)
        request.httpMethod = HttpMethod.get
//        request.setValue("application/x-www-form-urlencoded; charset=utf-8", forHTTPHeaderField: "Content-Type")
        return request
    }
}
