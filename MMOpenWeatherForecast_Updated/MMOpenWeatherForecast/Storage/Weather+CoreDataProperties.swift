//
//  Weather+CoreDataProperties.swift
//  MMOpenWeatherForecast
//
//  Created by Apple3 on 04/05/17.
//  Copyright © 2017 Madhura. All rights reserved.
//

import Foundation
import CoreData

extension Weather {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Weather> {
        return NSFetchRequest<Weather>(entityName: "Weather");
    }
    // MARK: - Variables.
    @NSManaged public var cityId: Int32
    @NSManaged public var cloudiness: Int16
    @NSManaged public var humidity: Double
    @NSManaged public var name: String?
    @NSManaged public var pressure: Double
    @NSManaged public var temperature: Double
    @NSManaged public var temperatureMax: Double
    @NSManaged public var temperatureMin: Double
    @NSManaged public var weatherDescription: String?
    @NSManaged public var winddirection: Double
    @NSManaged public var windspeed: Double
    @NSManaged public var date: NSDate?
}
