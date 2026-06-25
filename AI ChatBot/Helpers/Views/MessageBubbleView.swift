import UIKit

final class MessageBubbleView: UIView {
    
    private let textLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = UIFont.systemFont(ofSize: 16)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let bubbleView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 16
        view.layer.masksToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private var leadingConstraint: NSLayoutConstraint!
    private var trailingConstraint: NSLayoutConstraint!
    
    init() {
        super.init(frame: .zero)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    private func setup() {
        addSubview(bubbleView)
        bubbleView.addSubview(textLabel)
        
        leadingConstraint = bubbleView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16)
        trailingConstraint = bubbleView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16)
        
        NSLayoutConstraint.activate([
            bubbleView.topAnchor.constraint(equalTo: topAnchor, constant: 4),
            bubbleView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -4),
            bubbleView.widthAnchor.constraint(lessThanOrEqualTo: widthAnchor, multiplier: 0.75),
            
            textLabel.topAnchor.constraint(equalTo: bubbleView.topAnchor, constant: 12),
            textLabel.leadingAnchor.constraint(equalTo: bubbleView.leadingAnchor, constant: 12),
            textLabel.trailingAnchor.constraint(equalTo: bubbleView.trailingAnchor, constant: -12),
            textLabel.bottomAnchor.constraint(equalTo: bubbleView.bottomAnchor, constant: -12)
        ])
    }
    
    func configure(with message: MessageBubble) {
        textLabel.text = message.text
        
        if message.isUser {
            textLabel.textColor = .white
            leadingConstraint.isActive = false
            trailingConstraint.isActive = true
            
            DispatchQueue.main.async {
                self.addGradientToBubble()
            }
        } else {
            textLabel.textColor = .white
            bubbleView.backgroundColor = UIColor(red: 0.09, green: 0.07, blue: 0.09, alpha: 1.00)
            leadingConstraint.isActive = true
            trailingConstraint.isActive = false
        }
    }
    
    private func addGradientToBubble() {
        bubbleView.layer.sublayers?.filter { $0.name == "gradient" }.forEach { $0.removeFromSuperlayer() }
        
        let gradientLayer = CAGradientLayer()
        gradientLayer.name = "gradient"
        gradientLayer.frame = bubbleView.bounds
        gradientLayer.colors = [
            UIColor(hex: "#98C6F7").cgColor,
            UIColor(hex: "#EB5B92").cgColor
        ]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1, y: 0.5)
        gradientLayer.cornerRadius = 16
        
        bubbleView.layer.insertSublayer(gradientLayer, at: 0)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        bubbleView.layer.sublayers?.first(where: { $0.name == "gradient" })?.frame = bubbleView.bounds
    }
}
