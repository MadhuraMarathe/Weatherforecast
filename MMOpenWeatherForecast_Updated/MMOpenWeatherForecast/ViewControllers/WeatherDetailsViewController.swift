//
//  WeatherDetailsViewController.swift
//  MMOpenWeatherForecast
//
//  Created by Madhura Marathe on 1/22/17.
//  Copyright © 2017 Madhura. All rights reserved.
//

import UIKit

class WeatherDetailsViewController: UIViewController {
    // MARK: - Variables.
    var weatherInfo : Weather?
    
    //  MARK: - Enum Background images.
    enum BackgroundImage {
        static let CLEAR_BACKGROUND_IMAGE = "ClearBackground"
        static let CLOUDY_BACKGROUND_IMAGE = "CloudsBackground"
        static let RAINY_BACKGROUND_IMAGE = "RainBackground"
        static let THUNDERSTORM_BACKGROUND_IMAGE = "ThunderstormBackground"
    }
    
    @IBOutlet weak var imageBackground: UIImageView!
    @IBOutlet weak var labelDate: UILabel!
    @IBOutlet weak var labelTemperature: UILabel!
    @IBOutlet weak var labelCityName: UILabel!
    @IBOutlet weak var labelCurrentWeather: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        commonUIInit()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - Functions
    func commonUIInit() {
        self.navigationController?.topViewController?.title = "Weather Details"
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title:" ", style:.plain, target:nil, action:nil)
        let dateFormatter = DateFormatter()
        //dateFormatter.dateFormat = "yyyy-MM-dd"
        dateFormatter.dateStyle = .full
        dateFormatter.timeStyle = .short
        
        if let weatherInfo = weatherInfo {
            // Checked the different timezones to match the times
            if weatherInfo.name == "Melbourne" || weatherInfo.name == "Sydney" {
                dateFormatter.timeZone = TimeZone(identifier: "GMT+11")
            } else if weatherInfo.name == "Brisbane" {
                    dateFormatter.timeZone = TimeZone(identifier: "GMT+10")
            }
            let dateString = dateFormatter.string(from: (weatherInfo.date as! Date))
            labelDate.text = dateString
            labelTemperature.text = String(format: "%.0f °C", (weatherInfo.temperature) - 273.15)
            labelCityName.text = weatherInfo.name
            imageBackground.backgroundColor = UIColor.clear
            imageBackground.alpha = 0.6
            // set images according to the weather conditions
            labelCurrentWeather.text = weatherInfo.weatherDescription
            if let weatherDescription = weatherInfo.weatherDescription {
                switch weatherDescription {
                case WeatherDescription.fewClouds.rawValue, WeatherDescription.brokenClouds.rawValue,WeatherDescription.scatteredClouds.rawValue:
                    imageBackground.image = UIImage(named: BackgroundImage.CLOUDY_BACKGROUND_IMAGE)
                case WeatherDescription.clear.rawValue:
                    imageBackground.image = UIImage(named: BackgroundImage.CLEAR_BACKGROUND_IMAGE)
                case WeatherDescription.lightRains.rawValue,
                     WeatherDescription.showerRain.rawValue,
                     WeatherDescription.lightIntensityShowerRains.rawValue:
                    imageBackground.image = UIImage(named: BackgroundImage.RAINY_BACKGROUND_IMAGE)
                case WeatherDescription.thunderStorm.rawValue:
                    imageBackground.image = UIImage(named: BackgroundImage.THUNDERSTORM_BACKGROUND_IMAGE)
                default:
                    imageBackground.image = UIImage(named: "")
                    imageBackground.backgroundColor = UIColor.init(red: 71/255, green: 135/255, blue: 255/255, alpha: 0.7)
                }
            }
        }
    }
    
    //  MARK: -  prepareforsegue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == UIConstants.detailsToMore {
            let moreDetailsVC = segue.destination as! MoreDetailsViewController
            moreDetailsVC.weatherInfo = weatherInfo
        }
    }
}
