import Foundation

struct LocationModel: Decodable {
    let name: String
    let lat: Double
    let lon: Double
    let countryAndState: String
}
