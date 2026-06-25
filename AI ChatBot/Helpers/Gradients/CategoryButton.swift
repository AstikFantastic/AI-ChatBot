import UIKit

final class CategoryButton: UIButton {
    
    private var gradientColors: [UIColor]?
    
    override func layoutSubviews() {
        super.layoutSubviews()
        updateGradientFrame()
    }
    
    func applyGradient(colors: [UIColor]) {
        self.gradientColors = colors
        backgroundColor = .clear
        addGradientToButtonBackground(colors: colors)
    }
    
    func removeGradientStyle() {
        self.gradientColors = nil
        removeGradient()
    }
}
