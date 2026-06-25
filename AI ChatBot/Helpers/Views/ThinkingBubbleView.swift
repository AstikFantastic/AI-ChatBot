import UIKit

final class ThinkingBubbleView: UIView {
    
    private let containerView = UIView()
    private let dot1 = UIView()
    private let dot2 = UIView()
    private let dot3 = UIView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        startAnimating()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        containerView.backgroundColor = UIColor(red: 0.09, green: 0.07, blue: 0.09, alpha: 1.00)
        containerView.layer.cornerRadius = 20
        containerView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(containerView)
        
        let dots = [dot1, dot2, dot3]
        let dotSize: CGFloat = 8
        let spacing: CGFloat = 6
        
        for (index, dot) in dots.enumerated() {
            dot.backgroundColor = .white
            dot.layer.cornerRadius = dotSize / 2
            dot.alpha = 0.3
            dot.translatesAutoresizingMaskIntoConstraints = false
            containerView.addSubview(dot)
            
            NSLayoutConstraint.activate([
                dot.widthAnchor.constraint(equalToConstant: dotSize),
                dot.heightAnchor.constraint(equalToConstant: dotSize),
                dot.centerYAnchor.constraint(equalTo: containerView.centerYAnchor)
            ])
            
            if index == 0 {
                dot.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16).isActive = true
            } else {
                dot.leadingAnchor.constraint(equalTo: dots[index - 1].trailingAnchor, constant: spacing).isActive = true
            }
        }
        
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: topAnchor),
            containerView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            containerView.bottomAnchor.constraint(equalTo: bottomAnchor),
            containerView.heightAnchor.constraint(equalToConstant: 44),
            containerView.trailingAnchor.constraint(equalTo: dot3.trailingAnchor, constant: 16)
        ])
    }
    
    func startAnimating() {
        let dots = [dot1, dot2, dot3]
        
        for (index, dot) in dots.enumerated() {
            let animation = CABasicAnimation(keyPath: "opacity")
            animation.fromValue = 0.3
            animation.toValue = 1.0
            animation.duration = 0.6
            animation.repeatCount = .infinity
            animation.autoreverses = true
            animation.beginTime = CACurrentMediaTime() + Double(index) * 0.2
            dot.layer.add(animation, forKey: "opacity")
        }
    }
    
    func stopAnimating() {
        [dot1, dot2, dot3].forEach { $0.layer.removeAllAnimations() }
    }
    
    deinit {
        stopAnimating()
    }
}
