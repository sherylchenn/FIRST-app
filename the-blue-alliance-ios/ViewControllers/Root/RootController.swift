import CoreData
import Foundation
import MyTBAKit
import Photos
import TBAData
import TBAKit
import UIKit

protocol RootChildController {
    var rootType: RootType { get }
}

enum RootType: Int, CaseIterable {
    case events = 0
    case teams = 1
    case districts = 2
    case grants = 3
    case more = 4
    case myTBA = 5
    case settings = 6

    var title: String {
        switch self {
        case .events:
            return "Events"
        case .teams:
            return "Teams"
        case .districts:
            return "Districts"
        case .more:
            return "More"
        case .grants:
            return "Grants"
        case .myTBA:
            return "myTBA"
        case .settings:
            return "Settings"
        }
    }

    var icon: UIImage? {
        switch self {
        case .events:
            return UIImage.eventIcon
        case .teams:
            return UIImage.teamIcon
        case .districts:
            return UIImage.districtIcon
        case .more:
            return UIImage(systemName: "ellipsis.circle")
        case .grants:
            return UIImage(systemName: "dollarsign.circle")
        case .myTBA:
            return UIImage.starIcon
        case .settings:
            return UIImage.settingsIcon
        }
    }

    var supportsPush: Bool {
        switch self {
        case .events, .teams, .districts, .grants:
            return true
        case .more, .myTBA, .settings:
            return false
        }
    }

}

protocol RootController {
    var fcmTokenProvider: FCMTokenProvider { get }
    var myTBA: MyTBA { get }
    var pasteboard: UIPasteboard? { get }
    var photoLibrary: PHPhotoLibrary? { get }
    var pushService: PushService { get }
    var searchService: SearchService { get }
    var urlOpener: URLOpener { get }
    var statusService: StatusService { get }
    var dependencies: Dependencies { get }

    // MARK: - Handoff Methods
    func continueSearch(_ searchText: String) -> Bool

    func show(event: Event) -> Bool
    func show(team: Team) -> Bool
}

extension RootController {

    var eventsViewController: EventsContainerViewController {
        return EventsContainerViewController(myTBA: myTBA,
                                             pasteboard: pasteboard,
                                             photoLibrary: photoLibrary,
                                             searchService: searchService,
                                             statusService: statusService,
                                             urlOpener: urlOpener,
                                             dependencies: dependencies)
    }

    var teamsViewController: TeamsContainerViewController {
        return TeamsContainerViewController(myTBA: myTBA,
                                            pasteboard: pasteboard,
                                            photoLibrary: photoLibrary,
                                            searchService: searchService,
                                            statusService: statusService,
                                            urlOpener: urlOpener,
                                            dependencies: dependencies)
    }

    var districtsViewController: DistrictsContainerViewController {
        return DistrictsContainerViewController(myTBA: myTBA,
                                                statusService: statusService,
                                                urlOpener: urlOpener,
                                                dependencies: dependencies)
    }

    var grantsViewController: GrantsContainerViewController {
        return GrantsContainerViewController(urlOpener: urlOpener,
                                             dependencies: dependencies)
    }

    var settingsViewController: SettingsViewController {
        return SettingsViewController(fcmTokenProvider: fcmTokenProvider,
                                      myTBA: myTBA,
                                      pushService: pushService,
                                      searchService: searchService,
                                      urlOpener: urlOpener,
                                      dependencies: dependencies)
    }

    var myTBAViewController: MyTBAViewController {
        return MyTBAViewController(myTBA: myTBA,
                                   pasteboard: pasteboard,
                                   photoLibrary: photoLibrary,
                                   statusService: statusService,
                                   urlOpener: urlOpener,
                                   dependencies: dependencies)
    }

}
