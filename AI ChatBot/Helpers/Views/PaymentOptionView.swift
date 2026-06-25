import UIKit

final class PaymentOptionView: UIControl {
    
    private let badgeLabel = UILabel()
    private let badgeBackgroundView = UIView()
    private let titleLabel = UILabel()
    private let priceLabel = UILabel()

    private let title: String
    private let price: String
    private let showBadge: Bool
    
    private var isOptionSelected = false
    
    init(title: String, price: String, showBadge: Bool) {
        self.title = title
        self.price = price
        self.showBadge = showBadge
        
        super.init(frame: .zero)
        
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    private func setupUI() {
        backgroundColor = .black
        layer.cornerRadius = 24
        layer.borderWidth = 1
        layer.borderColor = UIColor.white.withAlphaComponent(0.7).cgColor
        
        isUserInteractionEnabled = true
        
        badgeBackgroundView.layer.cornerRadius = 12
        badgeBackgroundView.clipsToBounds = true
        badgeBackgroundView.isHidden = !showBadge
        addSubview(badgeBackgroundView)
        badgeBackgroundView.translatesAutoresizingMaskIntoConstraints = false
        badgeLabel.text = "SAVE 100%"
        badgeLabel.font = UIFont(name: "Inter-Bold", size: 12) ?? UIFont.boldSystemFont(ofSize: 12)
        badgeLabel.textColor = .white
        badgeLabel.textAlignment = .center
        badgeLabel.backgroundColor = .clear
        badgeBackgroundView.addSubview(badgeLabel)
        badgeLabel.translatesAutoresizingMaskIntoConstraints = false
        
        titleLabel.text = title
        titleLabel.font = UIFont(name: "Inter-SemiBold", size: 16) ?? UIFont.systemFont(ofSize: 16, weight: .semibold)
        titleLabel.textColor = .white
        
        priceLabel.text = price
        priceLabel.font = UIFont(name: "Inter-Regular", size: 14) ?? UIFont.boldSystemFont(ofSize: 20)
        priceLabel.textColor = .lightGray

        let leftStack = UIStackView(arrangedSubviews: [titleLabel, priceLabel])
        leftStack.axis = .vertical
        leftStack.spacing = 4
        leftStack.alignment = .leading
        
        addSubview(leftStack)

        leftStack.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            leftStack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            leftStack.centerYAnchor.constraint(equalTo: centerYAnchor),
            
            badgeBackgroundView.topAnchor.constraint(equalTo: topAnchor, constant: 16),
            badgeBackgroundView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            badgeBackgroundView.heightAnchor.constraint(equalToConstant: 25),
            badgeBackgroundView.widthAnchor.constraint(greaterThanOrEqualToConstant: 102),
            
            badgeLabel.topAnchor.constraint(equalTo: badgeBackgroundView.topAnchor),
            badgeLabel.leadingAnchor.constraint(equalTo: badgeBackgroundView.leadingAnchor, constant: 8),
            badgeLabel.trailingAnchor.constraint(equalTo: badgeBackgroundView.trailingAnchor, constant: -8),
            badgeLabel.bottomAnchor.constraint(equalTo: badgeBackgroundView.bottomAnchor)
        ])
        
    }
    
    override func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        return true
    }
    
    override func endTracking(_ touch: UITouch?, with event: UIEvent?) {
        super.endTracking(touch, with: event)
        if let touch = touch, bounds.contains(touch.location(in: self)) {
            sendActions(for: .touchUpInside)
        }
    }
    
    func setSelected(_ selected: Bool) {
        isOptionSelected = selected
        UIView.animate(withDuration: 0.2) {
            if selected {
                self.layer.borderWidth = 1
                self.backgroundColor = .black
                self.addGradientBorder(
                    colors: [UIColor(hex: "#98C6F7"), UIColor(hex: "#EB5B92")],
                    cornerRadius: 20,
                    lineWidth: 2
                )
            } else {
                self.layer.sublayers?
                    .filter { $0.name == "GradientBorderLayer" }
                    .forEach { $0.removeFromSuperlayer() }
                self.layer.borderColor = UIColor.white.withAlphaComponent(0.7).cgColor
                self.layer.borderWidth = 1
                self.backgroundColor = .black
            }
        }
    }
    
    // MARK: - Update Methods
    
    func updatePrice(_ newPrice: String) {
        priceLabel.text = newPrice
    }
    
    func updateTitle(_ newTitle: String) {
        titleLabel.text = newTitle
    }
    
    func updateBadge(_ newBadgeText: String) {
        badgeLabel.text = newBadgeText
    }
    
    func hideDiscountBadge() {
        badgeBackgroundView.isHidden = true
    }
    
    func showDiscountBadge() {
        badgeBackgroundView.isHidden = false
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()

        let gradientLayer = CAGradientLayer()
        gradientLayer.name = "BadgeGradientLayer"
        gradientLayer.frame = badgeBackgroundView.bounds
        gradientLayer.colors = [
            UIColor(hex: "#98C6F7").cgColor,
            UIColor(hex: "#EB5B92").cgColor
        ]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1, y: 0.5)
        gradientLayer.cornerRadius = 12
        
        badgeBackgroundView.layer.insertSublayer(gradientLayer, at: 0)
        
        if isOptionSelected {
            layer.sublayers?
                .filter { $0.name == "GradientBorderLayer" }
                .forEach { $0.removeFromSuperlayer() }
            
            addGradientBorder(
                colors: [UIColor(hex: "#98C6F7"), UIColor(hex: "#EB5B92")],
                cornerRadius: 20,
                lineWidth: 2
            )
        }
    }
}
