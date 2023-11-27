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
    case defaultUrlDoesntExist
}

protocol NetworkClient {
    @discardableResult
    func send(urlRequest: URLRequest,
              onResponse: @escaping (Result<Data, Error>) -> Void) -> NetworkTask?

    @discardableResult
    func send<T: Decodable>(urlRequest: URLRequest,
                            cacheFileName: String?,
                            cacheTimeOutInterval: Int?,
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
    func send<T: Decodable>(urlRequest: URLRequest, cacheFileName: String?, cacheTimeOutInterval: Int?, type: T.Type, onResponse: @escaping (Result<T, Error>) -> Void) -> NetworkTask? {
        
        if let fileName = cacheFileName,
           let timeOutInterval = cacheTimeOutInterval,
           !isCacheTimeOut(cacheFileName: fileName, timeOutInterval: timeOutInterval) {
            var data = Data()
            do {
                data = try readCacheFile(cacheFileName: fileName)
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
                writeCacheFile(cacheFileName: cacheFileName, data: data)
                self.parse(data: data, type: type, onResponse: onResponse)
            case let .failure(error):
                onResponse(.failure(error))
            }
        }
    }
    
    private func isCacheTimeOut(cacheFileName: String, timeOutInterval: Int) -> Bool {
        if let cacheDate = fileModificationDate(fileName: cacheFileName) {
            return Int(Date.timeIntervalSinceReferenceDate - cacheDate.timeIntervalSinceReferenceDate) > timeOutInterval
        }
        return true
    }
    
    private func fileModificationDate(fileName: String) -> Date? {
        guard var url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return nil }
        url.appendPathComponent(fileName)
        do {
            let attr = try FileManager.default.attributesOfItem(atPath: url.path)
            return attr[FileAttributeKey.modificationDate] as? Date
        } catch {
            return nil
        }
    }
    
    private func writeCacheFile(cacheFileName: String?, data: Data) {
        guard let cacheFileName,
              var url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
        else {
            return
        }
        url.appendPathComponent(cacheFileName)
        FileManager.default.createFile(atPath: url.path, contents: data)
    }
    
    private func readCacheFile(cacheFileName: String) throws -> Data {
        guard var url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
        else {
            throw FileManagerError.defaultUrlDoesntExist
        }
        url.appendPathComponent(cacheFileName)
        if !FileManager.default.fileExists(atPath: url.path) {
            throw FileManagerError.fileDoesntExist
        }
        return try Data(contentsOf: url)
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
