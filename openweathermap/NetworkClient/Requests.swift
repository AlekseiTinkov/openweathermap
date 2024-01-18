import Foundation

private let baseURL="https://api.openweathermap.org/"
private let appId="yourApiKey"

private func GetApiKey() -> String {
    guard var apiKey = SettingsVarible.shared.getApiKey() else { return appId }
    apiKey = apiKey.filter{!$0.isWhitespace}
    if apiKey == "" { return appId }
    return apiKey
}

func GetGeoRequest(locationName: String) -> URLRequest? {
    let urlString = "\(baseURL)geo/1.0/direct?q=\(locationName)&limit=5&appid=\(GetApiKey())"
    guard
        let urlString = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
        let url = URL(string: urlString)
    else { return nil }
    
    var urlRequest = URLRequest(url: url)
    urlRequest.httpMethod = "GET"
    return urlRequest
}

func GetCurrentWeatherRequest(lat: Double, lon: Double) -> URLRequest? {
    let urlString = "\(baseURL)data/2.5/weather?lat=\(lat)&lon=\(lon)&units=metric&lang=\("languageId".localized)&appid=\(GetApiKey())"
    guard
        let urlString = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
        let url = URL(string: urlString)
    else { return nil }
    
    var urlRequest = URLRequest(url: url)
    urlRequest.httpMethod = "GET"
    return urlRequest
}

func GetHourlyForecastRequest(lat: Double, lon: Double) -> URLRequest? {
    let urlString = "\(baseURL)data/2.5/forecast?lat=\(lat)&lon=\(lon)&units=metric&lang=\("languageId".localized)&appid=\(GetApiKey())"
    guard
        let urlString = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
        let url = URL(string: urlString)
    else { return nil }
    
    var urlRequest = URLRequest(url: url)
    urlRequest.httpMethod = "GET"
    return urlRequest
}

func GetDailyForecastRequest(lat: Double, lon: Double) -> URLRequest? {
    let urlString = "\(baseURL)data/2.5/forecast/daily?lat=\(lat)&lon=\(lon)&units=metric&lang=\("languageId".localized)&cnt=16&appid=\(GetApiKey())"
    guard
        let urlString = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
        let url = URL(string: urlString)
    else { return nil }
    
    var urlRequest = URLRequest(url: url)
    urlRequest.httpMethod = "GET"
    return urlRequest
}
