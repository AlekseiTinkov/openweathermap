import Foundation

enum CacheFileSuffix: String {
    case currentWeather = "CurrentWeather"
    case forecast = "Forecast"
}

final class LocationPageViewModel {
    
    private let networkClient = DefaultNetworkClient()
    
    @Observable
    private(set) var currentWeatherInfo: CurrentWeaterInfoModel?
    
    @Observable
    private(set) var forecastInfo: [HourlyForecastInfoModel] = []

    private func convertTemp(temp: Double) -> String {
        return "\(round(temp * 10) / 10.0)°"
    }
    
    private func getIconUrl(name: String, size: Int) -> String {
        var sizeSuffix = ""
        if size == 2 { sizeSuffix = "@2x" }
        return "https://openweathermap.org/img/wn/\(name)\(sizeSuffix).png"
    }
    
    func convertCurrentWeatherToInfo(_ currentWeatherModel: СurrentWeatherModel) -> CurrentWeaterInfoModel {
        return CurrentWeaterInfoModel(
                               temp: convertTemp(temp: currentWeatherModel.main.temp),
                               feelsLike: "feels like".localized + " " + convertTemp(temp: currentWeatherModel.main.feelsLike),
                               icon: getIconUrl(name: currentWeatherModel.weather[0].icon, size: 2),
                               description: currentWeatherModel.weather[0].description
        )
    }
    
    private func convertForecastToInfo(_ forecastModel: HourlyForecastModel) -> [HourlyForecastInfoModel] {
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
                    icon: getIconUrl(name: $0.weather[0].icon, size: 1)
                )
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
    
    func loadForecast(lat: Double, lon: Double) {
        guard let urlRequest = GetForecastRequest(lat: lat, lon: lon) else { return }
        let cacheFileName = getCacheFileName(lat: lat, lon: lon, suffix: .forecast)
        
        DispatchQueue.global().async {
            self.networkClient.send(urlRequest: urlRequest,
                                    cacheFileName: cacheFileName,
                                    type: HourlyForecastModel.self,
                                    onResponse: {result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let model):
                        self.forecastInfo = self.convertForecastToInfo(model)
                        //print(">>> \(model)")
                    case .failure(let error):
                        print(">>> \(error)")
                    }
                }
            })
        }
    }
    
}
