import CoreData
import Foundation
import TBAData
import TBAKit
import TBAUtils
import UIKit

protocol GrantsViewControllerDelegate: AnyObject {
    func grantSelected(_ grant: Grant)
}

class GrantsViewController: TBATableViewController {
    
    weak var delegate: GrantsViewControllerDelegate?
    
    private var grants: [Grant] = []
    private var filteredGrants: [Grant] = []
    
    // Filter states
    private var statusFilter: Grant.GrantStatus? = nil
    private var employeeFilter: Bool? = nil
    private var c501c3Filter: Bool? = nil
    
    // MARK: - Init
    init(dependencies: Dependencies) {
        super.init(style: .plain, dependencies: dependencies)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Grants"
        
        // Load sample data
        grants = Grant.sampleGrants
        filteredGrants = grants
        
        setupTableView()
        setupNavigationBar()
    }
    
    // MARK: - Setup
    private func setupTableView() {
        // Register the cell
        tableView.registerReusableCell(GrantTableViewCell.self)
        
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 80
        
        // DataSource is already set in TBATableViewController
        // Delegate is already set in TBATableViewController
    }
    
    private func setupNavigationBar() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "line.3.horizontal.decrease.circle"), 
                                                           style: .plain, 
                                                           target: self, 
                                                           action: #selector(showFilters))
    }
    
    // MARK: - Actions
    @objc private func showFilters() {
        let filterViewController = GrantFilterViewController(currentFilters: getCurrentFilters(), dependencies: dependencies, completion: { [weak self] filters in
            self?.applyFilters(filters)
        })
        
        let nav = UINavigationController(rootViewController: filterViewController)
        nav.modalPresentationStyle = .formSheet
        
        present(nav, animated: true)
    }
    
    // MARK: - Filtering
    private func getCurrentFilters() -> GrantFilters {
        return GrantFilters(status: statusFilter, 
                           requiresEmployee: employeeFilter, 
                           requires501c3: c501c3Filter)
    }
    
    private func applyFilters(_ filters: GrantFilters) {
        statusFilter = filters.status
        employeeFilter = filters.requiresEmployee
        c501c3Filter = filters.requires501c3
        
        filteredGrants = grants.filter { grant in
            // Status filter
            if let statusFilter = statusFilter, grant.status != statusFilter {
                return false
            }
            
            // Employee requirement filter
            if let employeeFilter = employeeFilter, grant.hasEmployeeRequirement != employeeFilter {
                return false
            }
            
            // 501c3 requirement filter
            if let c501c3Filter = c501c3Filter, grant.has501c3Requirement != c501c3Filter {
                return false
            }
            
            return true
        }
        
        tableView.reloadData()
    }
    
    // MARK: - UITableViewDataSource
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredGrants.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Safety check to prevent crashes
        guard indexPath.row < filteredGrants.count else {
            // Return a default cell if index is out of bounds
            let cell = UITableViewCell(style: .default, reuseIdentifier: "DefaultCell")
            cell.textLabel?.text = "Error loading grant"
            return cell
        }
        
        let cell = tableView.dequeueReusableCell(indexPath: indexPath) as GrantTableViewCell
        let grant = filteredGrants[indexPath.row]
        
        // Configure cell safely
        cell.viewModel = GrantCellViewModel(grant: grant)
        
        return cell
    }
    
    // MARK: - UITableViewDelegate
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        // Safety check to prevent crashes
        guard indexPath.row < filteredGrants.count else {
            return
        }
        
        let grant = filteredGrants[indexPath.row]
        
        delegate?.grantSelected(grant)
    }
}

// MARK: - Refreshable (Minimal implementation)
extension GrantsViewController: Refreshable {
    
    var refreshKey: String? {
        return nil
    }
    
    var automaticRefreshInterval: DateComponents? {
        return nil
    }
    
    var automaticRefreshEndDate: Date? {
        return nil
    }
    
    var isDataSourceEmpty: Bool {
        return filteredGrants.isEmpty
    }
    
    @objc func refresh() {
        // Ensure we're on the main thread for UI updates
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            // Reload the table data safely
            self.tableView.reloadData()
            
            // End the refresh control if it's active
            self.refreshControl?.endRefreshing()
        }
    }
}

// MARK: - Grant Filters
struct GrantFilters {
    let status: Grant.GrantStatus?
    let requiresEmployee: Bool?
    let requires501c3: Bool?
    
    init(status: Grant.GrantStatus? = nil, requiresEmployee: Bool? = nil, requires501c3: Bool? = nil) {
        self.status = status
        self.requiresEmployee = requiresEmployee
        self.requires501c3 = requires501c3
    }
} 