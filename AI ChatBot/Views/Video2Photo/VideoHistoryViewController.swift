import UIKit

final class VideoHistoryViewController: UIViewController {
    
    private let presenter: VideoHistoryPresenterProtocol
    private var historyItems: [VideoHistoryItem] = []
    
    private let customNavBar = UIView()
    private let backButton = UIButton()
    private let titleLabel = UILabel()
    
    private var collectionView: UICollectionView!

    private let emptyStateView = UIView()
    private let emptyIconImageView = UIImageView()
    private let emptyTitleLabel = UILabel()
    private let emptySubtitleLabel = UILabel()
    
    init(presenter: VideoHistoryPresenterProtocol) {
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        presenter.viewWillAppear()
    }
    
    // MARK: - Setup UI
    
    private func setupUI() {
        view.backgroundColor = .black
        
        setupCustomNavigationBar()
        setupEmptyState()
        setupCollectionView()
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
        
        titleLabel.text = "AI Video History"
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
    
    private func setupEmptyState() {
        emptyStateView.backgroundColor = .black
        emptyStateView.isHidden = true
        view.addSubview(emptyStateView)
        emptyStateView.translatesAutoresizingMaskIntoConstraints = false
        
        if let customIcon = UIImage(named: "Vector 1") {
            emptyIconImageView.image = customIcon
        } else { 
            emptyIconImageView.image = UIImage(systemName: "video.slash.circle")
            emptyIconImageView.tintColor = UIColor(red: 0.6, green: 0.4, blue: 0.9, alpha: 1)
        }
        emptyIconImageView.contentMode = .scaleAspectFit
        emptyStateView.addSubview(emptyIconImageView)
        emptyIconImageView.translatesAutoresizingMaskIntoConstraints = false
    
        emptyTitleLabel.text = "No videos yet"
        emptyTitleLabel.textColor = .white
        emptyTitleLabel.font = UIFont(name: "Inter-SemiBold", size: 20)
        emptyTitleLabel.textAlignment = .center
        emptyStateView.addSubview(emptyTitleLabel)
        emptyTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        emptySubtitleLabel.text = "Create your first video to see it here"
        emptySubtitleLabel.textColor = UIColor.white.withAlphaComponent(0.6)
        emptySubtitleLabel.font = UIFont(name: "Inter-Regular", size: 14)
        emptySubtitleLabel.textAlignment = .center
        emptySubtitleLabel.numberOfLines = 2
        emptyStateView.addSubview(emptySubtitleLabel)
        emptySubtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            emptyStateView.topAnchor.constraint(equalTo: customNavBar.bottomAnchor),
            emptyStateView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            emptyStateView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            emptyStateView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            emptyIconImageView.centerXAnchor.constraint(equalTo: emptyStateView.centerXAnchor),
            emptyIconImageView.centerYAnchor.constraint(equalTo: emptyStateView.centerYAnchor, constant: -60),
            emptyIconImageView.widthAnchor.constraint(equalToConstant: 80),
            emptyIconImageView.heightAnchor.constraint(equalToConstant: 80),
            
            emptyTitleLabel.topAnchor.constraint(equalTo: emptyIconImageView.bottomAnchor, constant: 24),
            emptyTitleLabel.centerXAnchor.constraint(equalTo: emptyStateView.centerXAnchor),
            emptyTitleLabel.leadingAnchor.constraint(equalTo: emptyStateView.leadingAnchor, constant: 40),
            emptyTitleLabel.trailingAnchor.constraint(equalTo: emptyStateView.trailingAnchor, constant: -40),
            
            emptySubtitleLabel.topAnchor.constraint(equalTo: emptyTitleLabel.bottomAnchor, constant: 8),
            emptySubtitleLabel.centerXAnchor.constraint(equalTo: emptyStateView.centerXAnchor),
            emptySubtitleLabel.leadingAnchor.constraint(equalTo: emptyStateView.leadingAnchor, constant: 40),
            emptySubtitleLabel.trailingAnchor.constraint(equalTo: emptyStateView.trailingAnchor, constant: -40)
        ])
    }
    
    private func setupCollectionView() {
        let layout = PinterestLayout()
        layout.delegate = self
        layout.numberOfColumns = 2
        layout.cellPadding = 6
        
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .black
        collectionView.dataSource = self
        collectionView.contentInset = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        collectionView.register(HistoryCell.self, forCellWithReuseIdentifier: "HistoryCell")
        view.addSubview(collectionView)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: customNavBar.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    // MARK: - Actions
    
    @objc private func backButtonTapped() {
        presenter.didTapBackButton()
    }
}

// MARK: - VideoHistoryViewProtocol

extension VideoHistoryViewController: VideoHistoryViewProtocol {
    
    func showHistoryItems(_ items: [VideoHistoryItem]) {
        self.historyItems = items
        collectionView.reloadData()
    }
    
    func showEmptyState() {
        emptyStateView.isHidden = false
        collectionView.isHidden = true
    }
    
    func hideEmptyState() {
        emptyStateView.isHidden = true
        collectionView.isHidden = false
    }
}

// MARK: - UICollectionViewDataSource

extension VideoHistoryViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return historyItems.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HistoryCell", for: indexPath) as! HistoryCell
        let item = historyItems[indexPath.item]
        cell.configure(with: item)
        return cell
    }
}

// MARK: - PinterestLayoutDelegate

extension VideoHistoryViewController: PinterestLayoutDelegate {
    func collectionView(_ collectionView: UICollectionView, heightForPhotoAtIndexPath indexPath: IndexPath) -> CGFloat {
        return presenter.heightForItem(at: indexPath.item)
    }
}
