import Foundation
import UIKit

class ImageListViewCell: UITableViewCell
{
    static let verticalPadding = CGFloat(20)
    static let horizontalPadding = CGFloat(16)
    static let insets = UIEdgeInsets(top: CGFloat(16), left: CGFloat(16), bottom: CGFloat(16), right: CGFloat(16))
    
    class var cellReuseIdentifier: String { return "ImageListViewCell" }
    class var cellHeight: CGFloat { return 400 }
    
    public var cache: NSCache<NSString, UIImage>?
    public var photo: Photo?
    
    required override init(style: UITableViewCellStyle, reuseIdentifier: String?)
    {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.setup()
    }
    
    required init?(coder: NSCoder)
    {
        super.init(coder: coder)
        self.setup()
    }
    
    internal func setup()
    {
        self.backgroundColor = nil
        self.isOpaque = false
        
        var observer: Any? = nil
        
        observer = NotificationCenter.default.addObserver(forName: Notification.Name("imageLoaded"), object: nil, queue: OperationQueue.main, using:
            {
            
            [weak self] notification in
                
                if self == nil
                {
                    if let obs = observer
                    {
                        NotificationCenter.default.removeObserver(obs)
                        observer = nil
                    }
                    return
                }
                
                if let cacheId = notification.userInfo?["cacheid"] as? String
                {
                    if let photoCacheId = self!.photo?.getImageCacheId() {
                        if (cacheId == photoCacheId) {
                            if let image = self?.cache!.object(forKey: cacheId as NSString) {
                                self?.imageView?.image = image
                            }
                        }
                    }
                }
            })
    }
}
