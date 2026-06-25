import UIKit
import Photos

final class MainViewController: UIViewController, MainViewProtocol {
    func showTitle(_ text: String) {
        welcomeMessageLabel.text = text
    }
    
    private let presenter: MainVCPresenter
    
    init(presenter: MainVCPresenter) {
        self.presenter = presenter
        super.init(nibName: nil, bundle: nil)
    }
    
    private let settingsButton = UIButton()
    private var mainImageIcon = UIImageView()
    private var welcomeMessageLabel = UILabel()
    private var askAnithingButton = UIButton()
    private var askAnithingImage = UIImageView()
    private var leftCard = UIControl()
    private var rightTopCard = UIControl()
    private var rightBottomCard = UIControl()
    private let playImage = UIImageView(image: UIImage(systemName: "play"))
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        presenter.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.navigationBar.isHidden = true
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if let gradientLayer = view.layer.sublayers?.first as? CAGradientLayer {
            gradientLayer.frame = view.bounds
        }
        
        askAnithingButton.addGradientBorder(colors: [UIColor(hex: "#98C6F7"), UIColor(hex: "#EB5B92")], cornerRadius: 24)
    }
    
    // MARK: - Setup UI
    
    private func setupUI() {
        setupGradientBackground()
        
        view.backgroundColor = .black
        
        settingsButton.setImage(UIImage(systemName: "gearshape",
                                        withConfiguration: UIImage.SymbolConfiguration(pointSize: 28, weight: .regular)),for: .normal)
        
        settingsButton.layer.cornerRadius = 20
        settingsButton.backgroundColor = .darkGray.withAlphaComponent(0.1)
        settingsButton.tintColor = .gray
        settingsButton.addTarget(self, action: #selector(settingsButtonTapped), for: .touchUpInside)
        
        mainImageIcon.image = UIImage(named: "mainIcon") ?? UIImage()
        
        welcomeMessageLabel.font = UIFont(name: "Inter-Bold", size: 32)
        welcomeMessageLabel.text = "Your AI tools, \nready to go"
        welcomeMessageLabel.textAlignment = .center
        welcomeMessageLabel.numberOfLines = 0
        welcomeMessageLabel.textColor = .white
        
        askAnithingButton.titleLabel?.font = UIFont(name: "Inter-Regular", size: 16)
        askAnithingButton.setTitleColor(.white, for: .normal)
        askAnithingButton.setTitle("Ask anything...", for: .normal)
        askAnithingButton.setImage(UIImage(named: "ButtonIcon"), for: .normal)
        askAnithingButton.layer.cornerRadius = 24
        askAnithingButton.layer.borderColor = UIColor.white.cgColor
        askAnithingButton.addTarget(self, action: #selector(askButtonTapped), for: .touchUpInside)
        
        leftCard.layer.cornerRadius = 28
        leftCard = CardView(configuration: CardConfiguration(title: "Turn Photo\ninto Video",
                                                             subtitle: "Animate • Templates",
                                                             image: UIImage(named: "frame") ?? UIImage(),
                                                             style: .gradient(colors: [UIColor(hex: "#98C6F7"), UIColor(hex: "#EB5B92")], bottomButtonTitle: "Ready in seconds"),
                                                             titleFont: UIFont(name: "Inter-Bold", size: 18) ?? UIFont.systemFont(ofSize: 16),
                                                             subtitleFont: UIFont(name: "Inter-Regular", size: 14) ?? UIFont.systemFont(ofSize: 16),
                                                             subtitleColor: UIColor.white))
        leftCard.addTarget(self, action: #selector(openVideoVC), for: .touchUpInside)
        
        rightTopCard.layer.cornerRadius = 28
        rightTopCard = CardView(configuration: CardConfiguration(title: "Fix & Improve\nWriting",
                                                                 subtitle: "Rewrite • Fix grammar",
                                                                 image: UIImage(named: "magicPencil") ?? UIImage(),
                                                                 style: .plain,
                                                                 titleFont: UIFont(name: "Inter-Bold", size: 16) ?? UIFont.systemFont(ofSize: 16),
                                                                 subtitleFont: UIFont(name: "Inter-Regular", size: 12) ?? UIFont.systemFont(ofSize: 16),
                                                                 subtitleColor: UIColor.lightGray))
        rightTopCard.addTarget(self, action: #selector(showComingSoonAlert), for: .touchUpInside)
        
        rightBottomCard.layer.cornerRadius = 28
        rightBottomCard = CardView(configuration: CardConfiguration(title: "Understand\nFaster",
                                                                    subtitle: "Summarize • Key points",
                                                                    image: UIImage(named: "vector") ?? UIImage(),
                                                                    style: .plain,
                                                                    titleFont: UIFont(name: "Inter-Bold", size: 16) ?? UIFont.systemFont(ofSize: 16),
                                                                    subtitleFont: UIFont(name: "Inter-Regular", size: 12) ?? UIFont.systemFont(ofSize: 16),
                                                                    subtitleColor: UIColor.lightGray))
        rightBottomCard.addTarget(self, action: #selector(showComingSoonAlert), for: .touchUpInside)
        
        view.addSubview(settingsButton)
        view.addSubview(mainImageIcon)
        view.addSubview(welcomeMessageLabel)
        view.addSubview(askAnithingButton)
        view.addSubview(leftCard)
        view.addSubview(rightTopCard)
        view.addSubview(rightBottomCard)
        
        settingsButton.translatesAutoresizingMaskIntoConstraints = false
        mainImageIcon.translatesAutoresizingMaskIntoConstraints = false
        welcomeMessageLabel.translatesAutoresizingMaskIntoConstraints = false
        askAnithingButton.translatesAutoresizingMaskIntoConstraints = false
        leftCard.translatesAutoresizingMaskIntoConstraints = false
        rightTopCard.translatesAutoresizingMaskIntoConstraints = false
        rightBottomCard.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            
            settingsButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            settingsButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            settingsButton.widthAnchor.constraint(equalToConstant: 40),
            settingsButton.heightAnchor.constraint(equalToConstant: 40),
            
            mainImageIcon.topAnchor.constraint(equalTo: settingsButton.bottomAnchor, constant: 40),
            mainImageIcon.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            mainImageIcon.widthAnchor.constraint(equalToConstant: 55),
            mainImageIcon.heightAnchor.constraint(equalToConstant: 55),
            
            welcomeMessageLabel.topAnchor.constraint(equalTo: mainImageIcon.bottomAnchor, constant: 15),
            welcomeMessageLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            askAnithingButton.topAnchor.constraint(equalTo: welcomeMessageLabel.bottomAnchor, constant: 20),
            askAnithingButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            askAnithingButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            askAnithingButton.heightAnchor.constraint(equalToConstant: 58),
            
            leftCard.topAnchor.constraint(equalTo: askAnithingButton.bottomAnchor, constant: 40),
            leftCard.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            leftCard.widthAnchor.constraint(equalTo: rightTopCard.widthAnchor),
            leftCard.heightAnchor.constraint(equalToConstant: 313),
            
            rightTopCard.topAnchor.constraint(equalTo: askAnithingButton.bottomAnchor, constant: 40),
            rightTopCard.leadingAnchor.constraint(equalTo: leftCard.trailingAnchor, constant: 12),
            rightTopCard.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            rightTopCard.heightAnchor.constraint(equalToConstant: 152.5),
            
            rightBottomCard.topAnchor.constraint(equalTo: rightTopCard.bottomAnchor, constant: 12),
            rightBottomCard.leadingAnchor.constraint(equalTo: rightTopCard.leadingAnchor),
            rightBottomCard.trailingAnchor.constraint(equalTo: rightTopCard.trailingAnchor),
            rightBottomCard.heightAnchor.constraint(equalToConstant: 152.5)
        ])
    }
    
    // MARK: - Actions
    
    @objc private func askButtonTapped() {
        presenter.didTapAskbutton()
    }
    
    @objc private func openVideoVC() {
        presenter.didTapVideoCard()
    }
    
    @objc private func settingsButtonTapped() {
        presenter.didTapSettings()
    }
    
    @objc private func showComingSoonAlert() {
        let alert = UIAlertController(
            title: "Coming Soon",
            message: "Use the feature to turn photos into videos or ask anything in chat",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

