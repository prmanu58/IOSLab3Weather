//
//  ViewController.swift
//  Lab3
//  Created by Pramesh Anuradha on 2022-04-05.
//

import UIKit
import CoreLocation

class ViewController: UIViewController, CLLocationManagerDelegate, UITextFieldDelegate {
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var weatherImage: UIImageView!
    @IBOutlet weak var weatherConditionLabel: UILabel!
    
    let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchTextField.delegate = self;
        locationManager.delegate = self;
        
        let config = UIImage.SymbolConfiguration(paletteColors: [.systemBrown, .systemYellow, .systemGray]);
        weatherImage.preferredSymbolConfiguration = config;
    }
    @IBAction func onSearchedTapped(_ sender: UIButton) {
        searchTextField.endEditing(true);
        getWeather(search: searchTextField.text);
    }
    @IBAction func onGetLocationTapped(_ sender: UIButton) {
        locationManager.requestWhenInUseAuthorization();
        locationManager.requestLocation();
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.endEditing(true);
        getWeather(search: textField.text);
        return true;
    }
    
    private func getWeather(search: String?) {
        guard let search = search else {
            return
        }
        
        let url = getUrl(search: search);
        
        guard let url = url else {
            print("could not get URL");
            return
        }
        
        let session = URLSession.shared;
        
        let dataTask = session.dataTask(with: url) { data, response, error in
            guard error == nil else {
                print("recieved error");
                return
            }
            
            guard let data = data else {
                print("No data found");
                return
            }
            
            if let weather = self.parseJson(data: data) {
                DispatchQueue.main.async {
                    self.locationLabel.text = weather.location.name;
                    self.temperatureLabel.text = "\(weather.current.temp_c)C";
                    self.weatherConditionLabel.text = "\(weather.current.condition.text)";
                    self.weatherImage.image = UIImage(systemName: self.getImageString(code: weather.current.condition.code));
                }
            }
        }
        
        dataTask.resume();
    }
    
    private func parseJson(data: Data) -> WeatherResponse? {
        let decoder = JSONDecoder()
        var weatherResponse: WeatherResponse?
        
        do {
            weatherResponse = try decoder.decode(WeatherResponse.self, from: data);
        } catch {
            print("Error parsing weather data");
            print(error);
        }
        
        return weatherResponse;
    }
    
    private func getUrl(search: String) -> URL? {
        let baseUrl = "https://api.weatherapi.com/v1/";
        let currentEndpoint = "current.json";
        let apikey = "775668c05fa543c1a3a24928220604";
        
        let url = "\(baseUrl)\(currentEndpoint)?key=\(apikey)&q=\(search)";
        return URL(string: url);
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        if let location = locations.last {
            let latitude = location.coordinate.latitude;
            let longitude = location.coordinate.longitude;
            getWeather(search: "\(latitude),\(longitude)");
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error);
    }
 
    
    private func getImageString(code: Int) -> String {
        var imageString: String = "cloud.moon";
        switch code {
        case 1000:
            imageString = "sun.max";
            break;
        case 1003:
            imageString = "cloud.sun";
            break;
        case 1030, 1135, 1147:
            imageString = "cloud.fog";
            break;
        case 1006:
            imageString = "cloud";
            break;
        case 1009:
            imageString = "cloud";
            break;
        case 1150:
            imageString = "cloud.drizzle";
            break;
        case 1153:
            imageString = "cloud.drizzle";
            break;
        case 1168:
            imageString = "cloud.drizzle";
            break;
        case 1072:
            imageString = "cloud.drizzle";
            break;
        case 1219, 1222, 1225, 1255, 1258:
            imageString = "cloud.snow";
            break;
        case 1063:
            imageString = "cloud.rain";
            break;
        case 1183:
            imageString = "cloud.rain";
            break;
        case 1195:
            imageString = "cloud.heavyrain";
            break;
        case 1186:
            imageString = "cloud.rain";
            break;
        case 1189:
            imageString = "cloud.rain";
            break;
        case 1198:
            imageString = "cloud.rain";
            break;
        case 1192:
            imageString = "cloud.heavyrain";
            break;
        case 1252:
            imageString = "cloud.sleet";
            break;
        case 1249:
            imageString = "cloud.sleet";
            break;
        case 1207:
            imageString = "cloud.sleet";
            break;
        case 1204:
            imageString = "cloud.sleet";
            break;
        case 1069:
            imageString = "cloud.sleet";
            break;
        case 1066:
            imageString = "cloud.snow";
            break;
        case 1201:
            imageString = "cloud.heavyrain";
            break;
       case 1114:
            imageString = "wind.snow";
            break;
        case 1276:
            imageString = "cloud.bolt.rain";
            break;
        case 1087:
            imageString = "cloud.bolt.rain";
            break;
        case 1273:
            imageString = "cloud.bolt.rain";
            break;
        case 1279:
            imageString = "cloud.bolt";
            break;
        case 1180:
            imageString = "cloud.rain";
            break;
        case 1282:
            imageString = "cloud.bolt";
            break;
        default:
            imageString = "cloud.moon";

        }
        return imageString;
    }
}

struct WeatherResponse: Decodable {
    let location: Location;
    let current: Weather;
}

struct Location: Decodable {
    let name: String;
}

struct Weather: Decodable {
    let temp_c: Float;
    let condition: WeatherCondition;
}

struct WeatherCondition: Decodable {
    let text: String;
    let code: Int;
}


