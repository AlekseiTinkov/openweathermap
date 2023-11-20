import Foundation

struct GeoModel: Decodable {
    let name: String
    let localNames: LocalNames?
    let lat: Double
    let lon: Double
    let country: String?
    let state: String?
    enum CodingKeys: String, CodingKey {
        case name
        case localNames = "local_names"
        case lat
        case lon
        case country
        case state
    }
}

struct LocalNames: Codable {
    let en: String?
    let ru: String?
}


