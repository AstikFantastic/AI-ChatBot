import UIKit

final class ChatViewController: UIViewController {
    
    var presenter: ChatPresenterProtocol!
    weak var coordinator: ChatCoordinatorProtocol?
    
    private let customBar = UIView()
    private let backButton = UIButton()
    private let navStack = UIStackView()
    private let titleLabel = UILabel()
    private let iconImageView = UIImageView()
    private let chatDate = UILabel()
    private let historyButton = UIButton()
    private let scrollView = UIScrollView()
    private let messagesStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 8
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private let emptyLabel = UILabel()
    private let emptySubtitleLabel = UILabel()
    
    private let loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.color = .white
        indicator.hidesWhenStopped = true
        indicator.translatesAutoresizingMaskIntoConstraints = false
        return indicator
    }()
    
    private var thinkingBubble: ThinkingBubbleView?
    
    private lazy var chatInputBar: ChatInputBar = {
        let bar = ChatInputBar(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: 60))
        bar.delegate = self
        return bar
    }()
    
    override var inputAccessoryView: UIView? {
        return chatInputBar
    }
    
    override var canBecomeFirstResponder: Bool {
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if presenter == nil {
            presenter = ChatPresenter(chatId: "", userId: "ApphudUserID", appId: "com.test.test")
            (presenter as? ChatPresenter)?.view = self
        }
        
        setupUI()
        setupKeyboardObservers()
        presenter.viewDidLoad()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        becomeFirstResponder()
    }
    
    // MARK: - Setup UI
    
    private func setupUI() {
        view.backgroundColor = .black
        
        setupCustomNavigationBar()
        setupScrollView()
        setupEmptyState()
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
        
        iconImageView.image = UIImage(named: "aiChatIcon")
        customBar.addSubview(iconImageView)
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        
        navStack.axis = .vertical
        navStack.spacing = 2
        navStack.translatesAutoresizingMaskIntoConstraints = false
        
        titleLabel.text = "AI Chat"
        titleLabel.textColor = .white
        titleLabel.font = UIFont(name: "Inter-SemiBold", size: 20)
        
        setChatDate(Date())
        
        navStack.addArrangedSubview(titleLabel)
        navStack.addArrangedSubview(chatDate)
        customBar.addSubview(navStack)
        
        historyButton.setImage(UIImage(named: "Union"), for: .normal)
        historyButton.tintColor = .white
        historyButton.addTarget(self, action: #selector(historyButtonTapped), for: .touchUpInside)
        customBar.addSubview(historyButton)
        historyButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            customBar.topAnchor.constraint(equalTo: view.topAnchor),
            customBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            customBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            customBar.heightAnchor.constraint(equalToConstant: 100),
            
            backButton.leadingAnchor.constraint(equalTo: customBar.leadingAnchor, constant: 12),
            backButton.bottomAnchor.constraint(equalTo: customBar.bottomAnchor, constant: -12),
            backButton.widthAnchor.constraint(equalToConstant: 32),
            backButton.heightAnchor.constraint(equalToConstant: 32),
            
            iconImageView.leadingAnchor.constraint(equalTo: backButton.trailingAnchor, constant: 12),
            iconImageView.centerYAnchor.constraint(equalTo: backButton.centerYAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 32),
            iconImageView.heightAnchor.constraint(equalToConstant: 32),
            
            navStack.leadingAnchor.constraint(equalTo: iconImageView.trailingAnchor, constant: 8),
            navStack.centerYAnchor.constraint(equalTo: backButton.centerYAnchor),
            
            historyButton.trailingAnchor.constraint(equalTo: customBar.trailingAnchor, constant: -16),
            historyButton.centerYAnchor.constraint(equalTo: backButton.centerYAnchor),
            historyButton.widthAnchor.constraint(equalToConstant: 24),
            historyButton.heightAnchor.constraint(equalToConstant: 24)
        ])
    }
    
    // MARK: - Methods
    
    func setChatDate(_ date: Date) {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy"
        chatDate.text = formatter.string(from: date)
        chatDate.textColor = .lightGray
        chatDate.font = UIFont(name: "Inter-Regular", size: 14)
    }
    
    private func setupScrollView() {
        scrollView.showsVerticalScrollIndicator = false
        scrollView.keyboardDismissMode = .interactive
        view.addSubview(scrollView)
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        
        scrollView.addSubview(messagesStackView)
        
        view.addSubview(loadingIndicator)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        scrollView.addGestureRecognizer(tapGesture)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: customBar.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            messagesStackView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor, constant: 16),
            messagesStackView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            messagesStackView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            messagesStackView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor, constant: -16),
            messagesStackView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor),
            
            loadingIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingIndicator.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -80)
        ])
    }
    
    func setupEmptyState() {
        let fullText = "Your AI assistant for anything"
        let attributedText = NSMutableAttributedString(string: fullText)
        attributedText.addAttribute(.font, value: UIFont(name: "Inter-SemiBold", size: 20) ?? UIFont.boldSystemFont(ofSize: 20), range: NSRange(location: 0, length: fullText.count))
        attributedText.addAttribute(.foregroundColor, value: UIColor.white, range: NSRange(location: 0, length: fullText.count))
        if let range = fullText.range(of: "AI assistant") {
            let nsRange = NSRange(range, in: fullText)
            let gradientColors = [UIColor(hex: "#98C6F7"), UIColor(hex: "#EB5B92")]
            let gradientImage = createGradientImage(colors: gradientColors, size: CGSize(width: 200, height: 24))
            let gradientColor = UIColor(patternImage: gradientImage)
            attributedText.addAttribute(.foregroundColor, value: gradientColor, range: nsRange)
        }
        
        emptyLabel.attributedText = attributedText
        emptyLabel.textAlignment = .center
        emptyLabel.numberOfLines = 0
        view.addSubview(emptyLabel)
        emptyLabel.translatesAutoresizingMaskIntoConstraints = false
        
        emptySubtitleLabel.text = "Ask questions, get answers, and explore ideas in seconds"
        emptySubtitleLabel.font = UIFont(name: "Inter-Regular", size: 14)
        emptySubtitleLabel.textColor = .lightGray
        emptySubtitleLabel.numberOfLines = 0
        emptySubtitleLabel.textAlignment = .center
        view.addSubview(emptySubtitleLabel)
        emptySubtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            emptyLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -100),
            emptyLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            emptyLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),
            
            emptySubtitleLabel.topAnchor.constraint(equalTo: emptyLabel.bottomAnchor, constant: 10),
            emptySubtitleLabel.leadingAnchor.constraint(equalTo: emptyLabel.leadingAnchor),
            emptySubtitleLabel.trailingAnchor.constraint(equalTo: emptyLabel.trailingAnchor)
        ])
    }
    
    func hideEmptyState() {
        UIView.animate(withDuration: 0.3) {
            self.emptyLabel.alpha = 0
            self.emptySubtitleLabel.alpha = 0
        } completion: { _ in
            self.emptyLabel.isHidden = true
            self.emptySubtitleLabel.isHidden = true
        }
    }
    
    func showEmptyState() {
        emptyLabel.isHidden = false
        emptySubtitleLabel.isHidden = false
        UIView.animate(withDuration: 0.3) {
            self.emptyLabel.alpha = 1
            self.emptySubtitleLabel.alpha = 1
        }
    }
    
    private func setupKeyboardObservers() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }
    // MARK: - Actions
    
    @objc private func keyboardWillShow(_ notification: Notification) {
        guard let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
        guard let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double else { return }
        
        let keyboardHeight = keyboardFrame.height
        
        scrollView.contentInset.bottom = keyboardHeight
        scrollView.verticalScrollIndicatorInsets.bottom = keyboardHeight
        
        UIView.animate(withDuration: duration) {
            self.view.layoutIfNeeded()
        }
    }
    
    @objc private func keyboardWillHide(_ notification: Notification) {
        guard let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double else { return }
        
        scrollView.contentInset.bottom = 0
        scrollView.verticalScrollIndicatorInsets.bottom = 0
        
        UIView.animate(withDuration: duration) {
            self.view.layoutIfNeeded()
        }
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @objc private func backButtonTapped() {
        coordinator?.didTapBack()
    }
    
    @objc private func historyButtonTapped() {
        coordinator?.didTapHistory()
    }
}

