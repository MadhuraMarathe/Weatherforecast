//
//  CityTemperatureListTableViewController.swift
//  MMOpenWeatherForecast
//
//  Created by Madhura Marathe on 1/20/17.
//  Copyright © 2017 Madhura. All rights reserved.
//

import UIKit

class CityTemperatureListTableViewController: UITableViewController, UISearchBarDelegate
{
    // MARK: - IBOutlets.
    @IBOutlet var tableViewTemperatureList: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    // MARK: - Variables.
    var cityTemperatureDetails : [Weather] = []
    var cityNames : [String] = ["Melbourne","Brisbane","Sydney"]
    var cityIDs: [Int] = [4163971,2174003,2147714]
    var activityIndicator: UIActivityIndicatorView!
    var searchBarCityName : String?
    var allCoreData : [Weather] = []
    
    //  MARK: -  View life cycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        commonUIInit()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title:" ", style:.plain, target:nil, action:nil)
    }
    
    private func commonUIInit() {
        activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)
        tableView.backgroundView = activityIndicator
        searchBar.delegate = self
        self.tableViewTemperatureList.tableFooterView = UIView(frame: .zero)
        
        // fetch from core data. if array is nil setup the ui with 3 static cities. else show the records fetched from the core data
        cityTemperatureDetails = WeatherForecastManager.sharedInstance.fetchRecord()
        if (cityTemperatureDetails.isEmpty) {
            loadWeatherDataFromWeb()
        }
        else{
            // show activity indicator
            view.alpha = 0.5
            activityIndicator.startAnimating()
            reloadCityList()
        }
    }
    
    //  MARK: -  Backgroundfetch methods
    func fetchFromBackground() {
        if !allCoreData.isEmpty {
            allCoreData.removeAll()
        }
        allCoreData = WeatherForecastManager.sharedInstance.fetchRecord()
        if (allCoreData.isEmpty) {
            NSLog("No Data. Hence no background fetch")
        }
        else {
            for info in allCoreData {
                WeatherForecastManager.sharedInstance.fetchBackgroundWeatherForecast(Int(info.cityId))
                { (response, error) in
                    if error != nil {
                        NSLog("Background fetch failed for a record")
                    }
                    else {
                        // update the data source
                        self.checkChangeInWeatherInfo(jsonResult: response as! [String:Any])
                    }
                }
            }
        }
    }
    
    private func checkChangeInWeatherInfo(jsonResult: [String:Any]) {
        var isDataChanged = false
        let record : Weather = WeatherForecastManager.sharedInstance.updateRecord(weatherInfo: jsonResult) as! Weather
        //for info in allCoreDataArray
        for i in 0..<allCoreData.count {
            let info = allCoreData[i]
            if info.cityId == record.cityId {
                // weather description has changed
                if info.weatherDescription != record.weatherDescription {
                    // update tableview's data source
                    if !(cityTemperatureDetails.isEmpty) {
                        cityTemperatureDetails[i] = record
                        isDataChanged = true
                    }
                    let delegate = UIApplication.shared.delegate as? AppDelegate
                    if (delegate?.isGrantedNotificationAccess)! {
                        delegate?.scheduleNotification(oldData: info, newData: record)}
                }
                break
            }
        }
        
        if isDataChanged { //if data is changed reload city list
            reloadCityList()
        }
    }
    
    //  MARK: -  private functions
    /*
     shows error alert
     */
    private func showErrorAlert(error : NSError) {
        var errorDescription: String? = error.localizedDescription
        if errorDescription == nil {
            errorDescription = "Error in fetching weather information. Try again Later."
        }
        let alert = UIAlertController(title: "Error",
                                      message: errorDescription,
                                      preferredStyle: UIAlertControllerStyle.alert)
        
        let dismiss = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alert.addAction(dismiss)
        self.present(alert, animated: true, completion: nil)
        // remove activity indicator
        self.view.alpha = 1
        activityIndicator.stopAnimating()
        self.searchBar.text = ""
    }
    
    /* reload list with updated data */
    private func reloadCityList() {
        DispatchQueue.main.async {
            // remove activity indicator
            self.view.alpha = 1
            self.activityIndicator.stopAnimating()
            self.searchBar.text = ""
            self.tableViewTemperatureList.reloadData()
        }
    }
    
    /* check for data availability and ask for reloading the data
     */
    private func showResponse(weatherInfo : Weather) {
        if !cityTemperatureDetails.isEmpty && cityTemperatureDetails.count == UIConstants.initialCityCount {
            self.reloadCityList()
        }
    }
    
    private func loadWeatherDataFromWeb() {
        // show activity indicator
        self.view.alpha = 0.5
        activityIndicator.startAnimating()
        
        // Call the getWeatherForecast webservice for each city
        for i in 0 ..< cityNames.count {
            // call GetWeatherForecastService
            // Receives the response, updaes the datasource and reloads the tableview
            WeatherForecastManager.sharedInstance.getWeatherForecast(cityIDs[i])
            { (response, error, shouldUpdateList) in   /// responseuihandler trailing closure
                
                // if bShouldUpdate is false, there is no need to update the tableview's data source
                // directly reload the tableview
                if !shouldUpdateList  {
                    self.reloadCityList()
                } else {
                    if error != nil{
                        // show error
                        DispatchQueue.main.async{
                            self.showErrorAlert(error: error!)
                        }
                    } else {
                        // update the data source
                        
                        let weatherInfo: Weather = response as! Weather
                        self.cityTemperatureDetails.append(weatherInfo)
                        self.showResponse(weatherInfo: weatherInfo)
                    }
                }
            }
        }
    }
    
    //  MARK: -  UITableViewDataSourece
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cityTemperatureDetails.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let listDetailsCell = tableView.dequeueReusableCell(withIdentifier: UIConstants.tableviewlistcell, for: indexPath) as! ListDetailsTableViewCell
        let weather = cityTemperatureDetails[(indexPath as NSIndexPath).row]
        listDetailsCell.labelCityName.text = weather.name
        if weather.temperature > 0 {
            listDetailsCell.labelTemperature.isHidden = false
            listDetailsCell.labelTemperature.text = String(format: "%.0f °C", weather.temperature - 273.15)
            // to show in Kelvin
            //            String(cityTemperature.cityTemperature) + "K"
        } else {
            listDetailsCell.labelTemperature.isHidden = true
        }
        listDetailsCell.accessoryType = UITableViewCellAccessoryType.disclosureIndicator
        return listDetailsCell
    }
    
    //  MARK: -  UITableViewDelegate
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44.0
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)  {
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath)  {
        if editingStyle == .delete {
            let bIsSuccessfullyDeleted = WeatherForecastManager.sharedInstance.deleteData(weatherInfo: cityTemperatureDetails[indexPath.row])
            if bIsSuccessfullyDeleted {
                cityTemperatureDetails.remove(at: indexPath.row)
                tableView.reloadData()
            } else {
                let userInfo: [AnyHashable : Any]? =
                    [
                        NSLocalizedDescriptionKey :  NSLocalizedString("Error", value: "Error in deleting the record. Try Later.", comment: "")
                ]
                let err: NSError = NSError(domain: "", code: -1, userInfo: userInfo)
                self.showErrorAlert(error: err)
            }
        }
    }
    
    //  MARK: -  UISearchBarDelegate Method
    public func searchBarSearchButtonClicked(_ searchBar: UISearchBar)  {
        // Do some search stuff
        searchBar.resignFirstResponder()
        searchBarCityName = searchBar.text
        DispatchQueue.main.async  {
            // show activity indicator
            self.view.alpha = 0.5
            self.activityIndicator.isHidden = false
            self.activityIndicator.startAnimating()
        }
        /* Block base responseUIHandler.
            Receives the response, updaes the datasource and reloads the tableview
            call GetWeatherForecastService */
        WeatherForecastManager.sharedInstance.getWeatherForecast(searchBarCityName!, responseUIHandler:  {(response: Any?, error:NSError?) in
            if error != nil {
                // show error
                DispatchQueue.main.async {
                    self.showErrorAlert(error: error!)
                }
            } else {
                let weatherInfo: Weather = response as! Weather
                self.cityTemperatureDetails.append(weatherInfo)
                self.reloadCityList()
            }
        })
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar)  {
        // Stop doing the search stuff
        // and clear the text in the search bar
        searchBar.text = ""
    }
    
    //  MARK: -  prepareforsegue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)  {
        if segue.identifier == UIConstants.listToDetails {
            if sender is ListDetailsTableViewCell {
                let detailCell = sender as? ListDetailsTableViewCell
                let indexpath = tableViewTemperatureList.indexPath(for: detailCell!)
                let weatherForecast = cityTemperatureDetails[(indexpath?.row)!]
                
                let detailsVC = segue.destination as! WeatherDetailsViewController
                detailsVC.weatherInfo = weatherForecast
            }
        }
    }
    
}
