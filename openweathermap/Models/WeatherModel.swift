import Foundation

struct WeatherModel: Codable {
    let weather: [Weather]
    let main: Main
    let name: String
}

struct Weather: Codable {
    let description: String
    let icon: String
}

struct Main: Encodable, Decodable {
    let temp: Double
    let feelsLike: Double
    enum CodingKeys: String, CodingKey {
        case temp
        case feelsLike = "feels_like"
    }
}
