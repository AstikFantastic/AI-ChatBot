import UIKit
protocol VideoHistoryViewProtocol: AnyObject {
    func showHistoryItems(_ items: [VideoHistoryItem])
    func showEmptyState()
    func hideEmptyState()
}

protocol VideoHistoryPresenterProtocol: AnyObject {
    func viewDidLoad()
    func viewWillAppear()
    func didTapBackButton()
    func heightForItem(at index: Int) -> CGFloat
}
