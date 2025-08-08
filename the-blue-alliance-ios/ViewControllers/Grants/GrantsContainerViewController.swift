import CoreData
import Foundation
import TBAData
import TBAKit
import TBAUtils
import UIKit

class GrantsContainerViewController: ContainerViewController {
    
    private let urlOpener: URLOpener
    private let dependencies: Dependencies
    
    private var grantsViewController: GrantsViewController!
    
    // MARK: - Init
    init(urlOpener: URLOpener, dependencies: Dependencies) {
        self.urlOpener = urlOpener
        self.dependencies = dependencies
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Grants"
        
        setupGrantsViewController()
    }
    
    // MARK: - Setup
    private func setupGrantsViewController() {
        grantsViewController = GrantsViewController(dependencies: dependencies)
        grantsViewController.delegate = self
        
        addChild(grantsViewController)
        view.addSubview(grantsViewController.view)
        grantsViewController.didMove(toParent: self)
        
        // Set up constraints
        grantsViewController.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            grantsViewController.view.topAnchor.constraint(equalTo: view.topAnchor),
            grantsViewController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            grantsViewController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            grantsViewController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
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