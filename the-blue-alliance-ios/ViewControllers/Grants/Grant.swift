import Foundation
import UIKit

struct Grant {
    let name: String
    let applicationLink: String
    let status: GrantStatus
    let openDate: String?
    let closeDate: String?
    let requiresEmployee: Bool?
    let requires501c3: Bool?
    
    enum GrantStatus: String, CaseIterable {
        case open = "Open"
        case closed = "Closed"
        case unsure = "Unsure"
        
        var displayName: String {
            return rawValue
        }
        
        var color: UIColor {
            switch self {
            case .open:
                return UIColor.systemGreen
            case .closed:
                return UIColor.systemRed
            case .unsure:
                return UIColor.systemOrange
            }
        }
    }
    
    init(name: String, applicationLink: String, status: GrantStatus, openDate: String?, closeDate: String?, requiresEmployee: Bool?, requires501c3: Bool?) {
        self.name = name
        self.applicationLink = applicationLink
        self.status = status
        self.openDate = openDate
        self.closeDate = closeDate
        self.requiresEmployee = requiresEmployee
        self.requires501c3 = requires501c3
    }
    
    // Helper computed properties
    var isOpen: Bool {
        return status == .open
    }
    
    var isClosed: Bool {
        return status == .closed
    }
    
    var hasEmployeeRequirement: Bool {
        return requiresEmployee == true
    }
    
    var has501c3Requirement: Bool {
        return requires501c3 == true
    }
    
    var requirementsText: String {
        var requirements: [String] = []
        
        if hasEmployeeRequirement {
            requirements.append("Employee Required")
        }
        
        if has501c3Requirement {
            requirements.append("501(c)(3) Required")
        }
        
        if requirements.isEmpty {
            return "No Special Requirements"
        }
        
        return requirements.joined(separator: ", ")
    }
    
    var dateText: String {
        if let closeDate = closeDate, closeDate != "No" && closeDate != "Unsure" {
            return "Closes: \(closeDate)"
        } else if let openDate = openDate, openDate != "No" && openDate != "Unsure" {
            return "Opens: \(openDate)"
        } else {
            return "No Date Available"
        }
    }
}

// Sample data based on the spreadsheet
extension Grant {
    static let sampleGrants: [Grant] = [
        Grant(name: "BAE Grant", 
              applicationLink: "https://www.baesystems.com/en-us/partnership/community-investment/community-investment-partners/first/first-team-grants-application", 
              status: .open, 
              openDate: "September 13", 
              closeDate: "No", 
              requiresEmployee: false, 
              requires501c3: false),
        
        Grant(name: "Boeing FIRST Grant", 
              applicationLink: "https://usfirst.submittable.com/submit/298791/2024-2025-boeing-team-grant-application", 
              status: .closed, 
              openDate: "Yes", 
              closeDate: "Unsure", 
              requiresEmployee: true, 
              requires501c3: nil),
        
        Grant(name: "Con Edison", 
              applicationLink: "https://www.coned.com/en/community-affairs/strategic-partnerships/apply-for-a-grant", 
              status: .closed, 
              openDate: "June 30", 
              closeDate: "No", 
              requiresEmployee: true, 
              requires501c3: nil),
        
        Grant(name: "Gene Haas", 
              applicationLink: "https://webportalapp.com/sp/login/ghf_first_sae_competitions", 
              status: .open, 
              openDate: "No", 
              closeDate: "Yes", 
              requiresEmployee: false, 
              requires501c3: false),
        
        Grant(name: "Canon USA", 
              applicationLink: "https://canonusa.allegiancetech.com/cgi-bin/qwebcorporate.dll?9JXBU6", 
              status: .open, 
              openDate: "No", 
              closeDate: "Yes", 
              requiresEmployee: false, 
              requires501c3: false),
        
        Grant(name: "Costco", 
              applicationLink: "https://www.costco.com/charitable-giving-faq.html", 
              status: .open, 
              openDate: "No", 
              closeDate: "Yes", 
              requiresEmployee: false, 
              requires501c3: false),
        
        Grant(name: "Dow", 
              applicationLink: "https://corporate.dow.com/en-us/about/partnerships/citizenship/tomorrows-innovators/first-robotics.html", 
              status: .open, 
              openDate: "August 12", 
              closeDate: "Unsure", 
              requiresEmployee: nil, 
              requires501c3: nil),
        
        Grant(name: "Ecolab", 
              applicationLink: "https://www.ecolab.com/corporate-responsibility/social/community-involvement", 
              status: .open, 
              openDate: "August 11", 
              closeDate: "Unsure", 
              requiresEmployee: nil, 
              requires501c3: nil),
        
        Grant(name: "Fabworks", 
              applicationLink: "https://www.fabworks.com/resources/partnerships/sponsorshipinfo", 
              status: .open, 
              openDate: "No", 
              closeDate: "No", 
              requiresEmployee: false, 
              requires501c3: false),
        
        Grant(name: "Grants.gov", 
              applicationLink: "https://www.grants.gov/", 
              status: .open, 
              openDate: "Unsure", 
              closeDate: "Unsure", 
              requiresEmployee: false, 
              requires501c3: false)
    ]
} 