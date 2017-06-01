//
//  GetWeatherForecastWebService.swift
//  MMOpenWeatherForecast
//
//  Created by Madhura Marathe on 1/20/17.
//  Copyright © 2017 Madhura. All rights reserved.
//

import Foundation

class GetWeatherForecastWebService: CommunicationServiceProtocol {

    // base URL
    let requestUrl = "http://api.openweathermap.org/data/2.5/weather?"
    
    var cityId: Int = -1;
    var cityName : String?
    let responseHandler: (_ response: Any?, _ error: NSError?)->Void
    
    init(cityId: Int, responseHandler: @escaping (_ response: Any?, _ error: NSError?)->Void)
    {
        self.cityId = cityId
        self.responseHandler = responseHandler
    }
    
    init(cityName: String, responseHandler: @escaping (_ response: Any?, _ error: NSError?)->Void)
    {
        // trim white spaces if any in the city name, as web-service doesn't allow white spaces
        self.cityName = cityName.replacingOccurrences(of: " ", with: "",options:NSString.CompareOptions.literal, range:nil )
        self.responseHandler = responseHandler
    }
    
    // returns the requestUrl
    func getRequestURLForCityWithId() -> String
    {
        var weatherInfoURL : String = requestUrl;
        //Add city id
        weatherInfoURL += "\(WebserviceRequestConstants.REQUEST_KEY_CITY_ID)="
        weatherInfoURL += String(cityId);
        //Add App ID
        weatherInfoURL += "&\(WebserviceRequestConstants.REQUEST_KEY_APP_ID)=";
        weatherInfoURL += WebserviceRequestConstants.OPEN_WEATHER_MAP_APP_ID;
        
        return weatherInfoURL
    }
    
    func getRequestURLForCityWithName() -> String
    {
        var weatherInfoURL : String = requestUrl;
        //Add city name
        weatherInfoURL += "\(WebserviceRequestConstants.REQUEST_KEY_CITY_NAME)="
        weatherInfoURL += cityName!
//        //Add App ID
        weatherInfoURL += "&\(WebserviceRequestConstants.REQUEST_KEY_APP_ID)=";
        weatherInfoURL += WebserviceRequestConstants.OPEN_WEATHER_MAP_APP_ID;
        
        return weatherInfoURL
    }
    
    // MARK: CommunicationServiceProtocol methods
    
    // handles the response
    func handleResponse(_ data:Data)
    {
        do{
            let jsonResult : [String:Any] = try JSONSerialization.jsonObject(with: data, options:.allowFragments) as![String:Any]
            print("JSON response: \(jsonResult)");
            
            let weatherInfo : WeatherForecast =  self.parseResponse(jsonResult: jsonResult)
            responseHandler(weatherInfo, nil)
            
        }catch {
            print("Error with Json: \(error)")
            responseHandler(nil, error as NSError?)
        }
    }
    
    
    // handles the failure
    func handleFailure(_ error:NSError)
    {
        responseHandler(nil, error)
    }
    
    // returns the request body
    func getRequestBody() -> AnyObject?
    {
        return nil
    }
    
    // returns the Http headers
    func getHttpHeaders() -> NSDictionary?
    {
        return nil
    }
    
    // returns the Http Method
    func getHttpMethod() -> HTTP_METHOD
    {
        return HTTP_METHOD.GET
    }
    
    /*
     Parses the json response y
     parameters:
     1) jsonResult : [String:Any]
     Returns: WeatherForecast object
     */
    
