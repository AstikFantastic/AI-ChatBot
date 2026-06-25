//
//  SceneDelegate.swift
//  AI ChatBot
//
//  Created by Астимир Марышев on 6/19/26.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    private var coordinator: Coordinator?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let scene = (scene as? UIWindowScene) else { return }
        window = UIWindow(windowScene: scene)
        let nav = UINavigationController()
        let coordinator = Coordinator(navigationController: nav)
        self.coordinator = coordinator
        coordinator.start()
        
        // Всегда показываем главный экран (paywall будет показан при клике на Turn Photo)
        window?.rootViewController = nav
        window?.makeKeyAndVisible()
        
        // Подписываемся на изменения подписки
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(subscriptionStatusChanged),
            name: PurchaseManager.didUpdateAccess,
            object: nil
        )
    }
    
    @objc private func subscriptionStatusChanged() {
        guard let window = window else { return }
        
        // После покупки открываем главный экран
        if PurchaseManager.shared.hasPremium {
            guard let nav = coordinator?.navigationController else { return }
            
            UIView.transition(with: window, duration: 0.3, options: .transitionCrossDissolve) {
                window.rootViewController = nav
            }
        }
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
        
        NotificationCenter.default.removeObserver(self)
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }


}

