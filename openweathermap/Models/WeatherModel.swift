import Foundation

struct WeatherModel: Codable {
    let main: Main
    let name: String
}

struct Main: Codable {
    let temp: Double
}
