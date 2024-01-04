import Foundation

enum TempUnits: Int, CaseIterable {
    case celsius, fahrenheit, kelvin
    
    var name: String {
        switch self {
        case .celsius:
            return "°C"
        case .fahrenheit:
            return "°F"
        case .kelvin:
            return "°K"
        }
    }
}

enum WindUnits: Int, CaseIterable {
    case metrPerSec, kiloMetrPerHour
    
    var name: String {
        switch self {
        case .metrPerSec:
            return "m/s".localized
        case .kiloMetrPerHour:
            return "km/h".localized
        }
    }
}

enum PressureUnits: Int, CaseIterable {
    case mmHg, hPa
    
    var name: String {
        switch self {
        case .mmHg:
            return "mmHg.".localized
        case .hPa:
            return "hPa".localized
        }
    }
}
