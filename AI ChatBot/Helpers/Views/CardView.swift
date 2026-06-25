import UIKit

struct CardConfiguration {

    let title: String
    let subtitle: String
    let image: UIImage
    let style: Style
    let titleFont: UIFont
    let subtitleFont: UIFont
    let subtitleColor: UIColor

    enum Style {
        case plain
        case gradient(colors: [UIColor], bottomButtonTitle: String)
    }
}

import UIKit

final class CardView: UIControl {

    private let imageView = UIImageView()
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()

    private let gradientLayer = CAGradientLayer()
    private let bottomButton = UIButton()

    init(configuration: CardConfiguration) {
        super.init(frame: .zero)
        setupUI()
        configure(with: configuration)
    }

    required init?(coder: NSCoder) {
        fatalError()
    }

    private func setupUI() {

        layer.cornerRadius = 28
        clipsToBounds = true

        imageView.contentMode = .scaleAspectFit

        titleLabel.textColor = .white
        titleLabel.numberOfLines = 0

        subtitleLabel.numberOfLines = 0

        var config = UIButton.Configuration.filled()

        config.baseBackgroundColor = UIColor.white.withAlphaComponent(0.2)
        config.baseForegroundColor = .white

        config.image = UIImage(systemName: "play.fill")
        config.imagePlacement = .trailing
        config.imagePadding = 6

        config.preferredSymbolConfigurationForImage = UIImage.SymbolConfiguration(pointSize: 10, weight: .regular)

        config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
            var outgoing = incoming
            outgoing.font = UIFont(name: "Inter-Regular", size: 12) ?? UIFont.systemFont(ofSize: 12)
            return outgoing
        }

        bottomButton.configuration = config
        bottomButton.layer.cornerRadius = 18
        bottomButton.isHidden = true
        bottomButton.isUserInteractionEnabled = false

        let stack = UIStackView(arrangedSubviews: [
            titleLabel,
            subtitleLabel
        ])

        stack.axis = .vertical
        stack.spacing = 6
        stack.isUserInteractionEnabled = false

        addSubview(imageView)
        addSubview(stack)
        addSubview(bottomButton)

        imageView.translatesAutoresizingMaskIntoConstraints = false
        stack.translatesAutoresizingMaskIntoConstraints = false
        bottomButton.translatesAutoresizingMaskIntoConstraints = false
        
        imageView.isUserInteractionEnabled = false

        NSLayoutConstraint.activate([

            imageView.topAnchor.constraint(equalTo: topAnchor, constant: 16),
            imageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            imageView.widthAnchor.constraint(equalToConstant: 36),
            imageView.heightAnchor.constraint(equalToConstant: 36),

            stack.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 10),
            stack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),

            bottomButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            bottomButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            bottomButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16),
            bottomButton.heightAnchor.constraint(equalToConstant: 36)
        ])

        layer.insertSublayer(gradientLayer, at: 0)
    }

    func configure(with configuration: CardConfiguration) {

        titleLabel.text = configuration.title
        subtitleLabel.text = configuration.subtitle
        imageView.image = configuration.image

        titleLabel.font = configuration.titleFont
        subtitleLabel.font = configuration.subtitleFont
        subtitleLabel.textColor = configuration.subtitleColor

        switch configuration.style {

        case .plain:

            gradientLayer.removeFromSuperlayer()
            backgroundColor = UIColor.white.withAlphaComponent(0.05)
            bottomButton.isHidden = true

        case .gradient(let colors, let buttonTitle):

            backgroundColor = .clear

            gradientLayer.colors = colors.map { $0.cgColor }
            gradientLayer.startPoint = CGPoint(x: 0, y: 0)
            gradientLayer.endPoint = CGPoint(x: 1, y: 1)

            if gradientLayer.superlayer == nil {
                layer.insertSublayer(gradientLayer, at: 0)
            }

            var updated = bottomButton.configuration
            updated?.title = buttonTitle
            bottomButton.configuration = updated

            bottomButton.isHidden = false
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = bounds
    }
}
