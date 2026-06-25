import UIKit

final class ChatHistoryCell: UITableViewCell {
    
    static let identifier = "ChatHistoryCell"
    
    private let cardView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(red: 0.09, green: 0.07, blue: 0.09, alpha: 1.00)
        view.layer.cornerRadius = 24
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let iconImageView: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(named: "Vector 2")
        iv.contentMode = .scaleAspectFit
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Inter-Medium", size: 16) ?? UIFont.systemFont(ofSize: 16, weight: .medium)
        label.textColor = .white
        label.numberOfLines = 1
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let timeLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Inter-Regular", size: 12) ?? UIFont.systemFont(ofSize: 12)
        label.textColor = .lightGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    private func setupUI() {
        backgroundColor = .black
        selectionStyle = .none
        
        contentView.addSubview(cardView)
        cardView.addSubview(iconImageView)
        cardView.addSubview(titleLabel)
        cardView.addSubview(timeLabel)
        
        NSLayoutConstraint.activate([
            cardView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 6),
            cardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            cardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            cardView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -6),
            
            iconImageView.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 12),
            iconImageView.centerYAnchor.constraint(equalTo: cardView.centerYAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 28),
            iconImageView.heightAnchor.constraint(equalToConstant: 28),
            
            titleLabel.leadingAnchor.constraint(equalTo: iconImageView.trailingAnchor, constant: 12),
            titleLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -12),
            titleLabel.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 16),
            
            timeLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            timeLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            timeLabel.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -16),
            
            cardView.heightAnchor.constraint(greaterThanOrEqualToConstant: 72)
        ])
    }
    
    func configure(with chat: ChatHistoryItem) {
        titleLabel.text = chat.title ?? chat.lastMessagePreview ?? "New Chat"
        
        if let date = chat.date {
            let formatter = DateFormatter()
            let calendar = Calendar.current
            
            if calendar.isDateInToday(date) {
                formatter.dateFormat = "h:mm a"
                timeLabel.text = "Today, \(formatter.string(from: date))"
            } else if calendar.isDateInYesterday(date) {
                formatter.dateFormat = "h:mm a"
                timeLabel.text = "Yesterday, \(formatter.string(from: date))"
            } else {
                formatter.dateFormat = "MMM d, h:mm a"
                timeLabel.text = formatter.string(from: date)
            }
        } else {
            timeLabel.text = ""
        }
    }
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        
        let normalColor = UIColor(red: 0.09, green: 0.07, blue: 0.09, alpha: 1.00)
        let highlightedColor = UIColor(red: 0.12, green: 0.10, blue: 0.12, alpha: 1.00)
        
        UIView.animate(withDuration: 0.2) {
            self.cardView.backgroundColor = highlighted ? highlightedColor : normalColor
            self.cardView.transform = highlighted ? CGAffineTransform(scaleX: 0.98, y: 0.98) : .identity
        }
    }
}
