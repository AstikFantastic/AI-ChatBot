import UIKit

final class GradientSendButton: UIButton {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    private func setup() {
        let image = UIImage(named: "send-2")
        setImage(image, for: .normal)
        tintColor = .white
        layer.cornerRadius = 18
        layer.masksToBounds = true
    }
    
    override func imageRect(forContentRect contentRect: CGRect) -> CGRect {
        let imageSize: CGFloat = 17
        let x = (contentRect.width - imageSize) / 2
        let y = (contentRect.height - imageSize) / 2
        return CGRect(x: x, y: y, width: imageSize, height: imageSize)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = bounds.height / 2
        updateGradientFrame()
        
        if layer.sublayers?.first(where: { $0.name == "gradient" }) == nil {
            let colors = [
                UIColor(hex: "#98C6F7"),
                UIColor(hex: "#EB5B92")
            ]
            addGradientToButtonBackground(
                colors: colors,
                startPoint: CGPoint(x: 0, y: 0.5),
                endPoint: CGPoint(x: 1, y: 0.5)
            )
        }
    }
}
