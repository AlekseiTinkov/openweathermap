import Foundation

final class LocationPageViewModel {
    
    private let networkClient = DefaultNetworkClient()
    
    private let cacheTimeOutInterval = 60 * 30 // 30 minutes
    
    @Observable
    private(set) var weaterInfo: WeaterInfoModel?
    
    private func convertTemp(temp: Double) -> String {
        return "\(round(temp * 10) / 10.0)°"
    }
    
    func convertWeatherToInfo(_ weatherModel: WeatherModel) -> WeaterInfoModel {
        return WeaterInfoModel(name: weatherModel.name,
                               temp: convertTemp(temp: weatherModel.main.temp),
                               feelsLike: "feels like".localized + " " + convertTemp(temp: weatherModel.main.feelsLike),
                               icon: "https://openweathermap.org/img/wn/\(weatherModel.weather[0].icon)@2x.png",
                               description: weatherModel.weather[0].description
        )
    }
    
    func loadWeather(lat: Double, lon: Double) {
        guard let urlRequest = GetWeatherRequest(lat: lat, lon: lon) else { return }
        var cacheFileName = locations.first(where: {$0.lat == lat && $0.lon == lon})?.id.uuidString
        if cacheFileName != nil {
            cacheFileName = (cacheFileName ?? "") + "-WEATHER"
        }
        print(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!)
        
        DispatchQueue.global().async {
            self.networkClient.send(urlRequest: urlRequest, 
                                    cacheFileName: cacheFileName, 
                                    cacheTimeOutInterval: self.cacheTimeOutInterval,
                                    type: WeatherModel.self,
                                    onResponse: {result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let model):
                        self.weaterInfo = self.convertWeatherToInfo(model)
                        print(">>> \(model)")
                    case .failure(let error):
                        print(">>> \(error)")
                    }
                }
            })
        }
    }
    
}
