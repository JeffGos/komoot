import UIKit
import CoreLocation
import UserNotifications

class MainViewController: UIViewController  {
    
    private var startStopButton: UIButton
    private var tableView: UITableView;
    
    private var feedManager = FeedManager()
    
    var running = false
    
    required init?(coder aDecoder: NSCoder) {
        
        startStopButton = UIButton(frame: CGRect(x: 0, y: 0, width: 0, height: CGFloat.leastNormalMagnitude))
        startStopButton.backgroundColor = UIColor.darkGray
        startStopButton.setTitle("Start", for: .normal)
        
        tableView = UITableView(frame: CGRect(x: 0, y: 0, width: 0, height: CGFloat.leastNormalMagnitude), style: .grouped)
        
        tableView.backgroundColor = UIColor.blue
        
        tableView.register(ImageListViewCell.self, forCellReuseIdentifier: ImageListViewCell.cellReuseIdentifier)
        
        super.init(coder: aDecoder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(startStopButton)
        view.addSubview(tableView)
        
        startStopButton.addTarget(self, action: #selector(self.onStartStopButtonTapped),for: .touchUpInside)
        
        startStopButton.translatesAutoresizingMaskIntoConstraints = false
        startStopButton.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        startStopButton.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        startStopButton.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        startStopButton.heightAnchor.constraint(equalToConstant: 100).isActive = true
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        tableView.topAnchor.constraint(equalTo: startStopButton.bottomAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
        tableView.dataSource = self
        
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
                    self?.tableView.reloadData()
                }
        })
    }
    
    @objc public func onStartStopButtonTapped(sender: UIButton!) {
        running = !running
        startStopButton.setTitle(running ? "Stop" : "Start", for: .normal)
        
        if (running) {
            feedManager.startFeed()
        }
        else {
            feedManager.stopFeed()
        }
    }
}

extension MainViewController : UITableViewDataSource {
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return feedManager.photoStream.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let titleCell = tableView.dequeueReusableCell(withIdentifier: ImageListViewCell.cellReuseIdentifier) as! ImageListViewCell
        
        let index = feedManager.photoStream.count - 1 - indexPath.row
        let item = feedManager.photoStream[index]

        titleCell.textLabel?.text = "\(index) - \(item.title!)"

        titleCell.cache = feedManager.imagesById
        titleCell.photo = item

        if let searchResponse = feedManager.searchResponse {
            feedManager.fetchImage(searchResponse: searchResponse, photo: item)
        }
        
        return titleCell
    }
}


