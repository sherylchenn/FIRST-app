import CoreData
import Foundation
import TBAData
import TBAKit
import TBAUtils
import UIKit

class GrantsContainerViewController: ContainerViewController {
    
    private let urlOpener: URLOpener
    
    private var grantsViewController: GrantsViewController!
    
    // MARK: - Init
    init(urlOpener: URLOpener, dependencies: Dependencies) {
        self.urlOpener = urlOpener
        
        // Create the grants view controller first
        let grantsVC = GrantsViewController(dependencies: dependencies)
        
        // Call super.init with the proper parameters
        super.init(viewControllers: [grantsVC], 
                  navigationTitle: "Grants", 
                  dependencies: dependencies)
        
        // Store reference to the grants view controller
        self.grantsViewController = grantsVC
        self.grantsViewController.delegate = self
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Grants"
    }
}

// MARK: - GrantsViewControllerDelegate
extension GrantsContainerViewController: GrantsViewControllerDelegate {
    func grantSelected(_ grant: Grant) {
        // Open the application link
        if let url = URL(string: grant.applicationLink) {
            urlOpener.open(url, options: [:], completionHandler: nil)
        }
    }
} 