    private func parseResponse(jsonResult : [String:Any]!) -> WeatherForecast
    {
        let weatherForecast : WeatherForecast = WeatherForecast()
        // parse weather main info
        if((jsonResult[WebserviceResponseConstants.RESPONSE_KEY_MAIN] as? NSDictionary) != nil)
        {
            let weatherMain = jsonResult[WebserviceResponseConstants.RESPONSE_KEY_MAIN] as! NSDictionary;
            
            //Parse Humidity
            if((weatherMain[WebserviceResponseConstants.RESPONSE_KEY_HUMIDITY] as? Double) != nil)
            {
                let humidity = weatherMain[WebserviceResponseConstants.RESPONSE_KEY_HUMIDITY] as! Double;
                weatherForecast.humidity = humidity;
            }
            
            //Parse pressure
            if((weatherMain[WebserviceResponseConstants.RESPONSE_KEY_PRESSURE] as? Double) != nil)
            {
                let pressure = weatherMain[WebserviceResponseConstants.RESPONSE_KEY_PRESSURE] as! Double;
                weatherForecast.pressure = pressure;
            }
            
            //Parse temperature
            if((weatherMain[WebserviceResponseConstants.RESPONSE_KEY_TEMP] as? Double) != nil)
            {
                let temperature = weatherMain[WebserviceResponseConstants.RESPONSE_KEY_TEMP] as! Double;
                weatherForecast.temperature = temperature;
            }
            
            //Parse max temperature
            if((weatherMain[WebserviceResponseConstants.RESPONSE_KEY_MAX_DAILY_TEMP] as? Double) != nil)
            {
                let maxTemperature = weatherMain[WebserviceResponseConstants.RESPONSE_KEY_MAX_DAILY_TEMP] as! Double;
                weatherForecast.temperatureMax = maxTemperature;
            }
            
            //Parse min temperature
            if((weatherMain[WebserviceResponseConstants.RESPONSE_KEY_MIN_DAILY_TEMP] as? Double) != nil)
            {
                let minTemperature = weatherMain[WebserviceResponseConstants.RESPONSE_KEY_MIN_DAILY_TEMP] as! Double;
                weatherForecast.temperatureMin = minTemperature;
            }
        }
        
        // parce city name
        if((jsonResult[WebserviceResponseConstants.RESPONSE_KEY_CITY_NAME] as? String) != nil)
        {
            let name = jsonResult[WebserviceResponseConstants.RESPONSE_KEY_CITY_NAME] as! String;
            weatherForecast.name = name;
        }
        
        // parce city id
        if((jsonResult[WebserviceResponseConstants.RESPONSE_KEY_CITY_ID] as? Int) != nil)
        {
            let cityId = jsonResult[WebserviceResponseConstants.RESPONSE_KEY_CITY_ID] as! Int;
            weatherForecast.cityId = cityId;
        }
        
        // parse co-ordinates
        if((jsonResult[WebserviceResponseConstants.RESPONSE_KEY_CITY_GEO_COORDINATES] as? NSDictionary) != nil)
        {
            let weatherCoords = jsonResult[WebserviceResponseConstants.RESPONSE_KEY_CITY_GEO_COORDINATES] as! NSDictionary;
            
            //Parse latitude
            if((weatherCoords[WebserviceResponseConstants.RESPONSE_KEY_LATITUDE] as? Double) != nil)
            {
                let latitude = weatherCoords[WebserviceResponseConstants.RESPONSE_KEY_LATITUDE] as! Double;
                weatherForecast.latitude = latitude;
            }
            
            //Parse longitude
            if((weatherCoords[WebserviceResponseConstants.RESPONSE_KEY_LONGITUDE] as? Double) != nil)
            {
                let longitude = weatherCoords[WebserviceResponseConstants.RESPONSE_KEY_LONGITUDE] as! Double;
                weatherForecast.longitude = longitude;
            }
        }
        
        // parse weather
        if((jsonResult[WebserviceResponseConstants.RESPONSE_KEY_WEATHER] as? [[String:Any]]) != nil)
        {
            let weatherDescription = jsonResult[WebserviceResponseConstants.RESPONSE_KEY_WEATHER] as! [[String:Any]]
            
            // parse weather description
            if((weatherDescription[0][WebserviceResponseConstants.RESPONSE_KEY_CONDITION_DESCRIPTION] as? String) != nil)
            {
                let weatherDescription = weatherDescription[0][WebserviceResponseConstants.RESPONSE_KEY_CONDITION_DESCRIPTION] as! String;
                weatherForecast.weatherDescription = weatherDescription;
            }
            
            // parse weather description main
            if((weatherDescription[0][WebserviceResponseConstants.RESPONSE_KEY_GROUP_PARAMETERS] as? String) != nil)
            {
                let weatherDescriptionMain = weatherDescription[0][WebserviceResponseConstants.RESPONSE_KEY_GROUP_PARAMETERS] as! String;
                weatherForecast.weatherDescriptionMain = weatherDescriptionMain;
            }
        }
        
        // parse cloud condition
        if((jsonResult[WebserviceResponseConstants.RESPONSE_KEY_CLOUDINESS] as? NSDictionary) != nil)
        {
            let cloudCondition = jsonResult[WebserviceResponseConstants.RESPONSE_KEY_CLOUDINESS] as! NSDictionary;
            
            // parse all
            if((cloudCondition[WebserviceResponseConstants.RESPONSE_KEY_ALL] as? Int) != nil)
            {
                let all = cloudCondition[WebserviceResponseConstants.RESPONSE_KEY_ALL] as! Int;
                weatherForecast.all = all;
            }
        }
        
        // parce date
        if((jsonResult[WebserviceResponseConstants.RESPONSE_KEY_WEATHER_DATE] as? TimeInterval) != nil)
        {
            let timeStamp = jsonResult[WebserviceResponseConstants.RESPONSE_KEY_WEATHER_DATE] as! TimeInterval;
            let date = Date(timeIntervalSince1970: timeStamp);
            weatherForecast.date = date;
        }
        
        // parce base
        if((jsonResult[WebserviceResponseConstants.RESPONSE_KEY_WEATHER_BASE] as? String) != nil)
        {
            let base = jsonResult[WebserviceResponseConstants.RESPONSE_KEY_WEATHER_BASE] as! String;
            weatherForecast.base = base;
        }
        
        // parse sys
        if((jsonResult[WebserviceResponseConstants.RESPONSE_KEY_WEATHER_SYS] as? NSDictionary) != nil)
        {
            let weatherSys = jsonResult[WebserviceResponseConstants.RESPONSE_KEY_WEATHER_SYS] as! NSDictionary;
            
            // parce country Name
            if((weatherSys[WebserviceResponseConstants.RESPONSE_KEY_COUNTRY] as? String) != nil)
            {
                let countryName = weatherSys[WebserviceResponseConstants.RESPONSE_KEY_COUNTRY] as! String;
                weatherForecast.countryName = countryName;
            }
            
            // parce country Id
            if((weatherSys[WebserviceResponseConstants.RESPONSE_KEY_COUNTRY_ID] as? Int) != nil)
            {
                let countryId = weatherSys[WebserviceResponseConstants.RESPONSE_KEY_COUNTRY_ID] as! Int;
                weatherForecast.countryId = countryId;
            }
            
            // parce message
            if((weatherSys[WebserviceResponseConstants.RESPONSE_KEY_MESSAGE] as? String) != nil)
            {
                let message = weatherSys[WebserviceResponseConstants.RESPONSE_KEY_MESSAGE] as! String;
                weatherForecast.message = message;
            }
            
            // parce sunrise
            if((weatherSys[WebserviceResponseConstants.RESPONSE_KEY_SUNRISE] as? TimeInterval) != nil)
            {
                let timeStamp = weatherSys[WebserviceResponseConstants.RESPONSE_KEY_SUNRISE] as! TimeInterval;
                let sunrise = Date(timeIntervalSince1970: timeStamp);
                weatherForecast.sunriseTime = sunrise;
            }
            
            // parce sunset
            if((weatherSys[WebserviceResponseConstants.RESPONSE_KEY_SUNSET] as? TimeInterval) != nil)
            {
                let timeStamp = weatherSys[WebserviceResponseConstants.RESPONSE_KEY_SUNSET] as! TimeInterval;
                let sunset = Date(timeIntervalSince1970: timeStamp);
                weatherForecast.sunsetTime = sunset;
            }
            
            // parce type
            if((weatherSys[WebserviceResponseConstants.RESPONSE_KEY_TYPE] as? Int) != nil)
            {
                let type = weatherSys[WebserviceResponseConstants.RESPONSE_KEY_TYPE] as! Int;
                weatherForecast.type = type;
            }
        }
        
        // parce code
        if((jsonResult[WebserviceResponseConstants.RESPONSE_KEY_INTERNAL_CODE] as? Int) != nil)
        {
            let cod = jsonResult[WebserviceResponseConstants.RESPONSE_KEY_INTERNAL_CODE] as! Int;
            weatherForecast.code = cod;
        }
        
        // parce visibility
        if((jsonResult[WebserviceResponseConstants.RESPONSE_KEY_INTERNAL_VISIBILITY] as? Int) != nil)
        {
            let visibility = jsonResult[WebserviceResponseConstants.RESPONSE_KEY_INTERNAL_VISIBILITY] as! Int;
            weatherForecast.visibility = visibility;
        }
        
        if((jsonResult[WebserviceResponseConstants.RESPONSE_KEY_WIND] as? NSDictionary) != nil)
        {
            let windInfo = jsonResult[WebserviceResponseConstants.RESPONSE_KEY_WIND] as! NSDictionary;
            
            //Parse degrees - windDirectionInDegrees
            if((windInfo[WebserviceResponseConstants.RESPONSE_KEY_WIND_DIRECTION_IN_DEGREES] as? Double) != nil)
            {
                let windDirectionInDegrees = windInfo[WebserviceResponseConstants.RESPONSE_KEY_WIND_DIRECTION_IN_DEGREES] as! Double;
                weatherForecast.windDirectionInDegrees = windDirectionInDegrees;
            }
            
            //Parse degrees - windDirectionInDegrees
            if((windInfo[WebserviceResponseConstants.RESPONSE_KEY_WIND_SPEED] as? Double) != nil)
            {
                let windSpeed = windInfo[WebserviceResponseConstants.RESPONSE_KEY_WIND_SPEED] as! Double;
                weatherForecast.windSpeed = windSpeed;
            }
        }
        
        return weatherForecast
    }
}
