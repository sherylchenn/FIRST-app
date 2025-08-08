import CoreData
import Foundation
import TBAData
import TBAKit
import TBAUtils
import UIKit

class GrantFilterViewController: TBATableViewController {
    
    private let currentFilters: GrantFilters
    private let completion: (GrantFilters) -> Void
    
    // Filter states
    private var statusFilter: Grant.GrantStatus?
    private var employeeFilter: Bool?
    private var c501c3Filter: Bool?
    
    // MARK: - Init
    init(currentFilters: GrantFilters, dependencies: Dependencies, completion: @escaping (GrantFilters) -> Void) {
        self.currentFilters = currentFilters
        self.completion = completion
        
        super.init(style: .grouped, dependencies: dependencies)
        
        // Initialize with current filters
        statusFilter = currentFilters.status
        employeeFilter = currentFilters.requiresEmployee
        c501c3Filter = currentFilters.requires501c3
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Filter Grants"
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, 
                                                          target: self, 
                                                          action: #selector(cancelTapped))
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, 
                                                           target: self, 
                                                           action: #selector(doneTapped))
    }
    
    // MARK: - Actions
    @objc private func cancelTapped() {
        dismiss(animated: true)
    }
    
    @objc private func doneTapped() {
        let filters = GrantFilters(status: statusFilter, 
                                  requiresEmployee: employeeFilter, 
                                  requires501c3: c501c3Filter)
        completion(filters)
        dismiss(animated: true)
    }
    
    // MARK: - UITableViewDataSource
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0: // Status
            return Grant.GrantStatus.allCases.count + 1 // +1 for "All"
        case 1: // Employee Requirement
            return 3 // All, Yes, No
        case 2: // 501c3 Requirement
            return 3 // All, Yes, No
        default:
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return "Status"
        case 1:
            return "Employee Requirement"
        case 2:
            return "501(c)(3) Requirement"
        default:
            return nil
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
        
        switch indexPath.section {
        case 0: // Status
            if indexPath.row == 0 {
                cell.textLabel?.text = "All"
                cell.accessoryType = statusFilter == nil ? .checkmark : .none
            } else {
                let status = Grant.GrantStatus.allCases[indexPath.row - 1]
                cell.textLabel?.text = status.displayName
                cell.accessoryType = statusFilter == status ? .checkmark : .none
            }
            
        case 1: // Employee Requirement
            switch indexPath.row {
            case 0:
                cell.textLabel?.text = "All"
                cell.accessoryType = employeeFilter == nil ? .checkmark : .none
            case 1:
                cell.textLabel?.text = "Required"
                cell.accessoryType = employeeFilter == true ? .checkmark : .none
            case 2:
                cell.textLabel?.text = "Not Required"
                cell.accessoryType = employeeFilter == false ? .checkmark : .none
            default:
                break
            }
            
        case 2: // 501c3 Requirement
            switch indexPath.row {
            case 0:
                cell.textLabel?.text = "All"
                cell.accessoryType = c501c3Filter == nil ? .checkmark : .none
            case 1:
                cell.textLabel?.text = "Required"
                cell.accessoryType = c501c3Filter == true ? .checkmark : .none
            case 2:
                cell.textLabel?.text = "Not Required"
                cell.accessoryType = c501c3Filter == false ? .checkmark : .none
            default:
                break
            }
            
        default:
            break
        }
        
        return cell
    }
    
    // MARK: - UITableViewDelegate
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        switch indexPath.section {
        case 0: // Status
            if indexPath.row == 0 {
                statusFilter = nil
            } else {
                statusFilter = Grant.GrantStatus.allCases[indexPath.row - 1]
            }
            
        case 1: // Employee Requirement
            switch indexPath.row {
            case 0:
                employeeFilter = nil
            case 1:
                employeeFilter = true
            case 2:
                employeeFilter = false
            default:
                break
            }
            
        case 2: // 501c3 Requirement
            switch indexPath.row {
            case 0:
                c501c3Filter = nil
            case 1:
                c501c3Filter = true
            case 2:
                c501c3Filter = false
            default:
                break
            }
            
        default:
            break
        }
        
        tableView.reloadData()
    }
} 