import UIKit

final class TemplateDetailsViewController: UIViewController, TemplateDetailsViewProtocol {
    
    private let presenter: TemplateDetailsPresenterProtocol
    private var imagePicker: ImagePickerVC?
    private let customNavBar = UIView()
    private let backButton = UIButton()
    private let titleLabel = UILabel()
    private var collectionView: UICollectionView!
    private let carouselContainerView = UIView()
    private let addPhotoButton = UIButton()
    private let removePhotoButton = UIButton()
    private let fotmatButton = UIButton()
    private let quallityButton = UIButton()
    private let createButton = UIButton()
    private let activityIndicator = UIActivityIndicatorView(style: .large)
    private var selectedFormat: String = "16:9"
    private var selectedQuality: String = "1080p"
    
    private var isScrollingProgrammatically = false
    
    init(presenter: TemplateDetailsPresenterProtocol) {
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
        collectionView.alpha = 0
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        scrollToTemplateInternal(at: presenter.currentTemplateIndex(), animated: false)
        
        UIView.animate(withDuration: 0.2) {
            self.collectionView.alpha = 1
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        addPhotoButton.addGradientBorder(colors: [UIColor(hex: "#98C6F7"), UIColor(hex: "#EB5B92")], cornerRadius: 16)
    }
    
    // MARK: - Setup UI
    
    private func setupUI() {
        setupCustomNavigationBar()
        
        view.backgroundColor = .black
        
        setupCarouselView()
        
        addPhotoButton.setImage(UIImage(systemName: "plus",
                                        withConfiguration: UIImage.SymbolConfiguration(pointSize: 24, weight: .regular)),for: .normal)
        addPhotoButton.tintColor = .white
        addPhotoButton.imageView?.contentMode = .scaleAspectFill
        addPhotoButton.clipsToBounds = true
        view.addSubview(addPhotoButton)
        addPhotoButton.translatesAutoresizingMaskIntoConstraints = false
        addPhotoButton.addTarget(self, action: #selector(addPhotoButtonTapped), for: .touchUpInside)
        
        let xmarkIcon = UIImage(systemName: "xmark",
                                withConfiguration: UIImage.SymbolConfiguration(pointSize: 14.73, weight: .thin))
        let gradienXmark = xmarkIcon?.withGradient(colors: [
            UIColor(hex: "#98C6F7"),
            UIColor(hex: "#EB5B92")
        ])
        removePhotoButton.backgroundColor = .white
        removePhotoButton.tintColor = nil
        removePhotoButton.setImage(gradienXmark, for: .normal)
        removePhotoButton.layer.cornerRadius = 16
        removePhotoButton.clipsToBounds = true
        removePhotoButton.isHidden = true
        removePhotoButton.addTarget(self, action: #selector(removePhotoButtonTapped), for: .touchUpInside)
        view.addSubview(removePhotoButton)
        removePhotoButton.translatesAutoresizingMaskIntoConstraints = false
        
        fotmatButton.layer.cornerRadius = 24
        fotmatButton.backgroundColor = UIColor.white.withAlphaComponent(0.1)
        fotmatButton.contentHorizontalAlignment = .left
        fotmatButton.addTarget(self, action: #selector(formatButtonTapped), for: .touchUpInside)
        view.addSubview(fotmatButton)
        fotmatButton.translatesAutoresizingMaskIntoConstraints = false
        updateFormatButton()
        
        quallityButton.layer.cornerRadius = 24
        quallityButton.backgroundColor = UIColor.white.withAlphaComponent(0.1)
        quallityButton.contentHorizontalAlignment = .left
        quallityButton.addTarget(self, action: #selector(qualityButtonTapped), for: .touchUpInside)
        view.addSubview(quallityButton)
        quallityButton.translatesAutoresizingMaskIntoConstraints = false
        updateQualityButton()
        
        createButton.setTitle("Create", for: .normal)
        createButton.backgroundColor = UIColor.white.withAlphaComponent(0.15)
        createButton.setTitleColor(.white.withAlphaComponent(0.15), for: .normal)
        createButton.layer.cornerRadius = 24
        createButton.titleLabel?.font = UIFont(name: "Inter-SemiBold", size: 16)
        createButton.addTarget(self, action: #selector(generateButtonTapped), for: .touchUpInside)
        
        view.addSubview(createButton)
        createButton.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            
            carouselContainerView.topAnchor.constraint(equalTo: customNavBar.bottomAnchor, constant: 16),
            carouselContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            carouselContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            carouselContainerView.heightAnchor.constraint(equalToConstant: 331),
            
            addPhotoButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            addPhotoButton.topAnchor.constraint(equalTo: carouselContainerView.bottomAnchor, constant: 24),
            addPhotoButton.widthAnchor.constraint(equalToConstant: 100),
            addPhotoButton.heightAnchor.constraint(equalToConstant: 100),
            
            removePhotoButton.trailingAnchor.constraint(equalTo: addPhotoButton.trailingAnchor, constant: 8),
            removePhotoButton.topAnchor.constraint(equalTo: addPhotoButton.topAnchor, constant: -8),
            removePhotoButton.widthAnchor.constraint(equalToConstant: 32),
            removePhotoButton.heightAnchor.constraint(equalToConstant: 32),
            
            fotmatButton.topAnchor.constraint(equalTo: addPhotoButton.bottomAnchor, constant: 24),
            fotmatButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            fotmatButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            fotmatButton.heightAnchor.constraint(equalToConstant: 60),
            
            quallityButton.topAnchor.constraint(equalTo: fotmatButton.bottomAnchor, constant: 8),
            quallityButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            quallityButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            quallityButton.heightAnchor.constraint(equalToConstant: 60),
            
            createButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            createButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            createButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            createButton.heightAnchor.constraint(equalToConstant: 50),
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
    
    // MARK: - Actions
    
    @objc private func backButtonTapped() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc private func addPhotoButtonTapped() {
        presenter.didTapAddPhoto()
    }
    
    @objc private func removePhotoButtonTapped() {
        presenter.didTapRemovePhoto()
    }
    
    @objc private func generateButtonTapped() {
        presenter.didTapCreate(format: selectedFormat, quality: selectedQuality)
    }
    
    // MARK: - Setup Carousel
    
    private func setupCarouselView() {
        carouselContainerView.backgroundColor = .clear
        view.addSubview(carouselContainerView)
        carouselContainerView.translatesAutoresizingMaskIntoConstraints = false
        
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 16
        layout.itemSize = CGSize(width: 280, height: 331)
        
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.decelerationRate = .fast
        collectionView.contentInset = UIEdgeInsets(top: 0, left: (UIScreen.main.bounds.width - 280) / 2, 
                                                     bottom: 0, right: (UIScreen.main.bounds.width - 280) / 2)
        collectionView.register(TemplateCarouselCell.self, forCellWithReuseIdentifier: "TemplateCarouselCell")
        
        carouselContainerView.addSubview(collectionView)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: carouselContainerView.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: carouselContainerView.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: carouselContainerView.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: carouselContainerView.bottomAnchor)
        ])
    }
    
    private func scrollToTemplateInternal(at index: Int, animated: Bool) {
        guard presenter.templatesCount > 0, index < presenter.templatesCount else { return }
        
        isScrollingProgrammatically = true
        collectionView.scrollToItem(at: IndexPath(item: index, section: 0),
                                    at: .centeredHorizontally,
                                    animated: animated)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
            self?.isScrollingProgrammatically = false
        }
    }
    
    func updateTitle(_ title: String) {
        titleLabel.text = title
    }
    
    @objc private func formatButtonTapped() {
        let formats = ["16:9", "9:16", "1:1"]
        let picker = CustomPickerView(options: formats, selectedOption: selectedFormat) { [weak self] format in
            guard let self = self else { return }
            self.selectedFormat = format
            self.updateFormatButton()
        }
        picker.show(in: view)
    }
    
    @objc private func qualityButtonTapped() {
        let qualities = ["540p", "720p", "1080p", "4K"]
        let picker = CustomPickerView(options: qualities, selectedOption: selectedQuality) { [weak self] quality in
            guard let self = self else { return }
            self.selectedQuality = quality
            self.updateQualityButton()
        }
        picker.show(in: view)
    }
    
    // MARK: - Methods
    
    private func updateFormatButton() {
        
        fotmatButton.viewWithTag(100)?.removeFromSuperview()
        fotmatButton.viewWithTag(101)?.removeFromSuperview()
        
        let titleLabel = UILabel()
        titleLabel.tag = 100
        titleLabel.text = "Format"
        titleLabel.font = UIFont(name: "Inter-Regular", size: 16) ?? UIFont.systemFont(ofSize: 16)
        titleLabel.textColor = UIColor.white.withAlphaComponent(0.6)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let valueLabel = UILabel()
        valueLabel.tag = 101
        valueLabel.text = selectedFormat
        valueLabel.font = UIFont(name: "Inter-Regular", size: 16) ?? UIFont.systemFont(ofSize: 16)
        valueLabel.textColor = .white
        valueLabel.translatesAutoresizingMaskIntoConstraints = false
        
        fotmatButton.addSubview(titleLabel)
        fotmatButton.addSubview(valueLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: fotmatButton.leadingAnchor, constant: 20),
            titleLabel.centerYAnchor.constraint(equalTo: fotmatButton.centerYAnchor),
            
            valueLabel.trailingAnchor.constraint(equalTo: fotmatButton.trailingAnchor, constant: -20),
            valueLabel.centerYAnchor.constraint(equalTo: fotmatButton.centerYAnchor)
        ])
    }
    
    private func updateQualityButton() {

        quallityButton.viewWithTag(200)?.removeFromSuperview()
        quallityButton.viewWithTag(201)?.removeFromSuperview()
        
        let titleLabel = UILabel()
        titleLabel.tag = 200
        titleLabel.text = "Quality"
        titleLabel.font = UIFont(name: "Inter-Regular", size: 16) ?? UIFont.systemFont(ofSize: 16)
        titleLabel.textColor = UIColor.white.withAlphaComponent(0.6)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let valueLabel = UILabel()
        valueLabel.tag = 201
        valueLabel.text = selectedQuality
        valueLabel.font = UIFont(name: "Inter-Regular", size: 16) ?? UIFont.systemFont(ofSize: 16)
        valueLabel.textColor = .white
        valueLabel.translatesAutoresizingMaskIntoConstraints = false
        
        quallityButton.addSubview(titleLabel)
        quallityButton.addSubview(valueLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: quallityButton.leadingAnchor, constant: 20),
            titleLabel.centerYAnchor.constraint(equalTo: quallityButton.centerYAnchor),
            
            valueLabel.trailingAnchor.constraint(equalTo: quallityButton.trailingAnchor, constant: -20),
            valueLabel.centerYAnchor.constraint(equalTo: quallityButton.centerYAnchor)
        ])
    }
    
    // MARK: - TemplateDetailsViewProtocol
    
    func showPhotoPicker() {
        imagePicker = ImagePickerVC(presentationController: self)
        imagePicker?.presentImagePicker { [weak self] image in
            self?.presenter.didSelectPhoto(image)
        }
    }
    
    func updatePhotoPreview(_ image: UIImage) {
        addPhotoButton.setImage(image, for: .normal)
        addPhotoButton.imageView?.layer.cornerRadius = 16
        addPhotoButton.removeTarget(self, action: #selector(addPhotoButtonTapped), for: .touchUpInside)
    }
    
    func clearPhotoPreview() {
        addPhotoButton.addTarget(self, action: #selector(addPhotoButtonTapped), for: .touchUpInside)
        addPhotoButton.setBackgroundImage(nil, for: .normal)
        addPhotoButton.setImage(UIImage(systemName: "plus",
                                        withConfiguration: UIImage.SymbolConfiguration(pointSize: 24, weight: .regular)), for: .normal)
        addPhotoButton.tintColor = .white
    }
    
    func enableCreateButton() {
        createButton.backgroundColor = .clear
        createButton.addGradientToButtonBackground(colors: [UIColor(hex: "#98C6F7"), UIColor(hex: "#EB5B92")])
        createButton.setTitleColor(.white, for: .normal)
    }
    
    func disableCreateButton() {
        createButton.removeGradient()
        createButton.backgroundColor = UIColor.white.withAlphaComponent(0.15)
        createButton.setTitleColor(.white.withAlphaComponent(0.15), for: .normal)
    }
    
    func showRemovePhotoButton() {
        removePhotoButton.isHidden = false
    }
    
    func hideRemovePhotoButton() {
        removePhotoButton.isHidden = true
    }
    
    func showLoading() {
        createButton.isEnabled = false
        activityIndicator.startAnimating()
        createButton.setTitle("", for: .normal)
    }
    
    func hideLoading() {
        activityIndicator.stopAnimating()
        createButton.isEnabled = true
        createButton.setTitle("Create", for: .normal)
    }
    
    func showSuccess(_ message: String) {
        let alert = UIAlertController(title: "Успешно", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "ОК", style: .default))
        present(alert, animated: true)
    }
    
    func showError(_ message: String) {
        let alert = UIAlertController(title: "Ошибка", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "ОК", style: .default))
        present(alert, animated: true)
    }
    
    func reloadCarousel() {
        collectionView.reloadData()
    }
    
    func scrollToTemplate(at index: Int, animated: Bool) {
        guard presenter.templatesCount > 0, index < presenter.templatesCount else { return }
        
        isScrollingProgrammatically = true
        collectionView.scrollToItem(at: IndexPath(item: index, section: 0),
                                    at: .centeredHorizontally,
                                    animated: animated)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
            self?.isScrollingProgrammatically = false
        }
    }
}
// MARK: - UICollectionView DataSource & Delegate

