import ApphudSDK
import UIKit
import StoreKit

final class PurchaseManager: NSObject {

    static let shared = PurchaseManager()
    static let didUpdateAccess = Notification.Name("PurchaseManager.didUpdateAccess")
    static let didLoadProducts = Notification.Name("PurchaseManager.didLoadProducts")
    private var apphudProducts: [ApphudProduct] = []

    private override init() { super.init() }

    func configure() {
        Apphud.start(apiKey: "app_FmCjFTwjWpcLSafxT8vCDeVffJyfFS")
        Apphud.setDelegate(self)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.refreshSubscriptionStatus { hasActive in
                print("\(hasActive)")
            }
        }
    }

    var hasPremium: Bool {
        let hasSubscription = Apphud.hasActiveSubscription()
        #if targetEnvironment(simulator)
        if let subscription = Apphud.subscription() {
            let isActive = subscription.isActive()
            let expiresDate = subscription.expiresDate
            let isExpired = expiresDate < Date()
            return !isExpired && isActive
        } else {
            return false
        }
        #else
        return hasSubscription
        #endif
    }
    
    func refreshSubscriptionStatus(completion: ((Bool) -> Void)? = nil) {
        Apphud.restorePurchases { result in
            if let error = result.error {
                print("\(error.localizedDescription)")
            }
            let hasActive = self.hasPremium
            self.notifyAccessChanged()
            completion?(hasActive)
        }
    }
    
    func loadProducts() async -> [SKProduct] {
        
        return await withCheckedContinuation { continuation in
            Apphud.fetchPlacements { [weak self] placements, error in
                guard let self = self else {
                    continuation.resume(returning: [])
                    return
                }
                
                if let error = error {
                    print("\(error.localizedDescription)")
                }
                
                if let placement = placements.first(where: { $0.identifier == "main" }),
                   let paywall = placement.paywall {
                    self.apphudProducts = paywall.products
                    let products = paywall.products.compactMap { $0.skProduct }
                    if !products.isEmpty {
                        for product in products {
                            print("   - \(product.productIdentifier): \(product.localizedTitle) - \(product.price)")
                        }
                        Apphud.paywallShown(paywall)
                        continuation.resume(returning: products)
                        return
                    }
                }
            
                
                Task {
                    let products = await Apphud.fetchSKProducts(maxAttempts: 3)
                    
                    if products.isEmpty {
                        #if targetEnvironment(simulator)
                        print("NO PRODUCTS LOADED!")
                        #endif
                    } else {
                        print("Loaded \(products.count) products:")
                        for product in products {
                            print("   - \(product.productIdentifier): \(product.localizedTitle) - \(product.price)")
                        }
                    }
                    
                    continuation.resume(returning: products)
                }
            }
        }
    }

    func purchase(_ product: SKProduct) async -> Bool {
        return await withCheckedContinuation { continuation in
            if let apphudProduct = apphudProducts.first(where: { $0.productId == product.productIdentifier }) {
                Apphud.purchase(apphudProduct) { result in
                    #if targetEnvironment(simulator)
                    if let error = result.error {
                        let errorMessage = error.localizedDescription
                        if errorMessage.contains("Bundle ID") {
                            self.notifyAccessChanged()
                            continuation.resume(returning: true)
                            return
                        } else {
                            print("\(errorMessage)")
                            continuation.resume(returning: false)
                            return
                        }
                    }
                    #else
                    if let error = result.error {
                        print("\(error.localizedDescription)")
                        continuation.resume(returning: false)
                        return
                    }
                    #endif
                    
                    let success = Apphud.hasActiveSubscription()
                    self.notifyAccessChanged()
                    continuation.resume(returning: success)
                }
            } else {
                Apphud.purchase(product.productIdentifier) { result in
                    #if targetEnvironment(simulator)
                    if let error = result.error {
                        let errorMessage = error.localizedDescription
                        if errorMessage.contains("Bundle ID") {
                            self.notifyAccessChanged()
                            continuation.resume(returning: true)
                            return
                        } else {
                            print("\(errorMessage)")
                            continuation.resume(returning: false)
                            return
                        }
                    }
                    #else
                    if let error = result.error {
                        print("\(error.localizedDescription)")
                        continuation.resume(returning: false)
                        return
                    }
                    #endif
                    
                    let success = Apphud.hasActiveSubscription()
                    self.notifyAccessChanged()
                    continuation.resume(returning: success)
                }
            }
        }
    }

    func restore(completion: @escaping (Bool) -> Void) {
        
        Apphud.restorePurchases { result in
            if let error = result.error {
                print("\(error.localizedDescription)")
                completion(false)
            } else {
                print("Restore completed.")
                
                self.refreshSubscriptionStatus { hasActive in
                    completion(hasActive)
                }
            }
        }
    }

    private func notifyAccessChanged() {
        NotificationCenter.default.post(name: Self.didUpdateAccess, object: nil)
    }
}

extension PurchaseManager: ApphudDelegate {
    func apphudSubscriptionsUpdated(_ subscriptions: [ApphudSubscription]) {
        notifyAccessChanged()
    }
    
    func apphudDidFetchStoreKitProducts(_ products: [SKProduct]) {
        print("✅ Apphud loaded \(products.count) products")
        NotificationCenter.default.post(name: Self.didLoadProducts, object: products)
    }
}
