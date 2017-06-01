//
//  WeatherForecastManager.swift
//  MMOpenWeatherForecast
//
//  Created by Madhura Marathe on 1/20/17.
//  Copyright © 2017 Madhura. All rights reserved.
//

import Foundation
import CoreData

class WeatherForecastManager {
    // MARK: - Variables.
    var cityId: Int = -1
    var cityName : String?
    static let sharedInstance = WeatherForecastManager()
    
    // MARK: - Functions.
    private func getBaseUrl() -> String {
        var baseUrl : String?
        if let plist = PlistManager(name: "UrlPlist") {
            plist.save()
            print(plist.getValuesInPlistFile())
            let plistData = plist.getValuesInPlistFile()
            baseUrl = plistData?.value(forKey: "BaseUrl") as! String?
        } else {
            print("Unable to get Plist")
        }
        return baseUrl!
    }
    
    private func formRequestURLForCityWithId(cityId : Int) -> String {
        var weatherInfoURL  = getBaseUrl()
        //Add city id
        weatherInfoURL += "\(WebserviceRequest.cityId)="
        weatherInfoURL += String(cityId)
        //Add App ID
        weatherInfoURL += "&\(WebserviceRequest.appId)="
        weatherInfoURL += WebserviceRequest.openWeatherMapAppId
        return weatherInfoURL
    }
    
    private func formRequestURLForCityWithName(cityName : String) -> String {
        var weatherInfoURL  = getBaseUrl()
        //Add city name
        weatherInfoURL += "\(WebserviceRequest.cityName)="
        weatherInfoURL += cityName
        //Add App ID
        weatherInfoURL += "&\(WebserviceRequest.appId)="
        weatherInfoURL += WebserviceRequest.openWeatherMapAppId
        return weatherInfoURL
    }
    
    /*
     Fetches the weather information due to background fetch event
     Parameters:
     !) cityID : Int
     */
    func fetchBackgroundWeatherForecast(_ cityId: Int,responseUIHandler :
        @escaping (_ response : Any?, _ error : NSError?) -> Void) {
        // call webservice as its not saved in the coredata
        HttpCommunication.sharedInstance.fetch(requestUrlStr: formRequestURLForCityWithId(cityId: cityId), responseHandler: { (response: Data?, error: NSError?) in
            do {
                if error == nil {
                    let jsonResult : [String:Any] = try JSONSerialization.jsonObject(with: response!, options:.allowFragments) as![String:Any]
                    print("JSON response: \(jsonResult)")
                    responseUIHandler(jsonResult, nil)
                } else {
                    responseUIHandler(nil, error as NSError?)
                }
            } catch {
                print("Error with Json: \(error)")
                responseUIHandler(nil, error as NSError?)
            }
        })
    }
    
    /*
     Gets the weatherForecast for each City
     parameters:
     1) cityID : Int
     2) responseUIHandler : WeatherForecastResponseUIHandler
     */
    func getWeatherForecast(_ cityId: Int, responseUIHandler : @escaping (_ response : Any?, _ error : NSError?, _ shouldUpdateUI: Bool) -> Void) {
        var isCityDataAvailable = false
        let weatherInfoArray = CoreDataManager.sharedInstance.fetchWeatherData()
        var weatherInfo : Weather?
        // if data already available in core data, just return it from the database
        if weatherInfoArray != nil && (weatherInfoArray?.count)! > 0 {
            for info in weatherInfoArray!{
                if info.cityId == Int32(cityId){
                    isCityDataAvailable = true
                    weatherInfo = info
                    break
                }
            }
        }
        if isCityDataAvailable {
            responseUIHandler(weatherInfo,nil, false)
        } else {
            // call webservice as its not saved in the coredata
            
            HttpCommunication.sharedInstance.fetch(requestUrlStr: formRequestURLForCityWithId(cityId: cityId), responseHandler: { (response: Data?, error: NSError?) in
                do {
                    let jsonResult : [String:Any] = try JSONSerialization.jsonObject(with: response!, options:.allowFragments) as![String:Any]
                    print("JSON response: \(jsonResult)")
                    let record = self.saveData(response: jsonResult,error: error)
                    responseUIHandler(record, nil,true)
                } catch {
                    print("Error with Json: \(error)")
                    responseUIHandler(nil, error as NSError?,false)
                }
            })
        }
    }
    
