import Foundation

final class VideoHistoryPresenter: VideoHistoryPresenterProtocol {
    
    weak var view: VideoHistoryViewProtocol?
    private weak var coordinator: VideoHistoryCoordinatorProtocol?
    
    private var historyItems: [VideoHistoryItem] = []
    private let historyManager: VideoHistoryManagerProtocol
    
    init(
        coordinator: VideoHistoryCoordinatorProtocol,
        historyManager: VideoHistoryManagerProtocol = VideoHistoryManager.shared
    ) {
        self.coordinator = coordinator
        self.historyManager = historyManager
    }
    
    // MARK: - VideoHistoryPresenterProtocol
    
    func viewDidLoad() {
        loadHistory()
    }
    
    func viewWillAppear() {
        loadHistory()
    }
    
    func didTapBackButton() {
        coordinator?.dismissHistory()
    }
    
    func heightForItem(at index: Int) -> CGFloat {
        let heights: [CGFloat] = [200, 250, 300, 220, 280, 240]
        return heights[index % heights.count]
    }
    
    // MARK: -  Methods
    
    private func loadHistory() {
        historyItems = historyManager.loadHistory()
        updateView()
    }
    
    private func updateView() {
        if historyItems.isEmpty {
            view?.showEmptyState()
        } else {
            view?.hideEmptyState()
            view?.showHistoryItems(historyItems)
        }
    }
}
