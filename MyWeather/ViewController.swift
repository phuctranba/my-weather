//
//  ViewController.swift
//  MyWeather
//
//  Created by ZipEnter on 08/02/2021.
//

import UIKit
import CoreLocation

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, CLLocationManagerDelegate {

    @IBOutlet var table: UITableView!
    var models = [DailyWeatherEntry]()
    var hourlyModels = [HourlyWeatherEntry]()
    
    let locationManager = CLLocationManager()
    var currentLocation: CLLocation?
    var current: CurrentWeather?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        //Register 2 cells
        table.register(HourlyTableViewCell.nib(), forCellReuseIdentifier: HourlyTableViewCell.identifier)
        table.register(WeatherTableViewCell.nib(), forCellReuseIdentifier: WeatherTableViewCell.identifier)
        
        table.delegate = self
        table.dataSource = self
        
        table.backgroundColor = UIColor(red: 52/255.0, green: 109/255.0, blue: 179/255.0, alpha: 0)
        self.view.backgroundColor = UIColor(patternImage: UIImage(named: "background.jpg")!)

    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setupLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if !locations.isEmpty, currentLocation == nil {
            currentLocation = locations.first
            locationManager.stopUpdatingLocation()
            requestWeatherForLocation()
        }
    }
    
    func requestWeatherForLocation() {
        guard let currentLocation = currentLocation else {
            return
        }
        
        let long = currentLocation.coordinate.longitude
        let lat = currentLocation.coordinate.latitude
        
        let url = "https://api.darksky.net/forecast/ddcc4ebb2a7c9930b90d9e59bda0ba7a/\(lat),\(long)?exclude=[flags,minutely]"
        URLSession.shared.dataTask(with: URL(string: url)!, completionHandler: { data, response, error in

                    // Validation
                    guard let data = data, error == nil else {
                        print("something went wrong")
                        return
                    }

                    // Convert data to models/some object
                    var json: WeatherResponse?
                    do {
                        json = try JSONDecoder().decode(WeatherResponse.self, from: data)
                    }
                    catch {
                        print("error: \(error)")
                    }

                    guard let result = json else {
                        return
                    }

                    let entries = result.daily.data

                    self.models.append(contentsOf: entries)

                    let current = result.currently
                    self.current = current

                    self.hourlyModels = result.hourly.data

                    // Update user interface
                    DispatchQueue.main.async {
                        self.table.reloadData()

                        self.table.tableHeaderView = self.createTableHeader()
                    }

                }).resume()
    }
    
    func createTableHeader() -> UIView {
            let headerVIew = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: view.frame.size.width))

            headerVIew.backgroundColor = UIColor(red: 52/255.0, green: 109/255.0, blue: 179/255.0, alpha: 0)

            let locationLabel = UILabel(frame: CGRect(x: 10, y: 10, width: view.frame.size.width-20, height: headerVIew.frame.size.height/5))
        let imageWeather = UIImageView(frame: CGRect(x: 10, y: 20+locationLabel.frame.size.height, width: headerVIew.frame.size.width, height: headerVIew.frame.size.height/3.5))
        
            let summaryLabel = UILabel(frame: CGRect(x: 10, y: 20+locationLabel.frame.size.height+imageWeather.frame.size.height, width: view.frame.size.width-20, height: headerVIew.frame.size.height/5))
            let tempLabel = UILabel(frame: CGRect(x: 10, y: 20+locationLabel.frame.size.height+summaryLabel.frame.size.height+imageWeather.frame.size.height, width: view.frame.size.width-20, height: headerVIew.frame.size.height/5))

            headerVIew.addSubview(locationLabel)
            headerVIew.addSubview(imageWeather)
            headerVIew.addSubview(tempLabel)
            headerVIew.addSubview(summaryLabel)

            tempLabel.textAlignment = .center
            locationLabel.textAlignment = .center
            summaryLabel.textAlignment = .center

            locationLabel.text = "Current Location"

            guard let currentWeather = self.current else {
                return UIView()
            }

            tempLabel.text = "\(currentWeather.temperature)°"
            tempLabel.font = UIFont(name: "Helvetica-Bold", size: 32)
            summaryLabel.text = self.current?.summary
        
            let icon = currentWeather.icon.lowercased()
            if icon.contains("clear") {
                imageWeather.image = UIImage(named: "clear")
            }
            else if icon.contains("rain") {
                imageWeather.image = UIImage(named: "rain")
            }
            else {
                imageWeather.image = UIImage(named: "cloud")
            }
            imageWeather.contentMode = .scaleAspectFit

            return headerVIew
        }
    
    //Location
    func setupLocation(){
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    //Table
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            // 1 cell that is collectiontableviewcell
            return 1
        }
        // return models count
        return models.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: HourlyTableViewCell.identifier, for: indexPath) as! HourlyTableViewCell
                cell.configure(with: hourlyModels)
                cell.backgroundColor = UIColor(red: 52/255.0, green: 109/255.0, blue: 179/255.0, alpha: 0)
                return cell
            }
        
        // Continue
        let cell = tableView.dequeueReusableCell(withIdentifier: WeatherTableViewCell.identifier, for: indexPath) as! WeatherTableViewCell
        cell.configure(with: models[indexPath.row])
        cell.backgroundColor = UIColor(red: 52/255.0, green: 109/255.0, blue: 179/255.0, alpha: 0)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }

}

