import UIKit

final class HistoryCell: UICollectionViewCell {
    
    private let imageView = UIImageView()
    private let statusBadge = UIView()
    private let statusLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 12
        imageView.backgroundColor = .darkGray
        contentView.addSubview(imageView)
        imageView.translatesAutoresizingMaskIntoConstraints = false

        statusBadge.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        statusBadge.layer.cornerRadius = 4
        statusBadge.isHidden = true
        contentView.addSubview(statusBadge)
        statusBadge.translatesAutoresizingMaskIntoConstraints = false
        
        statusLabel.font = UIFont(name: "Inter-Medium", size: 10)
        statusLabel.textColor = .white
        statusLabel.textAlignment = .center
        statusBadge.addSubview(statusLabel)
        statusLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            
            statusBadge.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            statusBadge.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
            statusBadge.heightAnchor.constraint(equalToConstant: 20),
            
            statusLabel.topAnchor.constraint(equalTo: statusBadge.topAnchor, constant: 4),
            statusLabel.leadingAnchor.constraint(equalTo: statusBadge.leadingAnchor, constant: 8),
            statusLabel.trailingAnchor.constraint(equalTo: statusBadge.trailingAnchor, constant: -8),
            statusLabel.bottomAnchor.constraint(equalTo: statusBadge.bottomAnchor, constant: -4)
        ])
        
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.3
        layer.shadowOffset = CGSize(width: 0, height: 2)
        layer.shadowRadius = 4
    }
    
    func configure(with item: VideoHistoryItem) {
        if let thumbnail = item.thumbnail {
            imageView.image = thumbnail
        } else {
            imageView.image = UIImage(named: "Result")
        }
        
        switch item.status {
        case .processing:
            statusBadge.isHidden = false
            statusLabel.text = "Processing"
            statusBadge.backgroundColor = UIColor.orange.withAlphaComponent(0.9)
        case .failed:
            statusBadge.isHidden = false
            statusLabel.text = "Failed"
            statusBadge.backgroundColor = UIColor.red.withAlphaComponent(0.9)
        case .completed:
            statusBadge.isHidden = true
        }
    }
}
