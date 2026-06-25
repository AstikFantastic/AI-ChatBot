import UIKit

final class VideoProcessingViewController: UIViewController {
    
    private let presenter: VideoProcessingPresenterProtocol
    
    private let customNavBar = UIView()
    private let backButton = UIButton()
    private let titleLabel = UILabel()
    
    private let progressView = UIView()
    private let progressIndicator = UIActivityIndicatorView(style: .large)
    private let statusLabel = UILabel()
    private let progressLabel = UILabel()
    
    private let resultContainer = UIView()
    private let videoPreviewContainer = UIView()
    private let videoImageView = UIImageView()
    
    private let replaceButton = UIButton()
    private let shareButton = UIButton()
    private let downloadButton = UIButton()
    
    
    init(presenter: VideoProcessingPresenterProtocol) {
        self.presenter = presenter
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        presenter.viewDidLoad()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        downloadButton.addGradientToButtonBackground(colors: [UIColor(hex: "#98C6F7"), UIColor(hex: "#EB5B92")])
    }
    
    // MARK: - Setup UI
    
    private func setupUI() {
        view.backgroundColor = .black
        
        setupCustomNavigationBar()
        setupProgressView()
        setupResultContainer()
        
        NSLayoutConstraint.activate([
            progressView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            progressView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            progressView.widthAnchor.constraint(equalToConstant: 358),
            progressView.heightAnchor.constraint(equalToConstant: 611),
            
            resultContainer.topAnchor.constraint(equalTo: customNavBar.bottomAnchor, constant: 16),
            resultContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            resultContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            resultContainer.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    private func setupCustomNavigationBar() {
        customNavBar.backgroundColor = .black
        view.addSubview(customNavBar)
        customNavBar.translatesAutoresizingMaskIntoConstraints = false
        
        backButton.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        backButton.tintColor = .white
        backButton.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
        customNavBar.addSubview(backButton)
        backButton.translatesAutoresizingMaskIntoConstraints = false
        
        titleLabel.textColor = .white
        titleLabel.font = UIFont(name: "Inter-SemiBold", size: 20)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        customNavBar.addSubview(titleLabel)
        
        NSLayoutConstraint.activate([
            customNavBar.topAnchor.constraint(equalTo: view.topAnchor),
            customNavBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            customNavBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            customNavBar.heightAnchor.constraint(equalToConstant: 100),
            
            backButton.leadingAnchor.constraint(equalTo: customNavBar.leadingAnchor, constant: 12),
            backButton.bottomAnchor.constraint(equalTo: customNavBar.bottomAnchor, constant: -12),
            backButton.widthAnchor.constraint(equalToConstant: 32),
            backButton.heightAnchor.constraint(equalToConstant: 32),
            
            titleLabel.centerXAnchor.constraint(equalTo: customNavBar.centerXAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: backButton.centerYAnchor)
        ])
    }
    
    private func setupProgressView() {
        view.addSubview(progressView)
        progressView.translatesAutoresizingMaskIntoConstraints = false
        
        progressIndicator.color = .white
        progressIndicator.startAnimating()
        progressView.addSubview(progressIndicator)
        progressIndicator.translatesAutoresizingMaskIntoConstraints = false
        
        statusLabel.text = "Generating..."
        statusLabel.textColor = .white
        statusLabel.font = UIFont(name: "Inter-SemiBold", size: 20)
        statusLabel.textAlignment = .center
        progressView.addSubview(statusLabel)
        statusLabel.translatesAutoresizingMaskIntoConstraints = false
        
        progressLabel.text = "We’re creating the best result for you"
        progressLabel.textColor = UIColor.white.withAlphaComponent(0.6)
        progressLabel.font = UIFont(name: "Inter-Regular", size: 16)
        progressLabel.textAlignment = .center
        progressView.addSubview(progressLabel)
        progressLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            progressIndicator.centerXAnchor.constraint(equalTo: progressView.centerXAnchor),
            progressView.centerYAnchor.constraint(equalTo: progressIndicator.centerYAnchor),
            progressIndicator.topAnchor.constraint(equalTo: progressView.topAnchor),
            
            statusLabel.centerXAnchor.constraint(equalTo: progressView.centerXAnchor),
            statusLabel.topAnchor.constraint(equalTo: progressIndicator.bottomAnchor, constant: 24),
            
            progressLabel.centerXAnchor.constraint(equalTo: progressView.centerXAnchor),
            progressLabel.topAnchor.constraint(equalTo: statusLabel.bottomAnchor, constant: 8)
        ])
    }
    
    private func setupResultContainer() {
        resultContainer.backgroundColor = .black
        resultContainer.isHidden = true
        view.addSubview(resultContainer)
        resultContainer.translatesAutoresizingMaskIntoConstraints = false
        
        videoPreviewContainer.backgroundColor = UIColor(white: 0.15, alpha: 1)
        videoPreviewContainer.layer.cornerRadius = 16
        videoPreviewContainer.clipsToBounds = true
        resultContainer.addSubview(videoPreviewContainer)
        videoPreviewContainer.translatesAutoresizingMaskIntoConstraints = false
        
        videoImageView.contentMode = .scaleAspectFill
        videoImageView.clipsToBounds = true
        videoPreviewContainer.addSubview(videoImageView)
        videoImageView.translatesAutoresizingMaskIntoConstraints = false
        
        let image = UIImage(named: "refresh-2")
        let resizedImage = image?.withConfiguration(UIImage.SymbolConfiguration(pointSize: 24))
        replaceButton.setImage(resizedImage, for: .normal)
        replaceButton.setTitle("Replace", for: .normal)
        replaceButton.setTitleColor(.white, for: .normal)
        replaceButton.titleLabel?.font = UIFont(name: "Inter-SemiBold", size: 14)
        replaceButton.backgroundColor = UIColor.black.withAlphaComponent(0.75)
        replaceButton.layer.cornerRadius = 20
        replaceButton.addTarget(self, action: #selector(replaceButtonTapped), for: .touchUpInside)
        replaceButton.titleLabel?.text = "Replace"
        resultContainer.addSubview(replaceButton)
        replaceButton.translatesAutoresizingMaskIntoConstraints = false
        
        shareButton.setTitle("Share", for: .normal)
        shareButton.setTitleColor(.white, for: .normal)
        shareButton.titleLabel?.font = UIFont(name: "Inter-SemiBold", size: 16)
        shareButton.backgroundColor = UIColor(white: 0.2, alpha: 1)
        shareButton.layer.cornerRadius = 24
        shareButton.addTarget(self, action: #selector(shareButtonTapped), for: .touchUpInside)
        resultContainer.addSubview(shareButton)
        shareButton.translatesAutoresizingMaskIntoConstraints = false
        
        downloadButton.setTitle("Download", for: .normal)
        downloadButton.setTitleColor(.white, for: .normal)
        downloadButton.titleLabel?.font = UIFont(name: "Inter-SemiBold", size: 16)
        downloadButton.layer.cornerRadius = 24
        downloadButton.addTarget(self, action: #selector(downloadButtonTapped), for: .touchUpInside)
        resultContainer.addSubview(downloadButton)
        downloadButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            videoPreviewContainer.topAnchor.constraint(equalTo: resultContainer.topAnchor, constant: 20),
            videoPreviewContainer.leadingAnchor.constraint(equalTo: resultContainer.leadingAnchor, constant: 20),
            videoPreviewContainer.trailingAnchor.constraint(equalTo: resultContainer.trailingAnchor, constant: -20),
            videoPreviewContainer.heightAnchor.constraint(equalToConstant: 611),
            
            videoImageView.topAnchor.constraint(equalTo: videoPreviewContainer.topAnchor),
            videoImageView.leadingAnchor.constraint(equalTo: videoPreviewContainer.leadingAnchor),
            videoImageView.trailingAnchor.constraint(equalTo: videoPreviewContainer.trailingAnchor),
            videoImageView.bottomAnchor.constraint(equalTo: videoPreviewContainer.bottomAnchor),
            
            replaceButton.topAnchor.constraint(equalTo: videoPreviewContainer.topAnchor, constant: 14),
            replaceButton.trailingAnchor.constraint(equalTo: videoPreviewContainer.trailingAnchor, constant: -16),
            replaceButton.heightAnchor.constraint(equalToConstant: 40),
            replaceButton.widthAnchor.constraint(equalToConstant: 110),
            
            shareButton.leadingAnchor.constraint(equalTo: resultContainer.leadingAnchor, constant: 20),
            shareButton.topAnchor.constraint(equalTo: videoPreviewContainer.bottomAnchor, constant: 24),
            shareButton.heightAnchor.constraint(equalToConstant: 50),
            
            downloadButton.leadingAnchor.constraint(equalTo: shareButton.trailingAnchor, constant: 16),
            downloadButton.trailingAnchor.constraint(equalTo: resultContainer.trailingAnchor, constant: -20),
            downloadButton.topAnchor.constraint(equalTo: videoPreviewContainer.bottomAnchor, constant: 24),
            downloadButton.heightAnchor.constraint(equalToConstant: 50),
            downloadButton.widthAnchor.constraint(equalTo: shareButton.widthAnchor)
        ])
    }
    
    // MARK: - Actions
    
    @objc private func backButtonTapped() {
        presenter.didTapBack()
    }
    
    @objc private func replaceButtonTapped() {
        presenter.didTapReplace()
    }
    
    @objc private func shareButtonTapped() {
        guard let image = videoImageView.image else { return }
        
        let activityVC = UIActivityViewController(activityItems: [image], applicationActivities: nil)
        present(activityVC, animated: true)
    }
    
    @objc private func downloadButtonTapped() {
        guard let image = videoImageView.image else { return }
        presenter.didTapDownload(image: image)
    }
}

// MARK: - VideoProcessingViewProtocol

extension VideoProcessingViewController: VideoProcessingViewProtocol {
    
    func setTitle(_ title: String) {
        titleLabel.text = title
    }
    
    func showLoading(status: String, message: String) {
        progressView.isHidden = false
        resultContainer.isHidden = true
        
        statusLabel.text = status
        progressLabel.text = message
        progressIndicator.startAnimating()
    }
    
    func hideLoading() {
        progressView.isHidden = true
        progressIndicator.stopAnimating()
    }
    
    func showResult(image: UIImage) {
        resultContainer.isHidden = false
        videoImageView.image = image
    }
    
    func showError(_ message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    func showSuccessBanner(message: String) {
        let overlayView = UIView()
        overlayView.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        overlayView.alpha = 0
        view.addSubview(overlayView)
        overlayView.translatesAutoresizingMaskIntoConstraints = false
        
        let bannerContainer = UIView()
        bannerContainer.backgroundColor = UIColor(white: 0.2, alpha: 1)
        bannerContainer.layer.cornerRadius = 12
        bannerContainer.layer.borderWidth = 2
        bannerContainer.layer.borderColor = UIColor(red: 0.5, green: 0.4, blue: 0.9, alpha: 1).cgColor
        bannerContainer.alpha = 0
        bannerContainer.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        view.addSubview(bannerContainer)
        bannerContainer.translatesAutoresizingMaskIntoConstraints = false
        
        let checkmarkContainer = UIView()
        bannerContainer.addSubview(checkmarkContainer)
        checkmarkContainer.translatesAutoresizingMaskIntoConstraints = false

        let checkmark = UIImage(systemName: "checkmark",
                                withConfiguration: UIImage.SymbolConfiguration(pointSize: 30, weight: .thin))
        let gradientCheckmark = checkmark?.withGradient(colors: [
            UIColor(hex: "#98C6F7"),
            UIColor(hex: "#EB5B92")
        ])
        let checkmarkImageView = UIImageView(image: gradientCheckmark)
        checkmarkContainer.addSubview(checkmarkImageView)
        checkmarkImageView.translatesAutoresizingMaskIntoConstraints = false
        
        let messageLabel = UILabel()
        messageLabel.text = message
        messageLabel.textColor = .white
        messageLabel.font = UIFont(name: "Inter-Medium", size: 16)
        messageLabel.textAlignment = .center
        messageLabel.numberOfLines = 2
        bannerContainer.addSubview(messageLabel)
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            overlayView.topAnchor.constraint(equalTo: view.topAnchor),
            overlayView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            overlayView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            overlayView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            bannerContainer.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            bannerContainer.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            bannerContainer.widthAnchor.constraint(equalToConstant: 280),
            bannerContainer.heightAnchor.constraint(equalToConstant: 160),

            checkmarkContainer.centerXAnchor.constraint(equalTo: bannerContainer.centerXAnchor),
            checkmarkContainer.topAnchor.constraint(equalTo: bannerContainer.topAnchor, constant: 24),
            checkmarkContainer.widthAnchor.constraint(equalToConstant: 50),
            checkmarkContainer.heightAnchor.constraint(equalToConstant: 50),
            
            checkmarkImageView.centerXAnchor.constraint(equalTo: checkmarkContainer.centerXAnchor),
            checkmarkImageView.centerYAnchor.constraint(equalTo: checkmarkContainer.centerYAnchor),
            checkmarkImageView.widthAnchor.constraint(equalToConstant: 40),
            checkmarkImageView.heightAnchor.constraint(equalToConstant: 40),
            
            messageLabel.topAnchor.constraint(equalTo: checkmarkContainer.bottomAnchor, constant: 20),
            messageLabel.leadingAnchor.constraint(equalTo: bannerContainer.leadingAnchor, constant: 16),
            messageLabel.trailingAnchor.constraint(equalTo: bannerContainer.trailingAnchor, constant: -16)
        ])
        
        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.5, options: .curveEaseOut) {
            overlayView.alpha = 1
            bannerContainer.alpha = 1
            bannerContainer.transform = .identity
        } completion: { _ in
            UIView.animate(withDuration: 0.3, delay: 2.0, options: .curveEaseIn) {
                overlayView.alpha = 0
                bannerContainer.alpha = 0
                bannerContainer.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
            } completion: { _ in
                overlayView.removeFromSuperview()
                bannerContainer.removeFromSuperview()
            }
        }
    }
}
