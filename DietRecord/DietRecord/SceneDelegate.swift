//
//  SceneDelegate.swift
//  DietRecord
//
//  Created by chun on 2022/10/29.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?
    var savedShortCutItem: UIApplicationShortcutItem?
    
    func windowScene(_ windowScene: UIWindowScene, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Void) {
        let handled = handleShortCutItem(shortcutItem: shortcutItem)
        completionHandler(handled)
    }
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        guard scene as? UIWindowScene != nil else { return }
        maybeOpenedFromWidget(urlContexts: connectionOptions.urlContexts)
        
        if let shortcutItem = connectionOptions.shortcutItem {
            savedShortCutItem = shortcutItem
        }
    }
    
    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        maybeOpenedFromWidget(urlContexts: URLContexts)
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
        // ???app???badgeValue??????0
        UIApplication.shared.applicationIconBadgeNumber = 0
        if let savedShortCutItem = savedShortCutItem {
            _ = handleShortCutItem(shortcutItem: savedShortCutItem)
        }
        savedShortCutItem = nil
    }

    func sceneWillResignActive(_ scene: UIScene) {
        var shortcutItems = UIApplication.shared.shortcutItems ?? []
        shortcutItems += [
            UIApplicationShortcutItem(
                type: ShortcutItemType.water.rawValue,
                localizedTitle: "???????????????",
                localizedSubtitle: "",
                icon: UIApplicationShortcutIcon(templateImageName: "Image_WaterIcon")),
            UIApplicationShortcutItem(
                type: ShortcutItemType.weight.rawValue,
                localizedTitle: "??????????????????",
                localizedSubtitle: "",
                icon: UIApplicationShortcutIcon(templateImageName: "Image_WeightIcon")),
            UIApplicationShortcutItem(
                type: ShortcutItemType.dietRecord.rawValue,
                localizedTitle: "??????????????????",
                localizedSubtitle: "",
                icon: UIApplicationShortcutIcon(templateImageName: "Image_DietIcon")),
            UIApplicationShortcutItem(
                type: ShortcutItemType.report.rawValue,
                localizedTitle: "??????????????????",
                localizedSubtitle: "",
                icon: UIApplicationShortcutIcon(systemImageName: "chart.bar.xaxis"))
        ]
        
        UIApplication.shared.shortcutItems = shortcutItems
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
    
    private func maybeOpenedFromWidget(urlContexts: Set<UIOpenURLContext>) {
        if let _: UIOpenURLContext = urlContexts.first(where: { $0.url.scheme == "Water-Widget" }) {
            DRConstant.groupUserDefaults?.set(1, forKey: "OpenWithWidget")
            print("???? Launched from water widget")
            if let navigationController = window?.rootViewController as? UINavigationController {
                navigationController.popToRootViewController(animated: false)
            }
        } else if let _: UIOpenURLContext = urlContexts.first(where: { $0.url.scheme == "Diet-Widget" }) {
            DRConstant.groupUserDefaults?.set(2, forKey: "OpenWithWidget")
            print("???? Launched from diet widget")
            if let navigationController = window?.rootViewController as? UINavigationController {
                navigationController.popToRootViewController(animated: false)
            }
        }
    }
    
    func handleShortCutItem(shortcutItem: UIApplicationShortcutItem) -> Bool {
        if let itemType = ShortcutItemType(rawValue: shortcutItem.type) {
            switch itemType {
            case .water:
                DRConstant.groupUserDefaults?.set(true, forKey: ShortcutItemType.water.rawValue)
            case .weight:
                DRConstant.groupUserDefaults?.set(true, forKey: ShortcutItemType.weight.rawValue)
            case .dietRecord:
                DRConstant.groupUserDefaults?.set(true, forKey: ShortcutItemType.dietRecord.rawValue)
            case .report:
                DRConstant.groupUserDefaults?.set(true, forKey: ShortcutItemType.report.rawValue)
            }
            if let navigationController = window?.rootViewController as? UINavigationController {
                navigationController.popToRootViewController(animated: false)
            }
        }
        return true
    }
}
