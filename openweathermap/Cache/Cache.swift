import Foundation

final class Cache {
    static let shared = Cache()

    private var timeout: Int = 0
    
    private let cacheDirectory = "openweathermap.cache"
    private var cachePath: URL
    
    private func fileModificationDate(url: URL) -> Date? {
        do {
            let attr = try FileManager.default.attributesOfItem(atPath: url.path)
            return attr[FileAttributeKey.modificationDate] as? Date
        } catch {
            return nil
        }
    }
    
    private func makePath(_ cachePath: URL) {
        if !FileManager.default.fileExists(atPath: cachePath.path) {
            do {
                try FileManager.default.createDirectory(atPath: cachePath.path, withIntermediateDirectories: true, attributes: nil)
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    private init() {
        self.cachePath = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first ?? URL(fileURLWithPath: ".")
        self.cachePath.appendPathComponent(cacheDirectory)
        makePath(self.cachePath)
    }
    
    func initCache(timeout: Int) {
        self.timeout = timeout

        do {
            let items = try FileManager.default.contentsOfDirectory(atPath: cachePath.path)
            for item in items {
                print("Found \(item)")
                if isCacheTimeOut(cacheFileName: item) {
                    var url = self.cachePath
                    url.appendPathComponent(item)
                    try FileManager.default.removeItem(atPath: url.path)
                    print("-> deleted")
                }
            }
        } catch {
            print(error.localizedDescription)
        }
        print(">>> initCache <<<")
    }
    
    func isCacheTimeOut(cacheFileName: String) -> Bool {
        var url = self.cachePath
        url.appendPathComponent(cacheFileName)
        if let cacheDate = fileModificationDate(url: url) {
            return Int(Date.timeIntervalSinceReferenceDate - cacheDate.timeIntervalSinceReferenceDate) > self.timeout
        }
        return true
    }
    
    func writeCacheFile(cacheFileName: String, data: Data) {
        var url = self.cachePath
        url.appendPathComponent(cacheFileName)
        FileManager.default.createFile(atPath: url.path, contents: data)
    }
    
    func readCacheFile(cacheFileName: String) throws -> Data {
        var url = self.cachePath
        url.appendPathComponent(cacheFileName)
        if !FileManager.default.fileExists(atPath: url.path) {
            throw FileManagerError.fileDoesntExist
        }
        return try Data(contentsOf: url)
    }
    
    func clearCache() {
        do {
            let items = try FileManager.default.contentsOfDirectory(atPath: cachePath.path)
            for item in items {
                print("Delete \(item)...")
                var url = self.cachePath
                url.appendPathComponent(item)
                try FileManager.default.removeItem(atPath: url.path)
            }
        } catch {
            print(error.localizedDescription)
        }
        print(">>> clearCache <<<")
    }

}