struct WeatherResponse: Codable {
    let latitude: Float
    let longitude: Float
    let timezone: String
    let currently: CurrentWeather
    let hourly: HourlyWeather
    let daily: DailyWeather
    let offset: Float
}

struct CurrentWeather: Codable {
    let time: Int
    let summary: String
    let icon: String
    let precipIntensity: Double
    let precipProbability: Double
    let temperature: Double
    let apparentTemperature: Double
    let dewPoint: Double
    let humidity: Double
    let pressure: Double
    let windSpeed: Double
    let windGust: Double
    let windBearing: Int
    let cloudCover: Double
    let uvIndex: Int
    let visibility: Double
    let ozone: Double
}

struct DailyWeather: Codable {
    let summary: String
    let icon: String
    let data: [DailyWeatherEntry]
}

struct DailyWeatherEntry: Codable {
    let time: Int
    let summary: String
    let icon: String
    let sunriseTime: Int
    let sunsetTime: Int
    let moonPhase: Double
    let precipIntensity: Float
    let precipIntensityMax: Float
    let precipProbability: Double
    let precipType: String?
    let temperatureHigh: Double
    let temperatureHighTime: Int
    let temperatureLow: Double
    let temperatureLowTime: Int
    let apparentTemperatureHigh: Double
    let apparentTemperatureHighTime: Int
    let apparentTemperatureLow: Double
    let apparentTemperatureLowTime: Int
    let dewPoint: Double
    let humidity: Double
    let pressure: Double
    let windSpeed: Double
    let windGust: Double
    let windGustTime: Int
    let windBearing: Int
    let cloudCover: Double
    let uvIndex: Int
    let uvIndexTime: Int
    let visibility: Double
    let ozone: Double
    let temperatureMin: Double
    let temperatureMinTime: Int
    let temperatureMax: Double
    let temperatureMaxTime: Int
    let apparentTemperatureMin: Double
    let apparentTemperatureMinTime: Int
    let apparentTemperatureMax: Double
    let apparentTemperatureMaxTime: Int
}

struct HourlyWeather: Codable {
    let summary: String
    let icon: String
    let data: [HourlyWeatherEntry]
}

struct HourlyWeatherEntry: Codable {
    let time: Int
    let summary: String
    let icon: String
    let precipIntensity: Float
    let precipProbability: Double
    let precipType: String?
    let temperature: Double
    let apparentTemperature: Double
    let dewPoint: Double
    let humidity: Double
    let pressure: Double
    let windSpeed: Double
    let windGust: Double
    let windBearing: Int
    let cloudCover: Double
    let uvIndex: Int
    let visibility: Double
    let ozone: Double
}
