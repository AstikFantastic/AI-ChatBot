import Foundation
import StoreKit

final class PayWallPresenter: PayWallPresenterProtocol {
    
    weak var view: PayWallViewProtocol?
    private let coordinator: PayWallCoordinatorProtocol
    private let purchaseManager: PurchaseManager
    
    private var yearProduct: SKProduct?
    private var monthProduct: SKProduct?
    private var isYearSelected: Bool = true
    private var isProcessing: Bool = false
    
    init(coordinator: PayWallCoordinatorProtocol,
         purchaseManager: PurchaseManager = .shared) {
        self.coordinator = coordinator
        self.purchaseManager = purchaseManager
    }
    
    // MARK: - PayWallPresenterProtocol
    
    func viewDidLoad() {
        loadProducts()
    }
    
    func didSelectYearOption() {
        isYearSelected = true
    }
    
    func didSelectMonthOption() {
        isYearSelected = false
    }
    
    func didTapUnlockNow() {
        
        guard !isProcessing else {
            return
        }
        
        let selectedProduct = isYearSelected ? yearProduct : monthProduct
        
        guard let product = selectedProduct else {
            view?.showError(title: "Error", message: "Product not loaded. Please try again.")
            return
        }
        
        performPurchase(product)
    }
    
    func didTapRestore() {
        
        guard !isProcessing else {
            return
        }
        
        performRestore()
    }
    
    func didTapPrivacy() {
        coordinator.openPrivacyPolicy()
    }
    
    func didTapTerms() {
        coordinator.openTermsOfUse()
    }
    
    func didTapClose() {
        coordinator.dismissPaywall()
    }
    
    // MARK: - Methods
    
    private func loadProducts() {
        view?.showLoading()
        
        Task {
            let products = await purchaseManager.loadProducts()
            
            await MainActor.run {
                self.view?.hideLoading()
                
                if products.isEmpty {
                    self.updateViewWithDefaultPrices()
                } else {
                    self.processLoadedProducts(products)
                }
            }
        }
    }
    
    private func processLoadedProducts(_ products: [SKProduct]) {
        if products.count > 0 {
            yearProduct = products[0]
        }
        if products.count > 1 {
            monthProduct = products[1]
        }
        
        updateViewWithProductPrices()
    }
    
    private func updateViewWithProductPrices() {
        if let yearProduct = yearProduct {
            let yearPrice = yearProduct.localizedPrice()
            let weeklyPrice = calculateWeeklyPrice(from: yearProduct, period: 52)
            let badge = calculateSavingsBadge()
            
            view?.updateYearOption(
                title: "Year \(weeklyPrice) / week",
                price: yearPrice,
                badge: badge
            )
        } else {
            view?.updateYearOption(
                title: "Year $1.27 / week",
                price: "$ 69.99",
                badge: "SAVE 27%"
            )
        }
        
        if let monthProduct = monthProduct {
            let monthPrice = monthProduct.localizedPrice()
            let weeklyPrice = calculateWeeklyPrice(from: monthProduct, period: 4)
            
            view?.updateMonthOption(
                title: "Month \(weeklyPrice) / week",
                price: monthPrice
            )
        } else {
            view?.updateMonthOption(
                title: "Month $1.99 / week",
                price: "$ 7.99"
            )
        }
    }
    
    private func updateViewWithDefaultPrices() {
        view?.updateYearOption(
            title: "Year $1.27 / week",
            price: "$ 69.99",
            badge: "SAVE 27%"
        )
        
        view?.updateMonthOption(
            title: "Month $1.99 / week",
            price: "$ 7.99"
        )
    }
    
    private func calculateWeeklyPrice(from product: SKProduct, period weeksInPeriod: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = product.priceLocale
        formatter.maximumFractionDigits = 2
        
        let weeklyPrice = product.price.doubleValue / Double(weeksInPeriod)
        let weeklyNumber = NSNumber(value: weeklyPrice)
        
        return formatter.string(from: weeklyNumber) ?? "$\(String(format: "%.2f", weeklyPrice))"
    }
    
    private func calculateSavingsBadge() -> String? {
        let yearlyTotal: Double
        let monthlyTotal: Double
        
        if let yearProduct = yearProduct {
            yearlyTotal = yearProduct.price.doubleValue
        } else {
            yearlyTotal = 69.99
        }
        
        if let monthProduct = monthProduct {
            monthlyTotal = monthProduct.price.doubleValue * 12
        } else {
            monthlyTotal = 7.99 * 12
        }
        
        if monthlyTotal > 0 {
            let savings = ((monthlyTotal - yearlyTotal) / monthlyTotal) * 100
            return "SAVE \(Int(savings))%"
        }
        
        return nil
    }
    
    private func performPurchase(_ product: SKProduct) {
        isProcessing = true
        view?.showLoading()
        
        Task {
            let success = await purchaseManager.purchase(product)
            
            await MainActor.run {
                self.isProcessing = false
                self.view?.hideLoading()
                
                if success {
                    self.view?.dismissView()
                } else {
                    self.view?.showError(
                        title: "Purchase Failed",
                        message: "Unable to complete purchase. Please try again."
                    )
                }
            }
        }
    }
    
    private func performRestore() {
        isProcessing = true
        view?.showLoading()
        
        purchaseManager.restore { [weak self] success in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                self.isProcessing = false
                self.view?.hideLoading()
                
                if success {
                    self.view?.showSuccess(
                        title: "Success",
                        message: "Purchases restored successfully!"
                    ) {
                        self.view?.dismissView()
                    }
                } else {
                    self.view?.showError(
                        title: "No Purchases",
                        message: "No active subscriptions found."
                    )
                }
            }
        }
    }
}

// MARK: - SKProduct Extension

extension SKProduct {
    func localizedPrice() -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = priceLocale
        return formatter.string(from: price) ?? "\(price)"
    }
}
