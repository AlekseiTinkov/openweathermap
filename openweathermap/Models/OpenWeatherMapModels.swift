import Foundation

struct HourlyForecastModel: Codable {
    let cod: String
    let list: [ListModel]
    let city: CityModel
}

struct СurrentWeatherModel: Codable {
    let main: MainModel
    let weather: [WeatherModel]
}

struct ListModel: Codable {
    let dt: Int64
    let main: MainModel
    let weather: [WeatherModel]
}

struct CityModel: Codable {
    let sunrise: Int64
    let sunset: Int64
}

struct WeatherModel: Codable {
    let description: String
    let icon: String
}

struct MainModel: Encodable, Decodable {
    let temp: Double
    let feelsLike: Double
    enum CodingKeys: String, CodingKey {
        case temp
        case feelsLike = "feels_like"
    }
}