extension TemplateDetailsViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return presenter.templatesCount
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TemplateCarouselCell", for: indexPath) as! TemplateCarouselCell
        let template = presenter.templateAt(index: indexPath.item)
        let isCenter = indexPath.item == presenter.currentTemplateIndex()
        cell.configure(with: template, isCenter: isCenter)
        return cell
    }
}

// MARK: - UIScrollViewDelegate

extension TemplateDetailsViewController: UIScrollViewDelegate {
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        guard !isScrollingProgrammatically else { return }
        
        let layout = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        let cellWidthIncludingSpacing = layout.itemSize.width + layout.minimumLineSpacing
        
        let offset = targetContentOffset.pointee.x + scrollView.contentInset.left
        let index = round(offset / cellWidthIncludingSpacing)
        
        let safeIndex = max(0, min(Int(index), presenter.templatesCount - 1))
        
        targetContentOffset.pointee.x = CGFloat(safeIndex) * cellWidthIncludingSpacing - scrollView.contentInset.left
        
        presenter.didScrollToTemplate(at: safeIndex)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let centerX = scrollView.contentOffset.x + scrollView.bounds.width / 2
        
        for cell in collectionView.visibleCells {
            guard let indexPath = collectionView.indexPath(for: cell),
                  let carouselCell = cell as? TemplateCarouselCell else { continue }
            
            let cellCenterX = collectionView.layoutAttributesForItem(at: indexPath)?.center.x ?? 0
            let distance = abs(centerX - cellCenterX)
            
            let maxDistance: CGFloat = 200
            let scale = max(0.85, 1 - (distance / maxDistance) * 0.15)
            let dimAlpha = min(1.0, distance / 150)
            
            carouselCell.updateScale(scale)
            carouselCell.updateDimAlpha(dimAlpha)
        }
    }
}

