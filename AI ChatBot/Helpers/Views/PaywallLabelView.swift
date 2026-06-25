import UIKit

final class PaywallLabelView: UIView {

    private let imageView = UIImageView()
    private let label = UILabel()

    init(text: String, image: UIImage?, font: UIFont, lines: Int) {
        super.init(frame: .zero)
        
        imageView.image = image
        imageView.tintColor = .white
        imageView.contentMode = .scaleAspectFit

        label.text = text
        label.textColor = .white
        label.font = font
        label.numberOfLines = lines
        label.textAlignment = image == nil ? .center : .left

        let stack = UIStackView(arrangedSubviews: [imageView, label])
        stack.axis = .horizontal
        stack.spacing = 8

        addSubview(stack)
        stack.translatesAutoresizingMaskIntoConstraints = false
        
        if image != nil {
            NSLayoutConstraint.activate([
                imageView.widthAnchor.constraint(equalToConstant: 24),
                imageView.heightAnchor.constraint(equalToConstant: 24)
            ])
        } else {
            imageView.isHidden = true
        }

        NSLayoutConstraint.activate([stack.topAnchor.constraint(equalTo: topAnchor),
                                     stack.leadingAnchor.constraint(equalTo: leadingAnchor),
                                     stack.trailingAnchor.constraint(equalTo: trailingAnchor),
                                     stack.bottomAnchor.constraint(equalTo: bottomAnchor)])
    }

    required init?(coder: NSCoder) {
        fatalError()
    }
}
