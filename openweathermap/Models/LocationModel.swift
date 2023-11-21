import Foundation

struct LocationModel: Encodable, Decodable {
    let name: String
    let lat: Double
    let lon: Double
    let countryAndState: String
}
