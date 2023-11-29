import Foundation

final class AddLocationViewModel {
    
    private let networkClient = DefaultNetworkClient()
    
    @Observable
    private(set) var searchResult: [LocationModel] = []
    
    func concatCountryAndState(country: String?, state: String?) -> String {
        if let country,
           let state {
            return country + ", " + state
        }
        if let country { return country }
        if let state { return state }
        return ""
    }
    
    func convertGeoToLocation(_ geoModel: GeoModel) -> LocationModel {
        var name = geoModel.name
        if "languageId".localized == "ru" {
            if let localName = geoModel.localNames?.ru { name = localName }
        }
        if "languageId".localized == "en" {
            if let localName = geoModel.localNames?.en { name = localName }
        }
        let countryAndState = concatCountryAndState(country: geoModel.country, state: geoModel.state)
        return LocationModel(id: UUID(), name: name, lat: geoModel.lat, lon: geoModel.lon, countryAndState: countryAndState)
    }
    
    func searchLocation(searchString: String) {
        guard let urlRequest = GetGeoRequest(locationName: searchString) else { return }
        
        DispatchQueue.global().async {
            self.networkClient.send(urlRequest: urlRequest,
                                    cacheFileName: nil,
                                    type: [GeoModel].self,
                                    onResponse: {result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let model):
                        self.searchResult = model.map { self.convertGeoToLocation($0) }
                    case .failure(let error):
                        print(">>> \(error)")
                    }
                }
            })
        }
    }
    
    
}
