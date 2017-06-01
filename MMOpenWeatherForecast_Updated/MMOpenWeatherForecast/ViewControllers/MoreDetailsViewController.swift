//
//  MoreDetailsViewController.swift
//  MMOpenWeatherForecast
//
//  Created by Madhura Marathe on 1/22/17.
//  Copyright © 2017 Madhura. All rights reserved.
//

import UIKit

class MoreDetailsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    // MARK: - IBOutlets.
    @IBOutlet weak var tableViewMoreDetails: UITableView!
    
    // MARK: - Variables.
    var weatherInfo : Weather?
    var weatherParameters: [String] = [UIConstants.weatherConditionDescription,UIConstants.cloudiness,UIConstants.windSpeed,UIConstants.windDirectionInDegrees,UIConstants.humidity,UIConstants.pressure,UIConstants.temp, UIConstants.minDailyTemp, UIConstants.maxDailyTemp]
    
    // MARK: - UIViewController.
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableViewMoreDetails.tableFooterView = UIView(frame: .zero)
        if let weatherInfo = weatherInfo , let name = weatherInfo.name {
            self.navigationController?.topViewController?.title = "\(name) : More Details"
        } else {
            self.navigationController?.topViewController?.title = "More Details"
        }
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title:" ", style:.plain, target:nil, action:nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Functions
    func getValueForWeatherParameter(_ weatherParameter: String) -> String {
        var weatherParameterValue: String = "" 
        if let weatherInfo = weatherInfo {
            if weatherParameter == UIConstants.weatherConditionDescription {
                weatherParameterValue = (weatherInfo.weatherDescription)!
            } else if weatherParameter == UIConstants.cloudiness {
                weatherParameterValue = String(format:"%d",(weatherInfo.cloudiness)) 
                weatherParameterValue += "%" 
            } else if weatherParameter == UIConstants.windSpeed {
                weatherParameterValue = String(format:"%.2f",(weatherInfo.windspeed)) 
                weatherParameterValue += " m/sec" 
            } else if weatherParameter == UIConstants.windDirectionInDegrees {
                weatherParameterValue = String(format:"%.2f",(weatherInfo.winddirection)) 
                weatherParameterValue += " degrees" 
            } else if weatherParameter == UIConstants.humidity {
                weatherParameterValue = String(format:"%.1f",(weatherInfo.humidity)) 
                weatherParameterValue += "%" 
            } else if weatherParameter == UIConstants.pressure {
                weatherParameterValue = String(format:"%.1f",(weatherInfo.pressure)) 
                weatherParameterValue += " hPa" 
            } else if weatherParameter == UIConstants.temp {
                //For Celsius
                weatherParameterValue = String(format: "%.0f °C", (weatherInfo.temperature) - 273.15)
            } else if weatherParameter == UIConstants.maxDailyTemp {
                //For Celsius
                weatherParameterValue = String(format: "%.0f °C", (weatherInfo.temperatureMax) - 273.15)
            } else if weatherParameter == UIConstants.minDailyTemp {
                //For Celsius
                weatherParameterValue = String(format: "%.0f °C", (weatherInfo.temperatureMin) - 273.15)
            }
        }
        return weatherParameterValue 
    }
    
    
    //  MARK: -  UITablevieDatasource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return weatherParameters.count 
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let weatherParameter = weatherParameters[(indexPath as NSIndexPath).row]
        let cell = tableViewMoreDetails.dequeueReusableCell(withIdentifier: UIConstants.tableviewWeatherParameterCell)
        cell!.textLabel?.text = weatherParameter
        let weatherParameterValue = self.getValueForWeatherParameter(weatherParameter)
        cell!.detailTextLabel?.text = weatherParameterValue
        cell!.selectionStyle = UITableViewCellSelectionStyle.none
        cell!.accessoryType = UITableViewCellAccessoryType.none
        return cell!
    }
    
    //  MARK: -  UITableView delegate
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }
    
}
