import Foundation

final class LocationPageViewModel {
    
    private let networkClient = DefaultNetworkClient()
    
    @Observable
    private(set) var weaterInfo: WeaterInfoModel?
    
    func convertWeatherToInfo(_ weatherModel: WeatherModel) -> WeaterInfoModel {
        return WeaterInfoModel(name: weatherModel.name,
                               temp: "\(round(weatherModel.main.temp * 10) / 10.0)°"
        )
    }
    
    func loadWeather(lat: Double, lon: Double) {
        guard let urlRequest = GetWeatherRequest(lat: lat, lon: lon) else { return }
        
        DispatchQueue.global().async {
            self.networkClient.send(urlRequest: urlRequest,
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
