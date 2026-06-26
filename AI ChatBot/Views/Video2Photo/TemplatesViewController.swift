import UIKit

final class TemplatesViewController: UIViewController, TemplatesViewProtocol {

    private let presenter: TemplatesPresenterProtocol

    private var filteredTemplates: [VideoTemplate] = []
    private var categories: [String] = []

    private let customNavBar = UIView()
    private let backButton = UIButton()
    private let titleLabel = UILabel()
    private let iconImageView = UIImageView()
    private let refreshButton = UIButton()
    
    private let categoryScrollView = UIScrollView()
    private let categoryStackView = UIStackView()
    
    private var collectionView: UICollectionView!
    private let activityIndicator = UIActivityIndicatorView(style: .large)
    private let errorLabel = UILabel()

    init(presenter: TemplatesPresenterProtocol) {
        self.presenter = presenter
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        presenter.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    // MARK: - TemplatesViewProtocol

    func showLoading() {
        errorLabel.isHidden = true
        collectionView.isHidden = true
        categoryScrollView.isHidden = true
        activityIndicator.startAnimating()
    }

    func showTemplates(_ templates: [VideoTemplate]) {
        self.filteredTemplates = templates
        
        activityIndicator.stopAnimating()
        errorLabel.isHidden = true
        collectionView.isHidden = false
        categoryScrollView.isHidden = false
        
        collectionView.reloadData()
    }
    
    func showCategories(_ categories: [String]) {
        self.categories = categories
        setupCategoryButtons()
    }
    
    func updateFilteredTemplates(_ templates: [VideoTemplate]) {
        self.filteredTemplates = templates
        collectionView.reloadData()
    }
    
    func navigateBack() {
        navigationController?.popViewController(animated: true)
    }

    func showError(_ message: String) {
        activityIndicator.stopAnimating()
        collectionView.isHidden = true
        categoryScrollView.isHidden = true
        errorLabel.text = message
        errorLabel.isHidden = false
    }
    
    func showPhotoPermissionAlert() {
        
        let alert = UIAlertController(
            title: "Allow access to photos?",
            message: "To upload an image, the app needs access to your photo gallery.",
            preferredStyle: .alert
        )
        
        
        let titleAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont(name: "Inter-SemiBold", size: 17) ?? UIFont.boldSystemFont(ofSize: 17),
            .foregroundColor: UIColor.black
        ]
        let attributedTitle = NSAttributedString(string: "Allow access to photos?", attributes: titleAttributes)
        alert.setValue(attributedTitle, forKey: "attributedTitle")
        
        let messageAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont(name: "Inter-Regular", size: 13) ?? UIFont.systemFont(ofSize: 13),
            .foregroundColor: UIColor.black.withAlphaComponent(0.6)
        ]
        let attributedMessage = NSAttributedString(string: "To upload an image, the app needs access to your photo gallery.", attributes: messageAttributes)
        alert.setValue(attributedMessage, forKey: "attributedMessage")
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) {_ in 
            return
        }
        cancelAction.setValue(UIColor(red: 0.38, green: 0.64, blue: 0.97, alpha: 1.0), forKey: "titleTextColor")
        alert.addAction(cancelAction)
        
        let allowAction = UIAlertAction(title: "Allow", style: .default) { _ in

            if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
                if UIApplication.shared.canOpenURL(settingsUrl) {
                    UIApplication.shared.open(settingsUrl)
                }
            }
        }
        allowAction.setValue(UIColor.black, forKey: "titleTextColor")
        alert.addAction(allowAction)
        
        present(alert, animated: true)
    }

    // MARK: - Setup

    private func setupUI() {
        view.backgroundColor = .black
        
        setupCustomNavigationBar()
        setupCategoryScrollView()
        setupCollectionView()
        setupActivityIndicator()
        setupErrorLabel()
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
    
        iconImageView.image = UIImage(named: "frame") ?? UIImage(systemName: "person.fill")
        customNavBar.addSubview(iconImageView)
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        
        titleLabel.text = "AI Video"
        titleLabel.font = UIFont(name: "Inter-SemiBold", size: 20)
        titleLabel.textColor = .white
        customNavBar.addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        refreshButton.setImage(UIImage(named: "Union"), for: .normal)
        refreshButton.tintColor = .white
        refreshButton.addTarget(self, action: #selector(refreshButtonTapped), for: .touchUpInside)
        customNavBar.addSubview(refreshButton)
        refreshButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            customNavBar.topAnchor.constraint(equalTo: view.topAnchor),
            customNavBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            customNavBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            customNavBar.heightAnchor.constraint(equalToConstant: 100),
            
            backButton.leadingAnchor.constraint(equalTo: customNavBar.leadingAnchor, constant: 12),
            backButton.bottomAnchor.constraint(equalTo: customNavBar.bottomAnchor, constant: -12),
            backButton.widthAnchor.constraint(equalToConstant: 32),
            backButton.heightAnchor.constraint(equalToConstant: 32),
            
            iconImageView.leadingAnchor.constraint(equalTo: backButton.trailingAnchor, constant: 12),
            iconImageView.centerYAnchor.constraint(equalTo: backButton.centerYAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 32),
            iconImageView.heightAnchor.constraint(equalToConstant: 32),
            
            titleLabel.leadingAnchor.constraint(equalTo: iconImageView.trailingAnchor, constant: 8),
            titleLabel.centerYAnchor.constraint(equalTo: backButton.centerYAnchor),
            
            refreshButton.trailingAnchor.constraint(equalTo: customNavBar.trailingAnchor, constant: -16),
            refreshButton.centerYAnchor.constraint(equalTo: backButton.centerYAnchor),
            refreshButton.widthAnchor.constraint(equalToConstant: 24),
            refreshButton.heightAnchor.constraint(equalToConstant: 24)
        ])
    }
    
    private func setupCategoryScrollView() {
        categoryScrollView.showsHorizontalScrollIndicator = false
        categoryScrollView.contentInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        view.addSubview(categoryScrollView)
        categoryScrollView.translatesAutoresizingMaskIntoConstraints = false
        
        categoryStackView.axis = .horizontal
        categoryStackView.spacing = 5
        categoryStackView.distribution = .fillProportionally
        categoryScrollView.addSubview(categoryStackView)
        categoryStackView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            categoryScrollView.topAnchor.constraint(equalTo: customNavBar.bottomAnchor, constant: 8),
            categoryScrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            categoryScrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            categoryScrollView.heightAnchor.constraint(equalToConstant: 33),
            
            categoryStackView.topAnchor.constraint(equalTo: categoryScrollView.topAnchor),
            categoryStackView.leadingAnchor.constraint(equalTo: categoryScrollView.leadingAnchor),
            categoryStackView.trailingAnchor.constraint(equalTo: categoryScrollView.trailingAnchor),
            categoryStackView.bottomAnchor.constraint(equalTo: categoryScrollView.bottomAnchor),
            categoryStackView.heightAnchor.constraint(equalTo: categoryScrollView.heightAnchor)
        ])
    }
    
    private func setupCategoryButtons() {
        categoryStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        for category in categories {
            let button = createCategoryButton(title: category)
            categoryStackView.addArrangedSubview(button)
        }
    }
    
    private func createCategoryButton(title: String) -> UIButton {
        let button = UIButton(type: .system)
        var config = UIButton.Configuration.plain()
        config.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16)
        button.configuration = config
        button.setTitle(title, for: .normal)
        button.titleLabel?.font = UIFont(name: "Inter-Regular", size: 14)
        button.layer.cornerRadius = 16
        button.clipsToBounds = true
        button.addTarget(self, action: #selector(categoryButtonTapped), for: .touchUpInside)
        button.backgroundColor = UIColor.white.withAlphaComponent(0.15)
        button.setTitleColor(.white, for: .normal)
        return button
    }
    
    private func updateCategoryButtonStyle(_ button: UIButton, isSelected: Bool) {
        if isSelected {
            button.backgroundColor = .clear
            button.layoutIfNeeded()
            button.addGradientToButtonBackground(colors: [UIColor(hex: "#98C6F7"), UIColor(hex: "#EB5B92")])
            button.setTitleColor(.white, for: .normal)
        } else {
            button.removeGradient()
            button.backgroundColor = UIColor.white.withAlphaComponent(0.15)
            button.setTitleColor(.white, for: .normal)
        }
    }
    
    private func setupCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumInteritemSpacing = 12
        layout.minimumLineSpacing = 12
        layout.sectionInset = UIEdgeInsets(top: 12, left: 16, bottom: 12, right: 16)
        
        let width = (UIScreen.main.bounds.width - 44) / 2 // 16 + 16 + 12 (отступы)
        layout.itemSize = CGSize(width: width, height: width * 1.4)
        
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .black
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(TemplateCell.self, forCellWithReuseIdentifier: "TemplateCell")
        view.addSubview(collectionView)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: categoryScrollView.bottomAnchor, constant: 8),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func setupActivityIndicator() {
        activityIndicator.color = .white
        view.addSubview(activityIndicator)
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    private func setupErrorLabel() {
        errorLabel.textAlignment = .center
        errorLabel.numberOfLines = 0
        errorLabel.textColor = .systemRed
        errorLabel.isHidden = true
        view.addSubview(errorLabel)
        errorLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            errorLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            errorLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            errorLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            errorLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
    }
    
    // MARK: - Actions
    
    @objc private func backButtonTapped() {
        presenter.didTapBackButton()
    }
    
    @objc private func refreshButtonTapped() {
        presenter.didTapHistoryButton()
    }
    
    @objc private func categoryButtonTapped(_ sender: UIButton) {
        guard let category = sender.titleLabel?.text else { return }
        
        categoryStackView.arrangedSubviews.compactMap { $0 as? UIButton }.forEach { button in
            updateCategoryButtonStyle(button, isSelected: button == sender)
        }
        
        presenter.didSelectCategory(category)
    }
}

// MARK: - UICollectionViewDataSource / Delegate

extension TemplatesViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return filteredTemplates.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TemplateCell", for: indexPath) as! TemplateCell
        let template = filteredTemplates[indexPath.item]
        cell.configure(with: template)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let template = filteredTemplates[indexPath.item]
        presenter.didSelectTemplate(template, fromFilteredList: filteredTemplates, atIndex: indexPath.item)
    }
}
