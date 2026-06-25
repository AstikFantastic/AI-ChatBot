import UIKit

final class PickerCell: UITableViewCell {

    private let titleLabel = UILabel()
    private let iconView = UIView()
    private let gradientLayer = CAGradientLayer()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }

    required init?(coder: NSCoder) {
        fatalError()
    }

    private func setup() {
        backgroundColor = .clear
        selectionStyle = .none

        titleLabel.font = UIFont(name: "Inter-Regular", size: 16)
        titleLabel.textColor = .white
        titleLabel.textAlignment = .left
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        iconView.backgroundColor = .clear
        iconView.layer.borderWidth = 2
        iconView.layer.borderColor = UIColor.white.cgColor
        iconView.layer.cornerRadius = 4
        iconView.translatesAutoresizingMaskIntoConstraints = false

        contentView.addSubview(titleLabel)
        contentView.addSubview(iconView)

        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            titleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            
            iconView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            iconView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])

        gradientLayer.colors = [
            UIColor(hex: "#98C6F7").cgColor,
            UIColor(hex: "#EB5B92").cgColor
        ]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1, y: 0.5)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = titleLabel.frame
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        gradientLayer.removeFromSuperlayer()
        titleLabel.layer.mask = nil
    }

    func configure(with title: String, isSelected: Bool) {
        titleLabel.text = title
        
        configureIcon(for: title)

        if isSelected {
            applyTextGradient()
        } else {
            removeTextGradient()
        }
    }
    
    private func configureIcon(for format: String) {
        iconView.constraints.forEach { iconView.removeConstraint($0) }
        
        var width: CGFloat = 24
        var height: CGFloat = 24
        
        switch format {
        case "16:9":
            width = 32
            height = 18
        case "9:16":
            width = 18
            height = 32
        case "1:1":
            width = 24
            height = 24
        default:
            iconView.isHidden = true
            return
        }
        
        iconView.isHidden = false
        
        NSLayoutConstraint.activate([
            iconView.widthAnchor.constraint(equalToConstant: width),
            iconView.heightAnchor.constraint(equalToConstant: height)
        ])
    }

    private func applyTextGradient() {
        titleLabel.font = UIFont(name: "Inter-SemiBold", size: 16)
        
        layoutIfNeeded()
        
        gradientLayer.frame = titleLabel.bounds

        let tempLabel = UILabel(frame: titleLabel.bounds)
        tempLabel.text = titleLabel.text
        tempLabel.font = UIFont(name: "Inter-SemiBold", size: 16)
        tempLabel.textAlignment = .left
        tempLabel.textColor = .white
        
        UIGraphicsBeginImageContextWithOptions(tempLabel.bounds.size, false, UIScreen.main.scale)
        if let context = UIGraphicsGetCurrentContext() {
            tempLabel.layer.render(in: context)
        }
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        let maskLayer = CALayer()
        maskLayer.contents = image?.cgImage
        maskLayer.frame = titleLabel.bounds
        
        gradientLayer.mask = maskLayer
        
        if gradientLayer.superlayer == nil {
            gradientLayer.position = titleLabel.layer.position
            gradientLayer.anchorPoint = titleLabel.layer.anchorPoint
            contentView.layer.addSublayer(gradientLayer)
        }
        
        titleLabel.textColor = .clear
        
        DispatchQueue.main.async { [weak self] in
            self?.applyGradientToIcon()
        }
    }
    
    private func applyGradientToIcon() {
        guard !iconView.isHidden else { return }
        
        iconView.layer.sublayers?.forEach { $0.removeFromSuperlayer() }
        iconView.layer.borderWidth = 0
        
        let gradientBorder = CAGradientLayer()
        gradientBorder.frame = iconView.bounds
        gradientBorder.colors = [
            UIColor(hex: "#98C6F7").cgColor,
            UIColor(hex: "#EB5B92").cgColor
        ]
        gradientBorder.startPoint = CGPoint(x: 0, y: 0.5)
        gradientBorder.endPoint = CGPoint(x: 1, y: 0.5)
        
        let shape = CAShapeLayer()
        shape.lineWidth = 2
        shape.path = UIBezierPath(roundedRect: gradientBorder.bounds, cornerRadius: 4).cgPath
        shape.strokeColor = UIColor.black.cgColor
        shape.fillColor = UIColor.clear.cgColor
        gradientBorder.mask = shape
        
        iconView.layer.addSublayer(gradientBorder)
    }

    private func removeTextGradient() {
        gradientLayer.removeFromSuperlayer()
        gradientLayer.mask = nil
        
        titleLabel.textColor = .white
        titleLabel.font = UIFont(name: "Inter-Regular", size: 16)
        
        // Возвращаем обычную белую рамку
        iconView.layer.sublayers?.forEach { $0.removeFromSuperlayer() }
        iconView.layer.borderWidth = 2
        iconView.layer.borderColor = UIColor.white.cgColor
    }
}
