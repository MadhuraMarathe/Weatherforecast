//
//  CoreDataManager.swift
//  MMOpenWeatherForecast
//
//  Created by Apple3 on 14/04/17.
//  Copyright © 2017 Madhura. All rights reserved.
//

import UIKit
import CoreData
/*
 This class is responsible to communicate with Core Data APIs for saving
 and fetching the core data entities and attributes.
 */
class CoreDataManager {
    // MARK: - Variables.
    /* Singletone instance of the CoreDataManager */
    static let sharedInstance = CoreDataManager()
    
    // MARK: - Functions.
    private func getContext () -> NSManagedObjectContext {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        return appDelegate.persistentContainer.viewContext
    }
    
    /*
     saves the weather info data to the core data
     parameters:
     1) jsonresult
     */
    func saveWeatherData (jsonResult : [String:Any]!) -> NSManagedObject {
        let context = getContext()
        //retrieve the entity that we just created
        let entity =  NSEntityDescription.entity( forEntityName: CoreData.EntityNames.weatherEntity, in: context)
        var record = Weather(entity: entity!, insertInto: context)
        record = transformToManagedObject(record: record, jsonResult:jsonResult)
        print(record)
        //save the object
        do {
            try context.save()
            print("saved!")
        } catch let error as NSError {
            print("Could not save \(error), \(error.userInfo)")
        }
        return record
    }
    
    /*
     fetch the weather info data from the core data
     Returns:
     1) [Weather] Array which is of type NSManagedObject
     */
    func fetchWeatherData () -> [Weather]? {
        //create a fetch request, telling it about the entity
        let fetchRequest: NSFetchRequest<Weather> = Weather.fetchRequest()
        var weatherInfoArray : [Weather]?
        do {
            //get the results
            weatherInfoArray = try getContext().fetch(fetchRequest)
            print ("num of results = \(weatherInfoArray?.count)")
        } catch {
            print("Error with request: \(error)")
        }
        return weatherInfoArray
    }
    
