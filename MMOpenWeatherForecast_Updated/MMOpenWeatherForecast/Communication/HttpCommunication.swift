//
//  HttpCommunication.swift
//  MMOpenWeatherForecast
//
//  Created by Madhura Marathe on 1/20/17.
//  Copyright © 2017 Madhura. All rights reserved.
//

import Foundation

// MARK: - Enum.
enum HTTP_METHOD : String {
    case GET = "GET"
    case POST = "POST"
    case PUT = "PUT"
}

enum HTTP_RESPONSE_CODES : Int {
    case success = 200
    case bad_REQUEST = 400
    case not_FOUND = 404
}

class HttpCommunication: NSObject {
    // MARK: - Variables.
    static let sharedInstance = HttpCommunication()
    
    // MARK: - Functions.
    func fetch(requestUrlStr : String, responseHandler: @escaping (_ response: Data?, _ error: NSError?)->Void) {
        if let requestURL = URL(string: requestUrlStr) {
            //let requestURL : URL = URL(string: requestUrlStr)!
            var urlRequest  = URLRequest(url: requestURL)
            urlRequest.httpMethod = HTTP_METHOD.GET.rawValue
            urlRequest.cachePolicy = .reloadIgnoringCacheData
            print("Request URL : \(requestURL)\n")
            let task = URLSession.shared.dataTask(with: urlRequest as URLRequest) {
                // completion handler
                (data: Data?, response: URLResponse?, error: Error?) -> Void in
                if let error  = error {
                    print("Request Failure!")
                    responseHandler(nil,error as NSError?)
                } else {
                    let httpResponse = response as! HTTPURLResponse
                    let statusCode = httpResponse.statusCode
                    // success
                    if (statusCode == HTTP_RESPONSE_CODES.success.rawValue) {
                        if data != nil {
                            print("Request Success!")
                            responseHandler(data,nil)
                        } else {
                            // data is nil. error
                            let userInfo: [AnyHashable : Any]? =
                                [
                                    NSLocalizedDescriptionKey :  NSLocalizedString("Error", value: "No response data received", comment: "")
                            ]
                            let error: NSError = NSError(domain: "", code: -1, userInfo: userInfo)
                            print("Request Failure!")
                            //service.handleFailure(err)
                            responseHandler(nil,error as NSError?)
                        }
                    }
                    else
                        if (statusCode == HTTP_RESPONSE_CODES.not_FOUND.rawValue) {
                            let userInfo: [AnyHashable : Any]? =
                                [
                                    NSLocalizedDescriptionKey :  NSLocalizedString("Error", value: "City not found. Please add valid City Name.", comment: "")
                            ]
                            let error: NSError = NSError(domain: "", code:  HTTP_RESPONSE_CODES.not_FOUND.rawValue, userInfo: userInfo)
                            print("Request Failure!")
                            responseHandler(nil,error as NSError?)
                    }
                }
            }
            task.resume()
        } else{
            // request url not formed
            print("Request URL : \(requestUrlStr)\n")
            let userInfo: [AnyHashable : Any]? =
                [
                    NSLocalizedDescriptionKey :  NSLocalizedString("Error", value: "Not a valid url", comment: "")
            ]
            let error: NSError = NSError(domain: "", code: -1, userInfo: userInfo)
            print("Request Failure!")
            //service.handleFailure(err)
            responseHandler(nil,error as NSError?)
        }
    }
}
