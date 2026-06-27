import UIKit

final class ChatHistoryViewController: UIViewController {
    
    var presenter: ChatHistoryPresenterProtocol!
    weak var coordinator: ChatHistoryCoordinatorProtocol?
    
    private let customBar = UIView()
    private let backButton = UIButton()
    private let titleLabel = UILabel()
    
    private let tableView: UITableView = {
        let tv = UITableView(frame: .zero, style: .grouped)
        tv.backgroundColor = .black
        tv.separatorStyle = .none
        tv.sectionHeaderTopPadding = 0
        tv.translatesAutoresizingMaskIntoConstraints = false
        return tv
    }()
    
    private let emptyStateView: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        view.isHidden = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let emptyIconImageView: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(systemName: "bubble.left.and.bubble.right")
        iv.tintColor = UIColor(white: 0.3, alpha: 1.0)
        iv.contentMode = .scaleAspectFit
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    private let emptyLabel: UILabel = {
        let label = UILabel()
        label.text = "No chats yet"
        label.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
        label.textColor = .white
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let emptySubtitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Start a conversation to see\nyour history here"
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .lightGray
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.color = .white
        indicator.hidesWhenStopped = true
        indicator.translatesAutoresizingMaskIntoConstraints = false
        return indicator
    }()
    
    private var sections: [ChatHistorySection] = []
    private var isFirstAppearance = true
    private var shouldRefreshOnAppear = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if isFirstAppearance {
            presenter?.viewDidLoad()
            isFirstAppearance = false
        } else if shouldRefreshOnAppear {
            presenter?.refreshChats()
            shouldRefreshOnAppear = false
        }
    }
    
    private func setupUI() {
        view.backgroundColor = .black
        
        setupCustomNavigationBar()
        
        view.addSubview(tableView)
        view.addSubview(emptyStateView)
        view.addSubview(loadingIndicator)
        
        emptyStateView.addSubview(emptyIconImageView)
        emptyStateView.addSubview(emptyLabel)
        emptyStateView.addSubview(emptySubtitleLabel)
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(ChatHistoryCell.self, forCellReuseIdentifier: ChatHistoryCell.identifier)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: customBar.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            emptyStateView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            emptyStateView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            emptyStateView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            emptyStateView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            emptyIconImageView.centerXAnchor.constraint(equalTo: emptyStateView.centerXAnchor),
            emptyIconImageView.centerYAnchor.constraint(equalTo: emptyStateView.centerYAnchor, constant: -60),
            emptyIconImageView.widthAnchor.constraint(equalToConstant: 80),
            emptyIconImageView.heightAnchor.constraint(equalToConstant: 80),
            
            emptyLabel.topAnchor.constraint(equalTo: emptyIconImageView.bottomAnchor, constant: 20),
            emptyLabel.leadingAnchor.constraint(equalTo: emptyStateView.leadingAnchor, constant: 40),
            emptyLabel.trailingAnchor.constraint(equalTo: emptyStateView.trailingAnchor, constant: -40),
            
            emptySubtitleLabel.topAnchor.constraint(equalTo: emptyLabel.bottomAnchor, constant: 8),
            emptySubtitleLabel.leadingAnchor.constraint(equalTo: emptyLabel.leadingAnchor),
            emptySubtitleLabel.trailingAnchor.constraint(equalTo: emptyLabel.trailingAnchor),
            
            loadingIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    private func setupCustomNavigationBar() {
        customBar.backgroundColor = .black
        view.addSubview(customBar)
        customBar.translatesAutoresizingMaskIntoConstraints = false
        
        backButton.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        backButton.tintColor = .white
        backButton.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
        customBar.addSubview(backButton)
        backButton.translatesAutoresizingMaskIntoConstraints = false
        
        titleLabel.text = "AI Chat History"
        titleLabel.textAlignment = .center
        titleLabel.textColor = .white
        titleLabel.font = UIFont(name: "Inter-SemiBold", size: 20) ?? UIFont.systemFont(ofSize: 20, weight: .semibold)
        customBar.addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            customBar.topAnchor.constraint(equalTo: view.topAnchor),
            customBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            customBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            customBar.heightAnchor.constraint(equalToConstant: 100),
            
            backButton.leadingAnchor.constraint(equalTo: customBar.leadingAnchor, constant: 12),
            backButton.bottomAnchor.constraint(equalTo: customBar.bottomAnchor, constant: -12),
            backButton.widthAnchor.constraint(equalToConstant: 32),
            backButton.heightAnchor.constraint(equalToConstant: 32),
            
            titleLabel.leadingAnchor.constraint(equalTo: backButton.trailingAnchor, constant: 12),
            titleLabel.centerYAnchor.constraint(equalTo: backButton.centerYAnchor),
            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: customBar.trailingAnchor, constant: -16)
        ])
    }
    
    @objc private func backButtonTapped() {
        coordinator?.didTapBack()
    }
    
    @objc private func handleRefresh() {
        presenter?.refreshChats()
    }
}

// MARK: - UITableViewDataSource & Delegate

extension ChatHistoryViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].chats.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ChatHistoryCell.identifier, for: indexPath) as? ChatHistoryCell else {
            return UITableViewCell()
        }
        
        let chat = sections[indexPath.section].chats[indexPath.row]
        cell.configure(with: chat)
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sections[section].title
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.01
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        if let header = view as? UITableViewHeaderFooterView {
            header.textLabel?.textColor = UIColor(white: 0.5, alpha: 1.0)
            header.textLabel?.font = UIFont(name: "Inter-SemiBold", size: 13) ?? UIFont.systemFont(ofSize: 13, weight: .semibold)
            header.contentView.backgroundColor = .black
            
            header.backgroundView = UIView()
            header.backgroundView?.backgroundColor = .black
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var flatIndex = 0
        for i in 0..<indexPath.section {
            flatIndex += sections[i].chats.count
        }
        flatIndex += indexPath.row
        
        shouldRefreshOnAppear = true
    }
}

// MARK: - ChatHistoryViewProtocol

extension ChatHistoryViewController: ChatHistoryViewProtocol {
    
    func displayChats(_ sections: [ChatHistorySection]) {
        self.sections = sections
        tableView.reloadData()
    }
    
    func showError(_ message: String) {
        let alert = UIAlertController(
            title: "Error",
            message: message,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    func showLoading() {
        loadingIndicator.startAnimating()
    }
    
    func hideLoading() {
        loadingIndicator.stopAnimating()
    }
    
    func showEmptyState() {
        emptyStateView.isHidden = false
        tableView.isHidden = true
    }
    
    func hideEmptyState() {
        emptyStateView.isHidden = true
        tableView.isHidden = false
    }
}
