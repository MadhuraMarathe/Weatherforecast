//
//  Constants.swift
//  OpenWeatherForecast
//
//  Created by Madhura Marathe on 1/20/17.
//  Copyright © 2017 Madhura. All rights reserved.
//

import Foundation

struct WebserviceRequest {
    //OpenWeatherMap app id
    static let openWeatherMapAppId = "b54cd5a62d43149189d28166efc275f9"
    //Weather map API request keys
    static let cityName = "q"
    static let cityId = "id"
    static let appId = "APPID"
}

struct WebserviceResponse {
    //OpenWeatherMap API response keys
    static let main = "main"
    static let humidity = "humidity"
    static let pressure = "pressure"
    static let temp = "temp"
    static let tempMin = "temp_min"
    static let tempMax = "temp_max"
    static let cityName = "name"
    static let cityId = "id"
    static let cityGeocoordinates = "coord"
    static let latitude = "lat"
    static let longitude = "lon"
    static let weather = "weather" 
    static let conditionId = "id"
    static let iconid = "icon"
    static let groupParameters = "main"
    static let conditiondescription = "description"
    static let cloudiness = "clouds" 
    static let all = "all"
    static let weatherDate = "dt"
    static let weatherBase = "base"
    static let weathersys = "sys"
    static let city = "city" 
    static let country = "country" 
    static let countryid = "id"
    static let message = "message" 
    static let sunrise = "sunrise" 
    static let sunset = "sunset" 
    static let type = "type"
    static let internal_code = "cod" 
    static let internal_visibility = "visibility"
    static let wind = "wind" 
    static let windSpeed = "speed"
    static let windDirectionInDegrees = "deg"
    static let count = "cnt"
}

struct UIConstants {
    // UI Constants
    static let tableviewlistcell = "ListDetailsCell"
    static let weatherdetailsvc = "WeatherDetailsViewController"
    static let moreWeatherDetailsvc = "MoreDetailsViewController"
    static let tableviewWeatherParameterCell = "WeatherParameterCell"

    //Weather details tableview keys
    static let weatherConditionDescription = "Condition"
    static let cloudiness = "Cloudiness"
    static let windSpeed = "Wind Speed"
    static let windDirectionInDegrees = "Wind direction"
    static let humidity = "Humidity"
    static let pressure = "Pressure"
    static let temp = "Temperature"
    static let minDailyTemp = "Min"
    static let maxDailyTemp = "Max"

    // segue identifiers
    static let listToDetails = "details"
    static let detailsToMore = "moredetails"
    static let initialCityCount = 3
}

// new constants for assignment changes
struct CoreData {
    struct EntityNames {
        static let weatherEntity = "Weather"
    }
    
    struct AttributeNames {
        static let cityName = "name"
        static let weatherDescription = "weatherDescription"
        static let cloudiness = "cloudiness"
        static let windspeed = "windspeed"
        static let winddirection = "winddirection"
        static let humidity = "humidity"
        static let pressure = "pressure"
        static let temperature = "temperature"
        static let temperatureMin = "temperatureMin"
        static let temperatureMax = "temperatureMax"
    }
}

// probable weather descriptions  received from the server
enum WeatherDescription : String {
    case fewClouds = "few clouds"
    case brokenClouds = "broken clouds"
    case scatteredClouds = "scattered clouds"
    case clear = "clear sky"
    case lightRains = "light rain"
    case thunderStorm = "thunderstorm"
    case showerRain = "shower rain"
    case lightIntensityShowerRains = "light intensity shower rain"
}