// MARK: - ChatInputBarDelegate

extension ChatViewController: ChatInputBarDelegate {
    func chatInputBar(_ bar: ChatInputBar, didSend text: String) {
        if messagesStackView.arrangedSubviews.isEmpty {
            hideEmptyState()
        }
        presenter.sendMessage(text)
    }
}

// MARK: - ChatViewProtocol

extension ChatViewController: ChatViewProtocol {
    func displayMessage(_ message: MessageBubble) {
        hideEmptyState()
        
        let bubbleView = MessageBubbleView()
        bubbleView.configure(with: message)
        bubbleView.translatesAutoresizingMaskIntoConstraints = false
        messagesStackView.addArrangedSubview(bubbleView)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.scrollToBottom()
        }
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
        showThinkingAnimation()
    }
    
    func hideLoading() {
        loadingIndicator.stopAnimating()
        hideThinkingAnimation()
    }
    
    func clearMessages() {
        messagesStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        showEmptyState()
    }
    
    private func showThinkingAnimation() {
        hideThinkingAnimation()
        let thinking = ThinkingBubbleView()
        thinking.translatesAutoresizingMaskIntoConstraints = false
        thinking.alpha = 0
        
        messagesStackView.addArrangedSubview(thinking)
        thinkingBubble = thinking
        
        UIView.animate(withDuration: 0.3) {
            thinking.alpha = 1
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.scrollToBottom()
        }
    }
    
    private func hideThinkingAnimation() {
        guard let thinking = thinkingBubble else { return }
        
        UIView.animate(withDuration: 0.3, animations: {
            thinking.alpha = 0
        }) { _ in
            thinking.removeFromSuperview()
            self.thinkingBubble = nil
        }
    }
    
    private func scrollToBottom() {
        let bottomOffset = CGPoint(x: 0, y: max(0, scrollView.contentSize.height - scrollView.bounds.height + scrollView.contentInset.bottom)
        )
        scrollView.setContentOffset(bottomOffset, animated: true)
    }
}

