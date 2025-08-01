import CoreData
import MyTBAKit
import Search
import TBAKit
import UIKit

private enum SettingsSection: Int, CaseIterable {
    case icons
    case debug
}

private enum DebugRow: Int, CaseIterable {
    case deleteNetworkCache
    case deleteSearchIndex
    case troubleshootNotifications
}

class SettingsViewController: TBATableViewController {

    private let fcmTokenProvider: FCMTokenProvider
    private let myTBA: MyTBA
    private let pushService: PushService
    private let searchService: SearchService
    private let urlOpener: URLOpener

    // MARK: - Init

    init(fcmTokenProvider: FCMTokenProvider, myTBA: MyTBA, pushService: PushService, searchService: SearchService, urlOpener: URLOpener, dependencies: Dependencies) {
        self.fcmTokenProvider = fcmTokenProvider
        self.myTBA = myTBA
        self.pushService = pushService
        self.searchService = searchService
        self.urlOpener = urlOpener

        super.init(style: .grouped, dependencies: dependencies)

        title = RootType.settings.title
        tabBarItem.image = RootType.settings.icon

        hidesBottomBarWhenPushed = false
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.registerReusableCell(IconTableViewCell.self)
    }

    // MARK: - Private Methods

    private func normalizedSection(_ section: Int) -> SettingsSection? {
        var section = section
        if !UIApplication.shared.supportsAlternateIcons, section >= SettingsSection.icons.rawValue {
            section += 1
        }
        return SettingsSection(rawValue: section)!
    }

    // MARK: - Table View Data Source

    override func numberOfSections(in tableView: UITableView) -> Int {
        var sections = SettingsSection.allCases.count
        // Remove our Icons section if they're not supported
        if !UIApplication.shared.supportsAlternateIcons {
            sections -= 1
        }
        return sections
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Remove our Icons section if they're not supported
        guard let section = normalizedSection(section) else {
            return 0
        }

        switch section {
        case .icons:
            return alternateAppIcons.count + 1 // +1 for default icon
        case .debug:
            return DebugRow.allCases.count
        }
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        guard let section = normalizedSection(section) else {
            return nil
        }

        switch section {
        case .icons:
            return "App Icon"
        case .debug:
            return "Debug"
        }
    }

    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        guard let section = normalizedSection(section) else {
            return nil
        }
        guard section == .debug else {
            return nil
        }
        return "The Blue Alliance for iOS - \(Bundle.main.displayVersionString)"
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let section = normalizedSection(indexPath.section) else {
            fatalError("This section does not exist")
        }

