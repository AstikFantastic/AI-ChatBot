import UIKit

final class PayWallVC: UIViewController {
    
    private let presenter: PayWallPresenterProtocol
    
    private let mainLabel = PaywallLabelView(text: "Create anything\nyou want",
                                             image: nil,
                                             font: UIFont(name: "Inter-Bold", size: 34) ?? UIFont.systemFont(ofSize: 34),
                                             lines: 2
    )
    
    private let firstLabel = PaywallLabelView(text: "Get results in seconds",
                                              image: UIImage(named:"Vector 2"),
                                              font: UIFont(name: "Inter-Regular", size: 16) ?? UIFont.systemFont(ofSize: 16),
                                              lines: 1
    )
    
    private let secondLabel = PaywallLabelView(text: "Turn any text into better writing",
                                               image: UIImage(named: "magicPencil"),
                                               font: UIFont(name: "Inter-Regular", size: 16) ?? UIFont.systemFont(ofSize: 16),
                                               lines: 1
    )
    
    private let thirdLabel = PaywallLabelView(text: "Simplify complex information",
                                              image: UIImage(named: "vector"),
                                              font: UIFont(name: "Inter-Regular", size: 16) ?? UIFont.systemFont(ofSize: 16),
                                              lines: 1
    )
    
    private let fourthLabel = PaywallLabelView(text: "Create content with AI templates",
                                               image: UIImage(named: "Vector 1"),
                                               font: UIFont(name: "Inter-Regular", size: 16) ?? UIFont.systemFont(ofSize: 16),
                                               lines: 1
    )
    
    private lazy var yearPaymentButton = PaymentOptionView(title: "Year $1.27 / week",
                                                           price: "$ 69.99",
                                                           showBadge: true
    )
    
    private lazy var monthPaymentButton = PaymentOptionView(title: "Month $1.99 / week",
                                                            price: "$ 7.99",
                                                            showBadge: false
    )
    
    private var selectedPaymentOption: PaymentOptionView?
    
    private let cancelAnyTimeLabel = PaywallLabelView(text: "Cancel Anytime",
                                                      image: UIImage(named: "symbol"),
                                                      font: UIFont(name: "SF-Pro-Display-Regular.otf", size: 12) ?? UIFont.systemFont(ofSize: 12),
                                                      lines: 1
    )
    
    private let unlockNowButton = UIButton()
    private let privacyButton = UIButton()
    private let restoreButton = UIButton()
    private let termsButton = UIButton()
    private let closeButton = UIButton()
    
    init(presenter: PayWallPresenterProtocol) {
        self.presenter = presenter
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        
        setupUI()
        showCloseButton()
        presenter.viewDidLoad()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        unlockNowButton.addGradientToButtonBackground(colors: [UIColor(hex: "#98C6F7"), UIColor(hex: "#EB5B92")])
    }
    
    // MARK: - Setuo UI
    
    private func setupUI() {
        setupGradientBackground()
        setupPaymentButtons()
        setupUnlockButton()
        setupFooterButtons()
        setupCloseButton()
        setupSubviews()
        setupConstraints()
        
        selectedPaymentOption = yearPaymentButton
        yearPaymentButton.setSelected(true)
    }
    
    private func setupSubviews() {
        view.addSubview(mainLabel)
        view.addSubview(firstLabel)
        view.addSubview(secondLabel)
        view.addSubview(thirdLabel)
        view.addSubview(fourthLabel)
        view.addSubview(yearPaymentButton)
        view.addSubview(monthPaymentButton)
        view.addSubview(cancelAnyTimeLabel)
        view.addSubview(unlockNowButton)
        view.addSubview(privacyButton)
        view.addSubview(restoreButton)
        view.addSubview(termsButton)
        view.addSubview(closeButton)
    }
    
