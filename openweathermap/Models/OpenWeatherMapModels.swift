import Foundation

struct DailyForecastModel: Codable {
    let cod: String
    let list: [DailyListModel]
}

struct HourlyForecastModel: Codable {
    let cod: String
    let list: [HourlyListModel]
    let city: CityModel
}

struct СurrentWeatherModel: Codable {
    let main: MainModel
    let weather: [WeatherModel]
}

struct HourlyListModel: Codable {
    let dt: Int64
    let main: MainModel
    let weather: [WeatherModel]
}

struct DailyListModel: Codable {
    let dt: Int64
    let temp: TempModel
    let weather: [WeatherModel]
}

struct TempModel: Codable {
    let min: Double
    let max: Double
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
