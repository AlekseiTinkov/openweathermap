import Foundation


class SettingsVarible {
    
    static let shared = SettingsVarible()
    
    private let userDefaults = UserDefaults.standard
    
    private let userDefaultsTempUnitsKey = "tempUnits"
    private let userDefaultsWindUnitsKey = "windUnits"
    private let userDefaultsPressureUnitsKey = "pressureUnits"
    private let userDefaultsApiKey = "apiKey"
    
    @Observable
    private(set) var units: Units = Units(tempUnits: .celsius, windUnits: .metrPerSec, pressureUnits: .hPa)
    
    func getUnits() {
        let tempUnits = TempUnits(rawValue: userDefaults.integer(forKey: userDefaultsTempUnitsKey)) ?? TempUnits.celsius
        let windUnits = WindUnits(rawValue: userDefaults.integer(forKey: userDefaultsWindUnitsKey)) ?? WindUnits.metrPerSec
        let pressureUnits = PressureUnits(rawValue: userDefaults.integer(forKey: userDefaultsPressureUnitsKey)) ?? PressureUnits.hPa
        units = Units(tempUnits: tempUnits, windUnits: windUnits, pressureUnits: pressureUnits)
    }
    
    func setTempUnits(tempUnits: TempUnits) {
        units.tempUnits = tempUnits
        userDefaults.set(tempUnits.rawValue, forKey: userDefaultsTempUnitsKey)
    }
    
    func setWindUnits(windUnits: WindUnits) {
        units.windUnits = windUnits
        userDefaults.set(windUnits.rawValue, forKey: userDefaultsWindUnitsKey)
    }
    
    func setPressureUnits(pressureUnits: PressureUnits) {
        units.pressureUnits = pressureUnits
        userDefaults.set(pressureUnits.rawValue, forKey: userDefaultsPressureUnitsKey)
    }
    
    func setApiKey(apiKey: String?) {
        userDefaults.set(apiKey, forKey: userDefaultsApiKey)
    }
    
    func getApiKey() -> String? {
        userDefaults.string(forKey: userDefaultsApiKey)
    }
        
}
