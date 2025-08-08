import Foundation
import UIKit

class GrantTableViewCell: UITableViewCell, Reusable {
    
    var viewModel: GrantCellViewModel? {
        didSet {
            configureCell()
        }
    }
    
    // MARK: - Reusable
    static var nib: UINib? {
        return nil // Programmatic cell
    }
    
    // MARK: - UI Elements
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        label.numberOfLines = 0
        return label
    }()
    
    private let statusLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        label.textAlignment = .center
        label.layer.cornerRadius = 4
        label.layer.masksToBounds = true
        return label
    }()
    
    private let dateLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = UIColor.secondaryLabel
        return label
    }()
    
    private let requirementsLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = UIColor.tertiaryLabel
        label.numberOfLines = 0
        return label
    }()
    
    // MARK: - Init
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    private func setupViews() {
        contentView.addSubview(nameLabel)
        contentView.addSubview(statusLabel)
        contentView.addSubview(dateLabel)
        contentView.addSubview(requirementsLabel)
        
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        statusLabel.translatesAutoresizingMaskIntoConstraints = false
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        requirementsLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            // Status label (top right)
            statusLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            statusLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            statusLabel.widthAnchor.constraint(greaterThanOrEqualToConstant: 60),
            statusLabel.heightAnchor.constraint(equalToConstant: 20),
            
            // Name label (top left, extends to status)
            nameLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            nameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            nameLabel.trailingAnchor.constraint(equalTo: statusLabel.leadingAnchor, constant: -8),
            
            // Date label (below name)
            dateLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 4),
            dateLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            dateLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            // Requirements label (below date)
            requirementsLabel.topAnchor.constraint(equalTo: dateLabel.bottomAnchor, constant: 4),
            requirementsLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            requirementsLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            requirementsLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12)
        ])
    }
    
    // MARK: - Private Methods
    private func configureCell() {
        guard let viewModel = viewModel else {
            return
        }
        
        nameLabel.text = viewModel.name
        statusLabel.text = viewModel.status
        statusLabel.textColor = viewModel.statusColor
        statusLabel.backgroundColor = viewModel.statusColor.withAlphaComponent(0.1)
        dateLabel.text = viewModel.dateText
        requirementsLabel.text = viewModel.requirementsText
    }
} 