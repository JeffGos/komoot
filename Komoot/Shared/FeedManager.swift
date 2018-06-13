import Foundation
import CoreLocation
import UIKit

class FeedManager : NSObject, CLLocationManagerDelegate {
    
    var locationManager: CLLocationManager!
    
    public var imagesById = NSCache<NSString, UIImage>()
    public var photoStream: [Photo] = []
    
    var searchResponse: PhotoSearchResponse? = nil
    
    var currentLocation: CLLocationCoordinate2D? = nil
    var running = false

    override init() {
    }
    
    func startFeed() {
        running = true
        
        if (locationManager == nil) {
            locationManager = CLLocationManager()
            locationManager.delegate = self
            locationManager.distanceFilter = 100;
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
        }
        
        if CLLocationManager.locationServicesEnabled(){
            locationManager.startUpdatingLocation()
        }
        else {
            locationManager.requestWhenInUseAuthorization()
        }
    }
    
    func stopFeed() {
        running = false
        currentLocation = nil
        
        locationManager.stopUpdatingLocation()
    }
    
    func getImage(_ imageId: NSString?) -> UIImage?
    {
        return imageId.flatMap { self.imagesById.object(forKey: $0) }
    }
    
    func addImage(_ id: NSString, image: UIImage)
    {
        self.imagesById.setObject(image, forKey: id)
        
        NotificationCenter.default.post(name: Notification.Name("imageLoaded"), object: nil, userInfo: ["cacheid": id])
    }
    
    func fetchImagesForLocation(lat : Double, long : Double)
    {
        print("lat, long = \(lat) \(long)")
        
        let endpoint = "https://api.flickr.com/services/rest/?method=flickr.photos.search&api_key=47731555d776634573b1ac392309a4b7&accuracy=15&lat=\(lat)&lon=\(long)&radius=1&format=json&nojsoncallback=1"
        
        let url = URL(string: endpoint)
        
        print("Querying : \(endpoint)")
        
        URLSession.shared.dataTask(with: url!) { (data, response, error) in
            
            guard let data = data else { return }
            
            do {
                
                let response = try JSONDecoder().decode(PhotoSearchResponse.self, from: data)
                
                self.searchResponse = response
                
                self.fetchRandomPhoto(searchResponse: response)
                
            } catch let jsonError {
                print("Error : \(jsonError)")
            }
            
            }.resume()
    }
    
    func fetchRandomPhoto(searchResponse: PhotoSearchResponse) {
        
        let perpage = UInt32(searchResponse.photos!.perpage!)
        
        if (perpage > 0) {
            let randomPhotoIdx = Int(arc4random_uniform(perpage - 1))
            let photo = searchResponse.photos!.photo![randomPhotoIdx]
            //let photo = searchResponse.photos!.photo![0]
            
            fetchImage(searchResponse: searchResponse, photo: photo)
        }
    }
    
    func fetchImage(searchResponse: PhotoSearchResponse, photo: Photo) {
        
        let imageCacheId = photo.getImageCacheId() as NSString
        
        if (self.getImage(imageCacheId) != nil)
        {
            NotificationCenter.default.post(name: Notification.Name("imageLoaded"), object: nil, userInfo: ["cacheid": imageCacheId])
            return
        }
        
        DispatchQueue.global(qos: .background).async {
            let photoUrl = "https://farm\(photo.farm!).staticflickr.com/\(photo.server!)/\(photo.id!)_\(photo.secret!).jpg"
            
            print("Photo URL: \(photoUrl)")
            
            let imageData = try? Data(contentsOf: URL(string: photoUrl)!)
            
            if imageData?.isEmpty != false
            {
                print("getImage \(photoUrl) - imageData is nil or empty")
                self.fetchRandomPhoto(searchResponse: searchResponse)
                return
            }
            
            if let image = imageData.flatMap({ UIImage(data: $0) })
            {
                print("getImage \(photoUrl) - Success")
                
                self.photoStream.append(photo)
                
                self.addImage(imageCacheId, image: image)
            }
            else
            {
                print("getImage \(photoUrl) - UIImage is nil")
                self.fetchRandomPhoto(searchResponse: searchResponse)
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        
        if status != .authorizedWhenInUse {
            print("Please Authorize location permission")
            return
        }
        
        locationManager.startUpdatingLocation()
    }
    
    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation])
    {
        if let location = manager.location?.coordinate {
            
            if (currentLocation?.latitude == location.latitude && currentLocation?.longitude == location.longitude) {
                return;
            }
            
            self.currentLocation = location
        
            if (self.running) {
                
                fetchImagesForLocation(lat: currentLocation!.latitude, long: currentLocation!.longitude)
            }
        }
    }
}
