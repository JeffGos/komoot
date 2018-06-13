import Foundation

struct Photo: Codable {
    let id: String?
    let secret: String?
    let server: String?
    let farm: Int?
    let title: String?
    
    func getImageCacheId() -> String {
        let imageCacheId = "\(id!)-\(farm!)-\(server!)-\(secret!)"
        
        return imageCacheId
    }
}

struct SearchResult: Codable {
    let page: Int?
    let pages: Int?
    let perpage: Int?
    let total: String?
    let photo: [Photo]?
}

struct PhotoSearchResponse: Codable {
    let stat: String?
    let photos: SearchResult?
}
