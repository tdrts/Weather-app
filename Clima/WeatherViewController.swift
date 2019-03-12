//
//  ViewController.swift
//  WeatherApp
//
//

import UIKit
import CoreLocation
import Alamofire
import SwiftyJSON


class WeatherViewController: UIViewController, CLLocationManagerDelegate, ChangeCityDelegate {
    
    
    
    
    //Constants
    let WEATHER_URL = "http://api.openweathermap.org/data/2.5/weather"
    let APP_ID = "f094b4efd63c1afe6b983fd727805199"
    
    var temp : Int = 0

    //instance variables
    
    let locationManager = CLLocationManager()
    let weatherDataModel = WeatherDataModel()

    
    //Pre-linked IBOutlets
    @IBOutlet weak var weatherIcon: UIImageView!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        //Set up the location manager
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    
    
    //Networking

    
    func getWeatherData (url : String, parameters : [String : String]) {
        
        Alamofire.request(url, method: .get, parameters: parameters).responseJSON {
            response in
            if response.result.isSuccess{
                
                print("Success! Got the weather data")
                
                let weatherJSON : JSON = JSON(response.result.value!)
                self.updateWeatherData(json: weatherJSON)
                
                
            } else  {
                
                print("Error \(response.result.error)")
                self.cityLabel.text = "Connection Issues"
                
            }
        }
    }
    

    
    func updateWeatherFormat(temperature : Double) {
        
        weatherDataModel.temperature = Int(temperature - 273.15)
        print(String(weatherDataModel.temperature))
        
        updateUIWithWeatherData()
    }
    
    
    
    
    
    //JSON Parsing
   

    func updateWeatherData(json : JSON) {
        
        if let tempResults = json["main"]["temp"].double {
        
            //weatherDataModel.temperature = Int(tempResults - 273.15)
            
            updateWeatherFormat(temperature: tempResults)
            
            temp = Int(tempResults)
        
            weatherDataModel.city = json["name"].stringValue
        
            weatherDataModel.condition = json["weather"][0]["id"].intValue
        
            weatherDataModel.weatherIconName = weatherDataModel.updateWeatherIcon(condition: weatherDataModel.condition)
            
            updateUIWithWeatherData()
        
        } else {
            cityLabel.text = "Location Unavailable"
        }
        
    }

    
    
    
    //UI Updates
   
    
    
    
    
    func updateUIWithWeatherData() {
        
        cityLabel.text = weatherDataModel.city
        temperatureLabel.text = String(weatherDataModel.temperature) + "°C"
        weatherIcon.image = UIImage(named: weatherDataModel.weatherIconName)
        
        
        
    }
    
    
    
    
    
    //Location Manager Delegate Methods
    
    
    

    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
            let location = locations[locations.count - 1]
        
        if location.horizontalAccuracy > 0 {
            locationManager.stopUpdatingLocation()
            locationManager.delegate = nil
            
            print("Longitude = \(location.coordinate.longitude)")
            print("Latitude = \(location.coordinate.latitude)")
            
            let latitude = String(location.coordinate.latitude)
            let longitude = String(location.coordinate.longitude)
            
            let params : [String : String] = ["lat" : latitude, "lon" : longitude, "appid" : APP_ID]
            
            getWeatherData(url: WEATHER_URL, parameters : params)
            
        }
    }
    
    
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
        cityLabel.text = "Location Unavailable"
    }
    
    

    
    //Change City Delegate methods
   
    
    

    
    func userAddedANewCityName(city: String) {
        print(city)
        
        let params : [String: String] = ["q" : city, "appid" : APP_ID]
        getWeatherData(url: WEATHER_URL, parameters: params)
    }

    
   
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "changeCityName" {
            
            let destinationVC = segue.destination as! ChangeCityViewController
            
            destinationVC.delegate = self
            
        }
    }
    
    @IBAction func mySwitch(_ sender: UISwitch) {
        if sender.isOn {
            updateWeatherFormat(temperature: Double(temp))
        } else {
            
            updateWeatherFormat(temperature: (Double(temp * ( 9 / 5 )  + 32)))
            temperatureLabel.text = String(weatherDataModel.temperature) + "°F"
            
        }
        
    }

    
    
    
    
}

