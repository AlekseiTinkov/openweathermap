import Foundation

struct CurrentWeaterInfoModel {
    let temp: String
    let feelsLike: String
    let icon: String
    let description: String
}

struct HourlyForecastInfoModel {
    let time: String
    let date: String
    let temp: String
    let icon: String
}

struct DailyForecastInfoModel {
    let date: String
    let temp: String
    let icon: String
    let description: String
}