    /*
     Gets the weatherForecast for each City
     parameters:
     1) cityName : String
     2) responseUIHandler : WeatherForecastResponseUIHandler
     */
    func getWeatherForecast(_ cityName: String, responseUIHandler : @escaping (_ response: Any?, _ error: NSError?) -> Void) {
        var weatherInfo: Weather?
        var isCityDataAvailable = false
        let weatherInfoArray = CoreDataManager.sharedInstance.fetchWeatherData()
        // if data already available in core data, just return it from the database
        if weatherInfoArray != nil && (weatherInfoArray?.count)! > 0 {
            for info in weatherInfoArray! {
                if  info.name == cityName {
                    isCityDataAvailable = true
                    weatherInfo = info
                    break
                }
            }
        }
        if isCityDataAvailable {
            let userInfo: [AnyHashable : Any]? =
                [
                    NSLocalizedDescriptionKey :  NSLocalizedString("Error", value: "City already exists", comment: "")
            ]
            let err: NSError = NSError(domain: "", code: -1, userInfo: userInfo)
            responseUIHandler(weatherInfo,err)
        } else {
            // call the webservice
            HttpCommunication.sharedInstance.fetch(requestUrlStr: formRequestURLForCityWithName(cityName: cityName), responseHandler: { (response: Data?, error: NSError?) in
                
                if (error != nil) {
                    // system error : eg not found
                    responseUIHandler(nil, error)
                } else{
                    do {
                        let jsonResult : [String:Any] = try JSONSerialization.jsonObject(with: response!, options:.allowFragments) as![String:Any]
                        print("JSON response: \(jsonResult)")
                        
                        // if the name entered in the search text and the name returned from the webservice response doesn't match then have discarded the record to maintain consistency in the database.
                        // eg: If i search New Delhi and get result as Connaught place -> skip the record
                        // Serach : Haryana : result -> Faridabad -> skip the record
                        
                        var name : String?
                        if((jsonResult[WebserviceResponse.cityName] as? String) != nil) {
                            name = jsonResult[WebserviceResponse.cityName] as? String
                        }
                        
                        if name?.caseInsensitiveCompare(cityName) == ComparisonResult.orderedSame {
                            let record = self.saveData(response: jsonResult,error: error)
                            responseUIHandler(record, error)
                        } else {
                            let userInfo: [AnyHashable : Any]? =
                                [
                                    NSLocalizedDescriptionKey :  NSLocalizedString("Error", value: "City not found. Please add valid City Name.", comment: "")
                            ]
                            let err: NSError = NSError(domain: "", code: -1, userInfo: userInfo)
                            responseUIHandler(nil, err)
                        }
                    } catch {
                        print("Error with Json: \(error)")
                        responseUIHandler(nil, error as NSError?)
                    }
                }
            })
        }
    }
    
    //  MARK: -  CoreDataManager functions
    /*
     Calls the CoreData Manager to save the data
     parameters:
     1) response : Any?
     2) error : NSError?
     */
    private func saveData(response: Any?, error: NSError?) -> NSManagedObject {
        let coreDataManager = CoreDataManager.sharedInstance
        var record : NSManagedObject?
        
        if error != nil {
            NSLog("Error in fetching weather information. Try again Later. Can't save to Core Data")
        } else {
            record = coreDataManager.saveWeatherData(jsonResult : response as! [String : Any]!)
        }
        return record!
    }
    
    /*
     fetches the data from CoreData Manager
     returns:
     1) array of [Weather]
     */
    func fetchRecord() -> [Weather] {
        let coreDataManager = CoreDataManager.sharedInstance
        let weatherInfoArray = coreDataManager.fetchWeatherData()
        return weatherInfoArray!
    }
    
    /*
     updates the particular data from CoreData Manager
     returns:
     1) updated NSManagedObject record
     */
    func updateRecord(weatherInfo : Any?) -> NSManagedObject {
        let record = CoreDataManager.sharedInstance.updateRecord(jsonResult : weatherInfo as! [String : Any]!)
        return record
    }
    
    /*
     Calls the CoreData Manager to delete an object
     parameters:
     1) weatherInfo : Weather
     Returns:
     Bool - success or failure
     */
    func deleteData(weatherInfo : Weather) -> Bool {
        let coreDataManager = CoreDataManager.sharedInstance
        let bIsSuccessfullyDeleted = coreDataManager.deleteWeatherData(weatherInfo:  weatherInfo)
        return bIsSuccessfullyDeleted
    }
}

