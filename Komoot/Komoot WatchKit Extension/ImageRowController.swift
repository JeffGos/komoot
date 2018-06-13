import WatchKit

class ImageRowController: NSObject {
    
    @IBOutlet var image: WKInterfaceImage!
    
    var imageAsset: UIImage? = nil {
        didSet {
            
            if let image = imageAsset
            {
                self.image?.setImage(image)
            }
        }
    }
}
