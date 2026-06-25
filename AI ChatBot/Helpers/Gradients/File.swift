import UIKit

extension UIView {
    
    func addGradientToButtonBackground(
        colors: [UIColor],
        startPoint: CGPoint = CGPoint(x: 0, y: 0),
        endPoint: CGPoint = CGPoint(x: 1, y: 1)
    ) {
        
        removeGradient()
        
        let gradient = CAGradientLayer()
        gradient.name = "gradient"
        gradient.frame = bounds
        gradient.colors = colors.map { $0.cgColor }
        gradient.startPoint = startPoint
        gradient.endPoint = endPoint
        gradient.cornerRadius = layer.cornerRadius
        
        layer.insertSublayer(gradient, at: 0)
    }
    
    func removeGradient() {
        layer.sublayers?
            .filter { $0.name == "gradient" }
            .forEach { $0.removeFromSuperlayer() }
    }
    
    func updateGradientFrame() {
        layer.sublayers?
            .filter { $0.name == "gradient" }
            .forEach { gradientLayer in
                if let gradient = gradientLayer as? CAGradientLayer {
                    gradient.frame = bounds
                }
            }
    }
    
    func addGradientBorder(
        colors: [UIColor],
        cornerRadius: CGFloat,
        lineWidth: CGFloat = 2
    ) {
        
        layer.sublayers?
            .filter { $0.name == "GradientBorderLayer" }
            .forEach { $0.removeFromSuperlayer() }
        
        let gradient = CAGradientLayer()
        gradient.name = "GradientBorderLayer"
        gradient.frame = bounds
        
        gradient.colors = colors.map(\.cgColor)
        gradient.startPoint = CGPoint(x: 0, y: 0)
        gradient.endPoint = CGPoint(x: 1, y: 1)
        
        let shape = CAShapeLayer()
        shape.lineWidth = lineWidth
        shape.fillColor = UIColor.clear.cgColor
        shape.strokeColor = UIColor.white.cgColor
        
        shape.path = UIBezierPath(
            roundedRect: bounds.insetBy(
                dx: lineWidth / 2,
                dy: lineWidth / 2
            ),
            cornerRadius: cornerRadius
        ).cgPath
        
        gradient.mask = shape
        
        layer.addSublayer(gradient)
    }
}

extension UIColor {
    convenience init(hex: String) {
        var hex = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hex = hex.replacingOccurrences(of: "#", with: "")
        
        var rgb: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&rgb)
        
        let r = CGFloat((rgb >> 16) & 0xFF) / 255
        let g = CGFloat((rgb >> 8) & 0xFF) / 255
        let b = CGFloat(rgb & 0xFF) / 255
        
        self.init(red: r, green: g, blue: b, alpha: 1)
    }
}

// MARK: - UIImage Gradient Extension

extension UIImage {
    func withGradient(colors: [UIColor]) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        defer { UIGraphicsEndImageContext() }
        
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        
        context.translateBy(x: 0, y: size.height)
        context.scaleBy(x: 1.0, y: -1.0)
        
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let gradient = CGGradient(
            colorsSpace: colorSpace,
            colors: colors.map { $0.cgColor } as CFArray,
            locations: nil
        )!
        
        context.drawLinearGradient(
            gradient,
            start: .zero,
            end: CGPoint(x: size.width, y: size.height),
            options: []
        )
        
        context.setBlendMode(.destinationIn)
        if let cgImage = self.cgImage {
            context.draw(cgImage, in: CGRect(origin: .zero, size: size))
        }
        
        return UIGraphicsGetImageFromCurrentImageContext()
    }
}


extension UIViewController {
    func setupGradientBackground() {
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = view.bounds
        
        gradientLayer.colors = [
            UIColor(red: 0.35, green: 0.25, blue: 0.45, alpha: 1.0).cgColor,
            UIColor(red: 0.15, green: 0.1, blue: 0.2, alpha: 1.0).cgColor,
            UIColor.black.cgColor
        ]
        
        gradientLayer.locations = [0.0, 0.0, 1.0]
        
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0.0)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 1.0)
        
        view.layer.insertSublayer(gradientLayer, at: 0)
    }
    
    func createGradientImage(colors: [UIColor], size: CGSize) -> UIImage {
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = CGRect(origin: .zero, size: size)
        gradientLayer.colors = colors.map { $0.cgColor }
        gradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1, y: 0.5)
        
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        guard let context = UIGraphicsGetCurrentContext() else {
            return UIImage()
        }
        gradientLayer.render(in: context)
        let image = UIGraphicsGetImageFromCurrentImageContext() ?? UIImage()
        UIGraphicsEndImageContext()
        
        return image
    }
}
