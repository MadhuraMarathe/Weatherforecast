//
//  CommunicationServiceProtocol.swift
//  MMOpenWeatherForecast
//
//  Created by Madhura Marathe on 1/20/17.
//  Copyright © 2017 Madhura. All rights reserved.
//

import Foundation

/*This generic protocol which is implemented in every Webservice class.
    Used to call these methods when HTTPCommunication class receives any kind of response
 */
protocol CommunicationServiceProtocol {
    
    // required methods
    func getRequestURLForCityWithId() -> String
    func getRequestURLForCityWithName() -> String
    func handleResponse(_ data:Data)
    func handleFailure(_ error:NSError)
    func getHttpMethod() -> HTTP_METHOD
    
    // Optional methods
    func getRequestBody() -> AnyObject?
    func getHttpHeaders() -> NSDictionary? // marked as optional as not all requests may have headers and request bodies
    
    
}
