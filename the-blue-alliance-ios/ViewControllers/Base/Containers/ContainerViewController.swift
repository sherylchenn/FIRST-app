import CoreData
import Foundation
import TBAData
import TBAKit
import TBAUtils
import UIKit

protocol NavigationTitleDelegate: AnyObject {
    func navigationTitleTapped()
}

protocol Navigatable {
    // Protocol to allow container views to show right bar button items in their container view
    var additionalRightBarButtonItems: [UIBarButtonItem] { get }
}

typealias ContainableViewController = UIViewController & Refreshable & Persistable & Navigatable

class ContainerViewController: UIViewController, Persistable, Alertable {

    // MARK: - Public Properties

    var navigationTitle: String? {
        didSet {
            DispatchQueue.main.async {
                self.navigationTitleLabel.text = self.navigationTitle
            }
        }
    }

    var navigationSubtitle: String? {
        didSet {
            DispatchQueue.main.async {
                self.navigationSubtitleLabel.text = self.navigationSubtitle
            }
        }
    }

    var rightBarButtonItems: [UIBarButtonItem] = [] {
        didSet {
            updateBarButtonItems()
        }
    }

    let dependencies: Dependencies
    
    // Flag to prevent network requests during initialization
    private var isInitialized = false

    var errorRecorder: ErrorRecorder {
        return dependencies.errorRecorder
    }
    var persistentContainer: NSPersistentContainer {
        return dependencies.persistentContainer
    }
    var tbaKit: TBAKit {
        return dependencies.tbaKit
    }
    var userDefaults: UserDefaults {
        return dependencies.userDefaults
    }

    // MARK: - Private View Elements

