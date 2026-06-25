import UIKit

final class TemplateCarouselCell: UICollectionViewCell {
    
    private let imageView = UIImageView()
    private let dimView = UIView()
    private let activityIndicator = UIActivityIndicatorView(style: .medium)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil
        activityIndicator.stopAnimating()
    }
    
    private func setupUI() {
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 16
        imageView.backgroundColor = .darkGray
        contentView.addSubview(imageView)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        dimView.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        dimView.layer.cornerRadius = 16
        imageView.addSubview(dimView)
        dimView.translatesAutoresizingMaskIntoConstraints = false
        
        activityIndicator.hidesWhenStopped = true
        activityIndicator.color = .white
        contentView.addSubview(activityIndicator)
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            
            dimView.topAnchor.constraint(equalTo: imageView.topAnchor),
            dimView.leadingAnchor.constraint(equalTo: imageView.leadingAnchor),
            dimView.trailingAnchor.constraint(equalTo: imageView.trailingAnchor),
            dimView.bottomAnchor.constraint(equalTo: imageView.bottomAnchor),
            
            activityIndicator.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
        
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.3
        layer.shadowOffset = CGSize(width: 0, height: 4)
        layer.shadowRadius = 8
    }
    
    func configure(with template: VideoTemplate, isCenter: Bool) {
        if let previewURL = template.previewLarge ?? template.previewSmall {
            activityIndicator.startAnimating()
            ThumbnailCache.shared.getThumbnail(for: previewURL, maxSize: CGSize(width: 600, height: 600)) { [weak self] thumbnail in
                self?.activityIndicator.stopAnimating()
                self?.imageView.image = thumbnail
            }
        }
        
        UIView.animate(withDuration: 0.3) {
            self.dimView.alpha = isCenter ? 0 : 1
        }
    }
    
    func updateScale(_ scale: CGFloat) {
        UIView.animate(withDuration: 0.1) {
            self.transform = CGAffineTransform(scaleX: scale, y: scale)
        }
    }
    
    func updateDimAlpha(_ alpha: CGFloat) {
        UIView.animate(withDuration: 0.1) {
            self.dimView.alpha = alpha
        }
    }
}


