import Foundation


private let userDefaults = UserDefaults.standard

private let userDefaultsTempUnitsKey = "tempUnits"
private let userDefaultsWindUnitsKey = "windUnits"
private let userDefaultsPressureUnitsKey = "pressureUnits"

var tempUnits: TempUnits = TempUnits(rawValue: {
    return userDefaults.integer(forKey: userDefaultsTempUnitsKey)
}()) ?? TempUnits.celsius {
    didSet {
        userDefaults.set(tempUnits.rawValue, forKey: userDefaultsTempUnitsKey)
    }
}

var windUnits: WindUnits = WindUnits(rawValue: {
    return userDefaults.integer(forKey: userDefaultsWindUnitsKey)
}()) ?? WindUnits.metrPerSec {
    didSet {
        userDefaults.set(windUnits.rawValue, forKey: userDefaultsWindUnitsKey)
    }
}

var pressureUnits: PressureUnits = PressureUnits(rawValue: {
    return userDefaults.integer(forKey: userDefaultsPressureUnitsKey)
}()) ?? PressureUnits.mmHg {
    didSet {
        userDefaults.set(pressureUnits.rawValue, forKey: userDefaultsPressureUnitsKey)
    }
}


