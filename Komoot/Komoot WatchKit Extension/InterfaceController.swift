import WatchKit
import Foundation
import UserNotifications

class InterfaceController: WKInterfaceController {
    
    @IBOutlet var startStopButton: WKInterfaceButton!
    @IBOutlet var imageTable: WKInterfaceTable!
    
    var running = false
    var feedManager = FeedManager()
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
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
                
                DispatchQueue.main.async {
                    self?.reloadData()
                }
        })
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
    
    func reloadData() {
        
        imageTable.setNumberOfRows(feedManager.photoStream.count, withRowType: "ImageRow")
        
        for index in 0..<imageTable.numberOfRows {
            
            let idx = imageTable.numberOfRows - 1 - index
            
            guard let controller = imageTable.rowController(at: index) as? ImageRowController else { continue }
            
            let imageCacheId = feedManager.photoStream[idx].getImageCacheId()
            
            controller.imageAsset = feedManager.getImage(imageCacheId as NSString)
        }
    }
    
    @IBAction func onStartStopButtonTapped() {
        running = !running
        startStopButton.setTitle(running ? "Stop" : "Start")
        
        if (running) {
            feedManager.startFeed()
        }
        else {
            feedManager.stopFeed()
        }
    }
}
