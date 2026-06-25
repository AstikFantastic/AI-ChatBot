import UIKit

final class CustomPickerView: UIView {

    private let containerView = UIView()
    private let tableView = UITableView()

    private var options: [String] = []
    private var selectedOption: String
    private var onSelect: ((String) -> Void)?

    init(options: [String], selectedOption: String, onSelect: @escaping (String) -> Void) {
        self.options = options
        self.selectedOption = selectedOption
        self.onSelect = onSelect
        super.init(frame: .zero)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        backgroundColor = .clear

        let dimView = UIView()
        dimView.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        dimView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(dimView)

        NSLayoutConstraint.activate([
            dimView.topAnchor.constraint(equalTo: topAnchor),
            dimView.bottomAnchor.constraint(equalTo: bottomAnchor),
            dimView.leadingAnchor.constraint(equalTo: leadingAnchor),
            dimView.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])

        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissPicker))
        dimView.addGestureRecognizer(tap)

        containerView.backgroundColor = UIColor(white: 0.15, alpha: 1.0)
        containerView.layer.cornerRadius = 12
        containerView.layer.borderWidth = 1
        containerView.layer.borderColor = UIColor(hex: "#7B61FF").cgColor
        containerView.clipsToBounds = true
        containerView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(containerView)

        tableView.backgroundColor = .clear
        tableView.separatorColor = UIColor(hex: "#7B61FF").withAlphaComponent(0.3)
        tableView.separatorStyle = .singleLine
        tableView.isScrollEnabled = false

        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(PickerCell.self, forCellReuseIdentifier: "PickerCell")

        tableView.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(tableView)

        NSLayoutConstraint.activate([
            containerView.centerYAnchor.constraint(equalTo: centerYAnchor),
            containerView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            containerView.widthAnchor.constraint(equalToConstant: 230),

            tableView.topAnchor.constraint(equalTo: containerView.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),

            tableView.heightAnchor.constraint(equalToConstant: CGFloat(options.count * 56))
        ])
    }

    @objc private func dismissPicker() {
        removeFromSuperview()
    }

    
    func show(in view: UIView) {
        frame = view.bounds
        view.addSubview(self)

        alpha = 0
        UIView.animate(withDuration: 0.25) {
            self.alpha = 1
        }
    }
}

// MARK: - UITableViewDelegate, DataSource

extension CustomPickerView: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        options.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PickerCell", for: indexPath) as! PickerCell

        let option = options[indexPath.row]
        cell.configure(with: option, isSelected: option == selectedOption)

        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        56
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selected = options[indexPath.row]

        onSelect?(selected)

        UIView.animate(withDuration: 0.15, animations: {
            self.alpha = 0
        }) { _ in
            self.removeFromSuperview()
        }
    }
}
