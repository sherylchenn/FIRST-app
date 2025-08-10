import CoreData
import Foundation
import MyTBAKit
import Photos
import TBAData
import TBAKit
import UIKit

class PhoneMoreViewController: TBATableViewController {
    
    // MARK: - Properties
    
    private let fcmTokenProvider: FCMTokenProvider
    private let myTBA: MyTBA
    private let pasteboard: UIPasteboard?
    private let photoLibrary: PHPhotoLibrary?
    private let pushService: PushService
    private let searchService: SearchService
    private let statusService: StatusService
    private let urlOpener: URLOpener
    
    private var moreOptions: [MoreOption] = []
    
    // MARK: - Init
    
    init(fcmTokenProvider: FCMTokenProvider, myTBA: MyTBA, pasteboard: UIPasteboard? = nil, photoLibrary: PHPhotoLibrary? = nil, pushService: PushService, searchService: SearchService, statusService: StatusService, urlOpener: URLOpener, dependencies: Dependencies) {
        self.fcmTokenProvider = fcmTokenProvider
        self.myTBA = myTBA
        self.pasteboard = pasteboard
        self.photoLibrary = photoLibrary
        self.pushService = pushService
        self.searchService = searchService
        self.statusService = statusService
        self.urlOpener = urlOpener
        
        super.init(dependencies: dependencies)
        
        // Set tab bar item properties immediately
        title = "More"
        tabBarItem.image = UIImage(systemName: "ellipsis.circle")
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Register cell
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "MoreOptionCell")
        
        setupMoreOptions()
    }
    
    // MARK: - Private Methods
    
    private func setupMoreOptions() {
        moreOptions = [
            MoreOption(title: "myTBA", icon: UIImage(systemName: "star.fill"), type: .myTBA),
            MoreOption(title: "Settings", icon: UIImage(systemName: "gear"), type: .settings)
        ]
    }
    

    
    // MARK: - Table View Data Source
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return moreOptions.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MoreOptionCell", for: indexPath)
        let option = moreOptions[indexPath.row]
        
        cell.textLabel?.text = option.title
        cell.imageView?.image = option.icon
        cell.accessoryType = .disclosureIndicator
        
        return cell
    }
    
    // MARK: - Table View Delegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let option = moreOptions[indexPath.row]
        
        switch option.type {
        case .myTBA:
            let myTBAViewController = MyTBAViewController(myTBA: myTBA, pasteboard: pasteboard, photoLibrary: photoLibrary, statusService: statusService, urlOpener: urlOpener, dependencies: self.dependencies)
            navigationController?.pushViewController(myTBAViewController, animated: true)
            
        case .settings:
            let settingsViewController = SettingsViewController(fcmTokenProvider: fcmTokenProvider, myTBA: myTBA, pushService: pushService, searchService: searchService, urlOpener: urlOpener, dependencies: self.dependencies)
            navigationController?.pushViewController(settingsViewController, animated: true)
        }
    }
}

// MARK: - MoreOption

private struct MoreOption {
    let title: String
    let icon: UIImage?
    let type: MoreOptionType
}

private enum MoreOptionType {
    case myTBA
    case settings
} 