        switch section {
        case .icons:
            let cell = tableView.dequeueReusableCell(indexPath: indexPath) as IconTableViewCell

            let viewModel: IconCellViewModel = {
                if indexPath.row == 0 {
                    return IconCellViewModel(name: "The Blue Alliance", imageName: primaryAppIconName ?? "AppIcon")
                } else {
                    let alternateName = Array(alternateAppIcons.keys)[indexPath.row - 1]
                    guard let alternateIconName = alternateAppIcons[alternateName] else {
                        fatalError("Unable to find alternate icon for \(alternateName)")
                    }
                    return IconCellViewModel(name: alternateName, imageName: alternateIconName)
                }
            }()

            cell.viewModel = viewModel

            // Show currently-selected app icon
            if isCurrentAppIcon(viewModel.name) || (isCurrentAppIcon(nil) && indexPath.row == 0) {
                cell.accessoryType = .checkmark
            } else {
                cell.accessoryType = .none
            }

            return cell
        case .debug:
            let cell = UITableViewCell(style: .default, reuseIdentifier: nil)

            let debugRow = DebugRow.allCases[indexPath.row]
            let titleString: String = {
                switch debugRow {
                case .deleteNetworkCache:
                    return "Delete network cache"
                case .deleteSearchIndex:
                    return "Delete search index"
                case .troubleshootNotifications:
                    return "Troubleshoot notifications"
                }
            }()

            cell.accessoryType = .disclosureIndicator
            cell.textLabel?.text = titleString
            return cell
        }
    }

    // MARK: - Table View Delegate

    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        // Override so we don't get colored headers
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        guard let section = normalizedSection(indexPath.section) else {
            fatalError("This section does not exist")
        }

        switch section {
        case .icons:
            if indexPath.row == 0 {
                setDefaultAppIcon()
            } else {
                let alternateName = Array(alternateAppIcons.keys)[indexPath.row - 1]
                setAlternateAppIcon(alternateName)
            }
        case .debug:
            let debugRow = DebugRow.allCases[indexPath.row]
            switch debugRow {
            case .deleteNetworkCache:
                showDeleteNetworkCache()
            case .deleteSearchIndex:
                showDeleteSearchIndex()
            case .troubleshootNotifications:
                pushTroubleshootNotifications()
            }
        }
    }

    // MARK: - Private Methods

    // MARK: - Icons Methods

    /**
     Check if the current app icon is the same as the passed app icon name.

     Used to show which app icon we currently have set.
    */
    private func isCurrentAppIcon(_ icon: String?) -> Bool {
        return icon == UIApplication.shared.alternateIconName
    }

    private var primaryAppIconName: String? {
        guard let iconsDictionary = Bundle.main.infoDictionary?["CFBundleIcons"] as? [String:Any],
            let primaryIconsDictionary = iconsDictionary["CFBundlePrimaryIcon"] as? [String:Any],
            let iconFiles = primaryIconsDictionary["CFBundleIconFiles"] as? [String],
            let lastIcon = iconFiles.last else { return nil }
        return lastIcon
    }

    /*
     Key is the name, value is the image name.
    */
    private lazy var alternateAppIcons: [String: String] = {
        guard let iconsDictionary = Bundle.main.infoDictionary?["CFBundleIcons"] as? [String:Any],
            let alternateIconsDictionary = iconsDictionary["CFBundleAlternateIcons"] as? [String:Any] else { return [:] }

        var alternateAppIcons: [String: String] = [:]
        alternateIconsDictionary.forEach({ (key, value) in
            guard let iconDictionary = value as? [String:Any],
                let iconFiles = iconDictionary["CFBundleIconFiles"] as? [String],
                let lastIcon = iconFiles.last else { return }
            alternateAppIcons[key] = lastIcon
        })
        return alternateAppIcons
    }()

    private func setDefaultAppIcon() {
        // Only change icons if it's supported by the OS
        guard UIApplication.shared.supportsAlternateIcons else {
            return
        }

        // Only set the default app icon if we have an alternate icon set
        guard UIApplication.shared.alternateIconName != nil else {
            return
        }

        UIApplication.shared.setAlternateIconName(nil, completionHandler: { _ in
            self.reloadIconsSection()
        })
    }

    private func setAlternateAppIcon(_ alternateName: String) {
        // Only change icons if it's supported by the OS
        guard UIApplication.shared.supportsAlternateIcons else {
            return
        }

        // Only set the the alternate icon if it's different from the icon we have currently set
        guard UIApplication.shared.alternateIconName != alternateName else {
            return
        }

        UIApplication.shared.setAlternateIconName(alternateName, completionHandler: { _ in
            self.reloadIconsSection()
        })
    }

    private func reloadIconsSection() {
        DispatchQueue.main.async {
            self.tableView.reloadSections(IndexSet(integer: SettingsSection.icons.rawValue), with: .automatic)
        }
    }

    // MARK: - Debug Methods

    private func showDeleteNetworkCache() {
        let alertController = UIAlertController(title: "Delete Network Cache", message: "Are you sure you want to delete all the network cache data?", preferredStyle: .alert)

        let deleteCacheAction = UIAlertAction(title: "Delete", style: .destructive) { [unowned self] (deleteAction) in
            self.tbaKit.clearCacheHeaders()
            self.userDefaults.clearSuccessfulRefreshes()
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)

        alertController.addAction(deleteCacheAction)
        alertController.addAction(cancelAction)

        self.present(alertController, animated: true, completion: nil)
    }

    private func showDeleteSearchIndex() {
        let alertController = UIAlertController(title: "Delete Search Index", message: "Are you sure you want to delete the local search index? Search may not work properly.", preferredStyle: .alert)

        let deleteCacheAction = UIAlertAction(title: "Delete", style: .destructive) { [unowned self] (deleteAction) in
            self.searchService.deleteSearchIndex(errorRecorder: errorRecorder)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)

        alertController.addAction(deleteCacheAction)
        alertController.addAction(cancelAction)

        self.present(alertController, animated: true, completion: nil)
    }

    private func pushTroubleshootNotifications() {
        let notificationsViewController = NotificationsViewController(fcmTokenProvider: fcmTokenProvider, myTBA: myTBA, pushService: pushService, urlOpener: urlOpener, dependencies: dependencies)
        navigationController?.pushViewController(notificationsViewController, animated: true)
    }

}