    /*
     fetch the weather info data from the core data and update with new information
     Parameters:
     1) jsonResult : [String:Any]
     */
    func updateRecord (jsonResult : [String:Any]!) -> NSManagedObject {
        let context = getContext()
        var cityId = -1
        if ((jsonResult[WebserviceResponse.cityId] as? Int) != nil) {
            cityId = jsonResult[WebserviceResponse.cityId] as! Int;
        }
        //retrieve the entity that we just created
        let fetchRequest: NSFetchRequest<Weather> = Weather.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "cityId = %ld",cityId)
        var record : Weather?
        do {
            let list = try context.fetch(fetchRequest)
            if list.count > 0 {
                record = transformToManagedObject(record: list[0], jsonResult:jsonResult)
                print("Updated Record :", record)
                try context.save()
                print("updated successfully!")
            }
        }
        catch let error as NSError {
            // failure
            print("Fetch failed: \(error.localizedDescription)")
            print("Could not update \(error), \(error.userInfo)")
        }
        return record!
    }
    
    /*
     deletes the weather info data from the core data
     parameters:
     1) Weather
     */
    func deleteWeatherData (weatherInfo : Weather) -> Bool {
        let context = getContext()
        var isSuccessfullyDeleted = false
        //retrieve the entity that we just created
        let fetchRequest: NSFetchRequest<Weather> = Weather.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "cityId = %ld",weatherInfo.cityId)
        do {
            let list = try context.fetch(fetchRequest)
            if list.count > 0 {
                let record : Weather = list[0]
                context.delete(record)
                print("Deleted Record :", record)
                try context.save()
                isSuccessfullyDeleted = true
            }
        }
        catch let error as NSError {
            // failure
            print("Fetch failed: \(error.localizedDescription)")
            isSuccessfullyDeleted = false
            print("Could not delete \(error), \(error.userInfo)")
        }
        return isSuccessfullyDeleted
    }
    
    func transformToManagedObject(record : Weather, jsonResult : [String:Any]!) -> Weather {
        // parse weather main info
        if ((jsonResult[WebserviceResponse.main] as? NSDictionary) != nil) {
            let weatherMain = jsonResult[WebserviceResponse.main] as! NSDictionary;
            //Parse Humidity
            if ((weatherMain[WebserviceResponse.main] as? Double) != nil) {
                let humidity = weatherMain[WebserviceResponse.main] as! Double;
                record.humidity = humidity
            }
            //Parse pressure
            if ((weatherMain[WebserviceResponse.pressure] as? Double) != nil) {
                let pressure = weatherMain[WebserviceResponse.pressure] as! Double;
                record.pressure = pressure
            }
            //Parse temperature
            if ((weatherMain[WebserviceResponse.temp] as? Double) != nil) {
                let temperature = weatherMain[WebserviceResponse.temp] as! Double;
                record.temperature = temperature
            }
            //Parse max temperature
            if ((weatherMain[WebserviceResponse.tempMax] as? Double) != nil) {
                let maxTemperature = weatherMain[WebserviceResponse.tempMax] as! Double;
                record.temperatureMax = maxTemperature
            }
            //Parse min temperature
            if ((weatherMain[WebserviceResponse.tempMin] as? Double) != nil) {
                let minTemperature = weatherMain[WebserviceResponse.tempMin] as! Double;
                record.temperatureMin = minTemperature
            }
        }
        // parce city name
        if ((jsonResult[WebserviceResponse.cityName] as? String) != nil) {
            let name = jsonResult[WebserviceResponse.cityName] as! String;
            record.name = name
        }
        // parce city id
        if ((jsonResult[WebserviceResponse.cityId] as? Int) != nil) {
            let cityId = jsonResult[WebserviceResponse.cityId] as! Int;
            record.cityId = Int32(cityId)
        }
        // parse weather
        if ((jsonResult[WebserviceResponse.weather] as? [[String:Any]]) != nil) {
            let weatherDescription = jsonResult[WebserviceResponse.weather] as! [[String:Any]]
            // parse weather description
            if ((weatherDescription[0][WebserviceResponse.conditiondescription] as? String) != nil) {
                let weatherDescription = weatherDescription[0][WebserviceResponse.conditiondescription] as! String;
                record.weatherDescription = weatherDescription;
            }
        }
        // parse cloud condition
        if ((jsonResult[WebserviceResponse.cloudiness] as? NSDictionary) != nil) {
            let cloudCondition = jsonResult[WebserviceResponse.cloudiness] as! NSDictionary;
            // parse all
            if ((cloudCondition[WebserviceResponse.all] as? Int) != nil) {
                let all = cloudCondition[WebserviceResponse.all] as! Int;
                record.cloudiness = Int16(all);
            }
        }
        // parce date
        if ((jsonResult[WebserviceResponse.weatherDate] as? TimeInterval) != nil) {
            let timeStamp = jsonResult[WebserviceResponse.weatherDate] as! TimeInterval;
            let date = Date(timeIntervalSince1970: timeStamp);
            record.date = date as NSDate?;
        }
        if ((jsonResult[WebserviceResponse.wind] as? NSDictionary) != nil) {
            let windInfo = jsonResult[WebserviceResponse.wind] as! NSDictionary;
            //Parse degrees - windDirectionInDegrees
            if ((windInfo[WebserviceResponse.windDirectionInDegrees] as? Double) != nil) {
                let windDirectionInDegrees = windInfo[WebserviceResponse.windDirectionInDegrees] as! Double;
                record.winddirection = windDirectionInDegrees;
            }
            //Parse degrees - windDirectionInDegrees
            if ((windInfo[WebserviceResponse.windSpeed] as? Double) != nil) {
                let windSpeed = windInfo[WebserviceResponse.windSpeed] as! Double;
                record.winddirection = windSpeed;
            }
        }
        return record
    }
}
