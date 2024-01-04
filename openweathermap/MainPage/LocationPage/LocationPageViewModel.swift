import Foundation

enum CacheFileSuffix: String {
    case currentWeather = "CurrentWeather"
    case hourlyForecast = "HourlyForecast"
    case dailyForecast = "DailyForecast"
}

let iconsNameReplace: [String : String] = [
    "03n" : "03d",
    "04n" : "04d",
    "09n" : "09d",
    "11n" : "11d",
    "13n" : "13d",
    "50n" : "50d"
]

final class LocationPageViewModel {
    
    private let networkClient = DefaultNetworkClient()
    
    @Observable
    private(set) var currentWeatherInfo: CurrentWeaterInfoModel?
    
    @Observable
    private(set) var hourlyForecastInfo: [HourlyForecastInfoModel] = []

    @Observable
    private(set) var dailyForecastInfo: [DailyForecastInfoModel] = []
    
    private func convertTemp(temp: Double) -> String {
        var outTemp: Double
        switch tempUnits {
        case .fahrenheit:
            outTemp = temp * 9 / 5 + 32
        case .kelvin:
            outTemp = temp + 273.15
        default:
            outTemp = temp
        }
        let sign = outTemp > 0 ? "+" : ""
        return "\(sign)\(lroundl(outTemp))°"
    }
    
    private func convertTempInterval(tempMin: Double, tempMax: Double) -> String {
        let min = convertTemp(temp: tempMin)
        let max = convertTemp(temp: tempMax)
        if min == max { return min }
        return "\(min) ... \(max)"
    }
    
//    private func getIconUrl(name: String, size: Int) -> String {
//        var sizeSuffix = ""
//        if size == 2 { sizeSuffix = "@2x" }
//        return "https://openweathermap.org/img/wn/\(name)\(sizeSuffix).png"
//    }
    
    private func getIconName(_ icon: String) -> String {
        let name = iconsNameReplace[icon]
        return name ?? icon
    }
    
    func convertCurrentWeatherToInfo(_ currentWeatherModel: СurrentWeatherModel) -> CurrentWeaterInfoModel {
        return CurrentWeaterInfoModel(
                               temp: convertTemp(temp: currentWeatherModel.main.temp),
                               feelsLike: "feels like".localized + " " + convertTemp(temp: currentWeatherModel.main.feelsLike),
                               icon: getIconName(currentWeatherModel.weather[0].icon), //getIconUrl(name: currentWeatherModel.weather[0].icon, size: 2),
                               description: currentWeatherModel.weather[0].description
        )
    }
    
    private func convertHourlyForecastToInfo(_ forecastModel: HourlyForecastModel) -> [HourlyForecastInfoModel] {
        let timeFormatter = DateFormatter()
        let dateFormatter = DateFormatter()
        timeFormatter.dateFormat = "HH:mm"
        dateFormatter.dateFormat = "dd.MM"
        
        return forecastModel.list.compactMap({
            let dt = Date(timeIntervalSince1970: TimeInterval($0.dt))
            if dt > Date() {
                return HourlyForecastInfoModel(
                    time: timeFormatter.string(from: dt),
                    date: dateFormatter.string(from: dt),
                    temp: convertTemp(temp: $0.main.temp),
                    icon: getIconName($0.weather[0].icon) //getIconUrl(name: $0.weather[0].icon, size: 1)
                )
            } else {
                return nil
            }
        })
    }
    
    private func convertDailyForecastToInfo(_ forecastModel: DailyForecastModel) -> [DailyForecastInfoModel] {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "E dd.MM.yyyy"
        
        return forecastModel.list.compactMap({
            let dt = Date(timeIntervalSince1970: TimeInterval($0.dt))
            if dt > Date() {
                return DailyForecastInfoModel(
                    date: dateFormatter.string(from: dt),
                    temp: convertTempInterval(tempMin: $0.temp.min, tempMax: $0.temp.max),
                    icon: getIconName($0.weather[0].icon), //getIconUrl(name: $0.weather[0].icon, size: 1),
                    description: $0.weather[0].description)
            } else {
                return nil
            }
        })
    }
    
    private func getCacheFileName(lat: Double, lon: Double, suffix: CacheFileSuffix) -> String? {
        if let uuid = locations.first(where: {$0.lat == lat && $0.lon == lon})?.locationId.uuidString {
            return uuid + "-" + suffix.rawValue
        }
        return nil
    }
    
    func loadCurrentWeather(lat: Double, lon: Double) {
        guard let urlRequest = GetCurrentWeatherRequest(lat: lat, lon: lon) else { return }
        let cacheFileName = getCacheFileName(lat: lat, lon: lon, suffix: .currentWeather)
        
        DispatchQueue.global().async {
            self.networkClient.send(urlRequest: urlRequest, 
                                    cacheFileName: cacheFileName,
                                    type: СurrentWeatherModel.self,
                                    onResponse: {result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let model):
                        self.currentWeatherInfo = self.convertCurrentWeatherToInfo(model)
                        //print(">>> \(model)")
                    case .failure(let error):
                        print(">>> \(error)")
                    }
                }
            })
        }
    }
    
    func loadHourlyForecast(lat: Double, lon: Double) {
        guard let urlRequest = GetHourlyForecastRequest(lat: lat, lon: lon) else { return }
        let cacheFileName = getCacheFileName(lat: lat, lon: lon, suffix: .hourlyForecast)
        
        DispatchQueue.global().async {
            self.networkClient.send(urlRequest: urlRequest,
                                    cacheFileName: cacheFileName,
                                    type: HourlyForecastModel.self,
                                    onResponse: {result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let model):
                        self.hourlyForecastInfo = self.convertHourlyForecastToInfo(model)
                        //print(">>> \(model)")
                    case .failure(let error):
                        print(">>> \(error)")
                    }
                }
            })
        }
    }
    
    func loadDailyForecast(lat: Double, lon: Double) {
        guard let urlRequest = GetDailyForecastRequest(lat: lat, lon: lon) else { return }
        let cacheFileName = getCacheFileName(lat: lat, lon: lon, suffix: .dailyForecast)
        
        DispatchQueue.global().async {
            self.networkClient.send(urlRequest: urlRequest,
                                    cacheFileName: cacheFileName,
                                    type: DailyForecastModel.self,
                                    onResponse: {result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let model):
                        self.dailyForecastInfo = self.convertDailyForecastToInfo(model)
                        //print(">>> \(model)")
                    case .failure(let error):
                        print(">>> \(error)")
                    }
                }
            })
        }
    }
    
}
