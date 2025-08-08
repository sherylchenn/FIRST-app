import Foundation
import UIKit

struct GrantCellViewModel {
    let name: String
    let status: String
    let statusColor: UIColor
    let dateText: String
    let requirementsText: String
    
    init(grant: Grant) {
        name = grant.name
        status = grant.status.displayName
        statusColor = grant.status.color
        dateText = grant.dateText
        requirementsText = grant.requirementsText
    }
} 