    private func setupConstraints() {
        mainLabel.translatesAutoresizingMaskIntoConstraints = false
        firstLabel.translatesAutoresizingMaskIntoConstraints = false
        secondLabel.translatesAutoresizingMaskIntoConstraints = false
        thirdLabel.translatesAutoresizingMaskIntoConstraints = false
        fourthLabel.translatesAutoresizingMaskIntoConstraints = false
        yearPaymentButton.translatesAutoresizingMaskIntoConstraints = false
        monthPaymentButton.translatesAutoresizingMaskIntoConstraints = false
        cancelAnyTimeLabel.translatesAutoresizingMaskIntoConstraints = false
        unlockNowButton.translatesAutoresizingMaskIntoConstraints = false
        privacyButton.translatesAutoresizingMaskIntoConstraints = false
        restoreButton.translatesAutoresizingMaskIntoConstraints = false
        termsButton.translatesAutoresizingMaskIntoConstraints = false
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            mainLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 147),
            mainLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 61.5),
            mainLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -61.5),
            
            firstLabel.topAnchor.constraint(equalTo: mainLabel.bottomAnchor, constant: 32),
            firstLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 61.5),
            
            secondLabel.topAnchor.constraint(equalTo: firstLabel.bottomAnchor, constant: 8),
            secondLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 61.5),
            
            thirdLabel.topAnchor.constraint(equalTo: secondLabel.bottomAnchor, constant: 8),
            thirdLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 61.5),
            
            fourthLabel.topAnchor.constraint(equalTo: thirdLabel.bottomAnchor, constant: 8),
            fourthLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 61.5),
            
            yearPaymentButton.topAnchor.constraint(equalTo: fourthLabel.bottomAnchor, constant: 32),
            yearPaymentButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            yearPaymentButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            yearPaymentButton.heightAnchor.constraint(equalToConstant: 68),
            
            monthPaymentButton.topAnchor.constraint(equalTo: yearPaymentButton.bottomAnchor, constant: 12),
            monthPaymentButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            monthPaymentButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            monthPaymentButton.heightAnchor.constraint(equalToConstant: 68),
            
            cancelAnyTimeLabel.topAnchor.constraint(equalTo: monthPaymentButton.bottomAnchor, constant: 32),
            cancelAnyTimeLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            unlockNowButton.topAnchor.constraint(equalTo: cancelAnyTimeLabel.bottomAnchor, constant: 16),
            unlockNowButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            unlockNowButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            unlockNowButton.heightAnchor.constraint(equalToConstant: 56),
            
            privacyButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -8),
            privacyButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            
            restoreButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -8),
            restoreButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            termsButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -8),
            termsButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            
            closeButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            closeButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            closeButton.widthAnchor.constraint(equalToConstant: 32),
            closeButton.heightAnchor.constraint(equalToConstant: 32),
        ])
    }
    
    //MARK: - Methods
    
    private func showCloseButton() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { [weak self] in
            UIView.animate(withDuration: 0.3) {
                self?.closeButton.alpha = 1
            }
        }
    }
    
    private func setupPaymentButtons() {
        yearPaymentButton.addTarget(self, action: #selector(paymentOptionTapped(_:)), for: .touchUpInside)
        monthPaymentButton.addTarget(self, action: #selector(paymentOptionTapped(_:)), for: .touchUpInside)
    }
    
    private func setupUnlockButton() {
        
        
        unlockNowButton.backgroundColor = .white
        unlockNowButton.layer.cornerRadius = 24
        unlockNowButton.setTitle("Unlock Now", for: .normal)
        unlockNowButton.setTitleColor(.white, for: .normal)
        unlockNowButton.titleLabel?.font = UIFont(name: "Inter-Bold", size: 18) ?? UIFont.boldSystemFont(ofSize: 18)
        unlockNowButton.addTarget(self, action: #selector(unlockNowTapped), for: .touchUpInside)
    }
    
    private func setupFooterButtons() {
        privacyButton.setTitle("Privacy", for: .normal)
        privacyButton.setTitleColor(.white.withAlphaComponent(0.6), for: .normal)
        privacyButton.titleLabel?.font = UIFont(name: "Inter-Regular", size: 12) ?? UIFont.systemFont(ofSize: 12)
        privacyButton.addTarget(self, action: #selector(privacyTapped), for: .touchUpInside)
        
        restoreButton.setTitle("Restore", for: .normal)
        restoreButton.setTitleColor(.white.withAlphaComponent(0.6), for: .normal)
        restoreButton.titleLabel?.font = UIFont(name: "Inter-Regular", size: 12) ?? UIFont.systemFont(ofSize: 12)
        restoreButton.addTarget(self, action: #selector(restoreTapped), for: .touchUpInside)
        
        termsButton.setTitle("Terms of Use", for: .normal)
        termsButton.setTitleColor(.white.withAlphaComponent(0.6), for: .normal)
        termsButton.titleLabel?.font = UIFont(name: "Inter-Regular", size: 12) ?? UIFont.systemFont(ofSize: 12)
        termsButton.addTarget(self, action: #selector(termsTapped), for: .touchUpInside)
    }
    
    private func setupCloseButton() {
        closeButton.setImage(UIImage(systemName: "xmark"), for: .normal)
        closeButton.tintColor = UIColor.white.withAlphaComponent(0.2)
        closeButton.backgroundColor = .clear
        closeButton.layer.cornerRadius = 16
        closeButton.alpha = 0
        closeButton.addTarget(self, action: #selector(closeTapped), for: .touchUpInside)
    }
    
    // MARK: - Actions
    
    @objc private func paymentOptionTapped(_ sender: PaymentOptionView) {
        selectedPaymentOption?.setSelected(false)
        sender.setSelected(true)
        selectedPaymentOption = sender
        
        if sender == yearPaymentButton {
            presenter.didSelectYearOption()
        } else {
            presenter.didSelectMonthOption()
        }
    }
    
    @objc private func closeTapped() {
        presenter.didTapClose()
    }
    
    @objc private func unlockNowTapped() {
        presenter.didTapUnlockNow()
    }
    
    @objc private func restoreTapped() {
        presenter.didTapRestore()
    }
    
    @objc private func privacyTapped() {
        presenter.didTapPrivacy()
    }
    
    @objc private func termsTapped() {
        presenter.didTapTerms()
    }
}

// MARK: - PayWallViewProtocol

extension PayWallVC: PayWallViewProtocol {
    
    func showLoading() {
        unlockNowButton.isEnabled = false
        restoreButton.isEnabled = false
        view.isUserInteractionEnabled = false
    }
    
    func hideLoading() {
        unlockNowButton.isEnabled = true
        restoreButton.isEnabled = true
        view.isUserInteractionEnabled = true
    }
    
    func updateYearOption(title: String, price: String, badge: String?) {
        yearPaymentButton.updateTitle(title)
        yearPaymentButton.updatePrice(price)
        
        if let badge = badge {
            yearPaymentButton.updateBadge(badge)
            yearPaymentButton.showDiscountBadge()
        }
    }
    
    func updateMonthOption(title: String, price: String) {
        monthPaymentButton.updateTitle(title)
        monthPaymentButton.updatePrice(price)
    }
    
    func showError(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    func showSuccess(title: String, message: String, completion: (() -> Void)?) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
            completion?()
        })
        present(alert, animated: true)
    }
    
    func dismissView() {
        dismiss(animated: true)
    }
}
