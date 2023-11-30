import Foundation

enum NetworkClientError: Error {
    case httpStatusCode(Int)
    case urlRequestError(Error)
    case urlSessionError
    case parsingError
    case taskCreationFailed
}

enum FileManagerError: Error {
    case fileDoesntExist
}

protocol NetworkClient {
    @discardableResult
    func send(urlRequest: URLRequest,
              onResponse: @escaping (Result<Data, Error>) -> Void) -> NetworkTask?

    @discardableResult
    func send<T: Decodable>(urlRequest: URLRequest,
                            cacheFileName: String?,
                            type: T.Type,
                            onResponse: @escaping (Result<T, Error>) -> Void) -> NetworkTask?
}

struct DefaultNetworkClient: NetworkClient {
    private let session: URLSession
    private let decoder: JSONDecoder
    private let encoder: JSONEncoder

    init(session: URLSession = URLSession.shared,
         decoder: JSONDecoder = JSONDecoder(),
         encoder: JSONEncoder = JSONEncoder()) {
        self.session = session
        self.decoder = decoder
        self.encoder = encoder
    }

    @discardableResult
    func send(urlRequest: URLRequest, onResponse: @escaping (Result<Data, Error>) -> Void) -> NetworkTask? {

        let task = session.dataTask(with: urlRequest) { data, response, error in
            guard let response = response as? HTTPURLResponse else {
                onResponse(.failure(NetworkClientError.urlSessionError))
                return
            }

            guard 200 ..< 300 ~= response.statusCode else {
                onResponse(.failure(NetworkClientError.httpStatusCode(response.statusCode)))
                return
            }

            if let data = data {
                onResponse(.success(data))
                return
            } else if let error = error {
                onResponse(.failure(NetworkClientError.urlRequestError(error)))
                return
            } else {
                assertionFailure("Unexpected condition!")
                return
            }
        }

        task.resume()

        return DefaultNetworkTask(dataTask: task)
    }

    @discardableResult
    func send<T: Decodable>(urlRequest: URLRequest, cacheFileName: String?, type: T.Type, onResponse: @escaping (Result<T, Error>) -> Void) -> NetworkTask? {
        
        if let cacheFileName,
           !Cache.shared.isCacheTimeOut(cacheFileName: cacheFileName) {
            var data = Data()
            do {
                data = try Cache.shared.readCacheFile(cacheFileName: cacheFileName)
            } catch {
                onResponse(.failure(error))
            }
            print(">>> reading data from cache")
            self.parse(data: data, type: type, onResponse: onResponse)
            return nil
        }
        
        print(">>> reading data from server")
        return send(urlRequest: urlRequest) { result in
            switch result {
            case let .success(data):
                if cacheFileName != nil {
                    Cache.shared.writeCacheFile(cacheFileName: cacheFileName ?? "", data: data)
                }
                self.parse(data: data, type: type, onResponse: onResponse)
            case let .failure(error):
                onResponse(.failure(error))
            }
        }
    }
    
    private func parse<T: Decodable>(data: Data, type _: T.Type, onResponse: @escaping (Result<T, Error>) -> Void) {
        do {
            let response = try decoder.decode(T.self, from: data)
            onResponse(.success(response))
        } catch {
            onResponse(.failure(NetworkClientError.parsingError))
        }
    }
}
