import Foundation

//http://api.openweathermap.org/geo/1.0/direct?q=London&limit=5&appid=yourApiKey

private let baseURL="https://api.openweathermap.org/"
private let appId="yourApiKey"

func GetGeoRequest(locationName: String) -> URLRequest? {
    let urlString = "\(baseURL)geo/1.0/direct?q=\(locationName)&limit=5&appid=\(appId)"
    guard
        let urlString = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
        let url = URL(string: urlString)
    else { return nil }
    
    var urlRequest = URLRequest(url: url)
    urlRequest.httpMethod = "GET"
    return urlRequest
}
