import UIKit

protocol ChatInputBarDelegate: AnyObject {
    func chatInputBar(_ bar: ChatInputBar, didSend text: String)
}

final class ChatInputBar: UIView {
    
    weak var delegate: ChatInputBarDelegate?
    
    private let maxNumberOfLines: CGFloat = 3
    private let verticalPadding: CGFloat = 8
    private let horizontalPadding: CGFloat = 16
    private let buttonSize: CGFloat = 36
    private let cornerRadius: CGFloat = 22
    
    private let textView: UITextView = {
        let tv = UITextView()
        tv.backgroundColor = .clear
        tv.font = .systemFont(ofSize: 17)
        tv.textColor = .white
        tv.tintColor = .white
        tv.keyboardAppearance = .dark
        tv.isScrollEnabled = false
        tv.textContainerInset = UIEdgeInsets(top: 8, left: 4, bottom: 8, right: 4)
        tv.autocorrectionType = .no
        tv.spellCheckingType = .no
        tv.translatesAutoresizingMaskIntoConstraints = false
        return tv
    }()
    
    private let placeholderLabel: UILabel = {
        let label = UILabel()
        label.text = "Ask anything..."
        label.font = .systemFont(ofSize: 17)
        label.textColor = UIColor(white: 1, alpha: 0.4)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let sendButton: GradientSendButton = {
        let button = GradientSendButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.alpha = 0
        button.isHidden = true
        return button
    }()
    
    private var textViewHeight: NSLayoutConstraint!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    override var intrinsicContentSize: CGSize { .zero }
    
    // MARK: - Setup UI
    
    private func setup() {
        autoresizingMask = .flexibleHeight
        
        backgroundColor = UIColor(red: 0.09, green: 0.09, blue: 0.10, alpha: 1)
        layer.cornerRadius = cornerRadius
        layer.masksToBounds = true
        
        addSubview(textView)
        addSubview(placeholderLabel)
        addSubview(sendButton)
        
        textView.delegate = self
        sendButton.addTarget(self, action: #selector(sendTapped), for: .touchUpInside)
        
        let minHeight = minTextViewHeight()
        textViewHeight = textView.heightAnchor.constraint(equalToConstant: minHeight)
        
        NSLayoutConstraint.activate([
            textView.topAnchor.constraint(equalTo: topAnchor, constant: verticalPadding),
            textView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: horizontalPadding),
            textView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor,
                                             constant: -verticalPadding),
            
            textViewHeight,
            
            placeholderLabel.leadingAnchor.constraint(equalTo: textView.leadingAnchor,constant: textView.textContainerInset.left + 5),
            placeholderLabel.topAnchor.constraint(equalTo: textView.topAnchor,constant: textView.textContainerInset.top),
            
            sendButton.leadingAnchor.constraint(equalTo: textView.trailingAnchor, constant: 8),
            sendButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -horizontalPadding),
            sendButton.centerYAnchor.constraint(equalTo: textView.centerYAnchor),
            sendButton.widthAnchor.constraint(equalToConstant: buttonSize),
            sendButton.heightAnchor.constraint(equalToConstant: buttonSize),
        ])
        
        updateSendState()
    }
    
    func clear() {
        textView.text = ""
        textViewDidChange(textView)
    }
    
    // MARK: - Actions
    @objc private func sendTapped() {
        let text = textView.text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return }
        delegate?.chatInputBar(self, didSend: text)
        clear()
    }
    
    // MARK: - Sizing helpers
    private func minTextViewHeight() -> CGFloat {
        (textView.font?.lineHeight ?? 20) +
        textView.textContainerInset.top + textView.textContainerInset.bottom
    }
    
    private func maxTextViewHeight() -> CGFloat {
        ceil((textView.font?.lineHeight ?? 20) * maxNumberOfLines) +
        textView.textContainerInset.top + textView.textContainerInset.bottom
    }
    
    private func updateSendState() {
        let hasText = !textView.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        sendButton.isEnabled = hasText
        
        UIView.animate(withDuration: 0.2) {
            self.sendButton.alpha = hasText ? 1.0 : 0.0
        }
        
        if hasText && sendButton.isHidden {
            sendButton.isHidden = false
        } else if !hasText && !sendButton.isHidden {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                self.sendButton.isHidden = true
            }
        }
    }
}

// MARK: - UITextViewDelegate

extension ChatInputBar: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        placeholderLabel.isHidden = !textView.text.isEmpty
        updateSendState()
        
        let fitting = textView.sizeThatFits(
            CGSize(width: textView.bounds.width, height: .greatestFiniteMagnitude)
        )
        let target = min(max(fitting.height, minTextViewHeight()), maxTextViewHeight())
        
        let shouldScroll = fitting.height > maxTextViewHeight()
        
        if textViewHeight.constant != target || textView.isScrollEnabled != shouldScroll {
            textViewHeight.constant = target
            textView.isScrollEnabled = shouldScroll

            invalidateIntrinsicContentSize()
        }
    }
}