    private lazy var navigationStackView: UIStackView = {
        let navigationStackView = UIStackView(arrangedSubviews: [navigationTitleLabel, navigationSubtitleLabel])
        navigationStackView.translatesAutoresizingMaskIntoConstraints = false
        navigationStackView.axis = .vertical
        navigationStackView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(navigationTitleTapped)))
        return navigationStackView
    }()
    private lazy var navigationTitleLabel: UILabel = {
        let navigationTitleLabel = ContainerViewController.createNavigationLabel()
        navigationTitleLabel.font = UIFont.systemFont(ofSize: 17)
        return navigationTitleLabel
    }()
    private lazy var navigationSubtitleLabel: UILabel = {
        let navigationSubtitleLabel = ContainerViewController.createNavigationLabel()
        navigationSubtitleLabel.font = UIFont.systemFont(ofSize: 11)
        return navigationSubtitleLabel
    }()
    weak var navigationTitleDelegate: NavigationTitleDelegate?

    private let shouldShowSegmentedControl: Bool = false
    lazy var segmentedControlView: UIView = {
        let segmentedControlView = UIView(forAutoLayout: ())
        segmentedControlView.autoSetDimension(.height, toSize: 44.0)
        segmentedControlView.backgroundColor = UIColor.navigationBarTintColor
        segmentedControlView.addSubview(segmentedControl)
        segmentedControl.autoAlignAxis(toSuperviewAxis: .horizontal)
        segmentedControl.autoPinEdge(toSuperviewEdge: .leading, withInset: 16.0)
        segmentedControl.autoPinEdge(toSuperviewEdge: .trailing, withInset: 16.0)
        return segmentedControlView
    }()
    private var segmentedControl: UISegmentedControl

    private let containerView: UIView = UIView()
    private let viewControllers: [ContainableViewController]
    var rootStackView: UIStackView!

    private lazy var offlineEventView: UIView = {
        let offlineEventLabel = UILabel(forAutoLayout: ())
        offlineEventLabel.text = "It looks like this event hasn't posted any results recently. It's possible that the internet connection at the event is down. The event's information might be out of date."
        offlineEventLabel.textColor = UIColor.dangerDarkRed
        offlineEventLabel.numberOfLines = 0
        offlineEventLabel.textAlignment = .center
        offlineEventLabel.font = UIFont.preferredFont(forTextStyle: UIFont.TextStyle.footnote)

        let offlineEventView = UIView(forAutoLayout: ())
        offlineEventView.addSubview(offlineEventLabel)
        offlineEventLabel.autoPinEdgesToSuperviewSafeArea(with: UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8))
        offlineEventView.backgroundColor = UIColor.dangerRed
        return offlineEventView
    }()

    init(viewControllers: [ContainableViewController], navigationTitle: String? = nil, navigationSubtitle: String?  = nil, segmentedControlTitles: [String]? = nil, dependencies: Dependencies) {
        self.viewControllers = viewControllers
        self.dependencies = dependencies

        self.navigationTitle = navigationTitle
        self.navigationSubtitle = navigationSubtitle

        segmentedControl = UISegmentedControl(items: segmentedControlTitles)
        segmentedControl.selectedSegmentIndex = 0
        segmentedControl.translatesAutoresizingMaskIntoConstraints = false

        super.init(nibName: nil, bundle: nil)

        segmentedControl.addTarget(self, action: #selector(segmentedControlValueChanged), for: .valueChanged)

        if let navigationTitle = navigationTitle, let navigationSubtitle = navigationSubtitle {
            navigationTitleLabel.text = navigationTitle
            navigationSubtitleLabel.text = navigationSubtitle
            navigationItem.titleView = navigationStackView
        }

        updateBarButtonItems()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        // Remove segmentedControl if we don't need one
        var arrangedSubviews = [containerView]
        if segmentedControl.numberOfSegments > 1 {
            arrangedSubviews.insert(segmentedControlView, at: 0)
        }

        rootStackView = UIStackView(arrangedSubviews: arrangedSubviews)
        rootStackView.translatesAutoresizingMaskIntoConstraints = false
        rootStackView.axis = .vertical
        view.addSubview(rootStackView)

        // Add subviews to view hierarchy in reverse order, so first one is showing automatically
        for viewController in viewControllers.reversed() {
            addChild(viewController)
            containerView.addSubview(viewController.view)
            viewController.view.autoPinEdgesToSuperviewEdges()
            viewController.enableRefreshing()
        }

        rootStackView.autoPinEdge(toSuperviewSafeArea: .top)
        // Pin our stack view underneath the safe area to extend underneath the home bar on notch phones
        rootStackView.autoPinEdgesToSuperviewEdges(with: .zero, excludingEdge: .top)
        
        // Mark view as loaded to allow network requests
        isInitialized = true
        
        // Trigger initial data loading after a short delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            self?.triggerInitialDataLoading()
        }
    }
    
    private func triggerInitialDataLoading() {
        // Completely disable automatic data loading during initialization
        // Users can manually refresh if they need data
        // This prevents any network requests from blocking the UI
        
        // Trigger refreshes for the current view controller if needed
        // if let viewController = currentViewController() {
        //     DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
        //         if viewController.shouldRefresh() {
        //             // Set a flag to indicate we're about to refresh to prevent showing "no data" immediately
        //             if let refreshable = viewController as? Refreshable {
        //                 // Start the refresh operation
        //                 DispatchQueue.main.async {
        //                     refreshable.refresh()
        //                 }
        //             }
        //         }
        //     }
        // }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        updateSegmentedControlViews()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        // TODO: Consider... if a view is presented over top of the current view but no action is taken
        // We don't want to cancel refreshes in that situation
        // TODO: Consider only canceling if we're moving backwards or sideways in the view hierarchy, if we have
        // access to that information. Ex: Teams -> Team, we don't need to cancel the teams refresh
        // https://github.com/the-blue-alliance/the-blue-alliance-ios/issues/176
        if isMovingFromParent {
            cancelRefreshes()
        }
    }

    // MARK: - Public Methods

    public func switchedToIndex(_ index: Int) {}

    public func currentViewController() -> ContainableViewController? {
        if viewControllers.count == 1, let viewController = viewControllers.first {
            return viewController
        } else if viewControllers.count > 0, viewControllers.count > segmentedControl.selectedSegmentIndex {
            return viewControllers[segmentedControl.selectedSegmentIndex]
        }
        return nil
    }

    public static func yearSubtitle(_ year: Int?) -> String {
        if let year = year {
            return "▾ \(year)"
        } else {
            return "▾ ----"
        }
    }

    public func showOfflineEventMessage(shouldShow: Bool, animated: Bool = true) {
        if shouldShow {
            if !rootStackView.arrangedSubviews.contains(offlineEventView) {
                // Animate our down events view in
                if animated {
                    offlineEventView.isHidden = true
                }
                rootStackView.addArrangedSubview(offlineEventView)
                if animated {
                    // iOS animation timing magic number
                    UIView.animate(withDuration: 0.35) {
                        self.offlineEventView.isHidden = false
                    }
                }
            }
        } else {
            if animated {
                if rootStackView.arrangedSubviews.contains(offlineEventView) {
                    UIView.animate(withDuration: 0.35, animations: {
                        self.offlineEventView.isHidden = true
                    }, completion: { (_) in
                        self.rootStackView.removeArrangedSubview(self.offlineEventView)
                        if self.offlineEventView.superview != nil {
                            self.offlineEventView.removeFromSuperview()
                        }
                        self.offlineEventView.isHidden = false
                    })
                }
            } else {
                if rootStackView.arrangedSubviews.contains(offlineEventView) {
                    rootStackView.removeArrangedSubview(offlineEventView)
                }
                if offlineEventView.superview != nil {
                    self.offlineEventView.removeFromSuperview()
                }
            }
        }
    }

    // MARK: - Private Methods

    @objc private func segmentedControlValueChanged() {
        updateSegmentedControlViews()
    }

    private func updateSegmentedControlViews() {
        if let viewController = currentViewController() {
            show(view: viewController.view)
        }
        updateBarButtonItems()
    }

    private func show(view showView: UIView) {
        var switchedIndex = 0
        for (index, containedView) in viewControllers.compactMap({ $0.view }).enumerated() {
            let shouldHide = !(containedView == showView)
            if !shouldHide {
                let refreshViewController = viewControllers[index]

                // Reload our view on subsequent appears, since backing relationships
                // for objects might have changed while the view is in the background.
                // This can mean our view state falls out of sync with our data state while backgrounded.
                // Kickoff a reload to make sure our states match up.
                reloadViewController(refreshViewController)

                // Completely disable automatic refreshes during initialization
                // Only allow manual refreshes (pull-to-refresh) to prevent blocking
                // if isInitialized {
                //     // Add a delay to prevent immediate network requests during initialization
                //     DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                //         if refreshViewController.shouldRefresh() {
                //             // Make refresh asynchronous to not block UI when switching views
                //             DispatchQueue.main.async {
                //                 refreshViewController.refresh()
                //             }
                //         }
                //     }
                // }
                switchedIndex = index
            }
            containedView.isHidden = shouldHide
        }
        switchedToIndex(switchedIndex)
    }

    private func updateBarButtonItems() {
        var rightBarButtonItems: [UIBarButtonItem] = self.rightBarButtonItems
        if let viewController = currentViewController() {
            rightBarButtonItems.append(contentsOf: viewController.additionalRightBarButtonItems)
        }
        navigationItem.setRightBarButtonItems(rightBarButtonItems, animated: false)
    }

    private func reloadViewController(_ viewController: UIViewController) {
        if let viewController = viewController as? TBAViewController {
            viewController.reloadData()
        } else if let viewController = viewController as? UITableViewController {
            viewController.tableView.reloadData()
        } else if let viewController = viewController as? UICollectionViewController {
            viewController.collectionView.reloadData()
        }
    }

    private func cancelRefreshes() {
        viewControllers.forEach {
            $0.cancelRefresh()
        }
    }

    @objc private func navigationTitleTapped() {
        navigationTitleDelegate?.navigationTitleTapped()
    }

    // MARK: - Helper Methods

    private static func createNavigationLabel() -> UILabel {
        let label = UILabel(forAutoLayout: ())
        label.textColor = UIColor.white
        label.textAlignment = .center
        return label
    }

}
