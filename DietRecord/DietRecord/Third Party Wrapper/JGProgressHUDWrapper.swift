//
//  JGProgressHUDWrapper.swift
//  DietRecord
//
//  Created by chun on 2022/11/10.
//

import JGProgressHUD

enum HUDType {
    case success(String)
    case failure(String)
}

class DRProgressHUD {
    static let shared = DRProgressHUD()

    private init() { }

    let hud = JGProgressHUD(style: .dark)
    
    var view: UIView {
        /*
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
            let sceneDelegate = windowScene.delegate as? SceneDelegate,
            let view = sceneDelegate.window?.rootViewController?.view
        else { fatalError("Could not find view.") }
        return view
         */
        guard let window = UIApplication.shared.windows.first,
              let view = window.rootViewController?.view
        else { return UIView() }
        return view
    }

    static func show(type: HUDType) {
        switch type {
        case .success(let text):
            showSuccess(text: text)
        case .failure(let text):
            showFailure(text: text)
        }
    }

    static func showSuccess(text: String = "success") {
        if !Thread.isMainThread {
            DispatchQueue.main.async {
                showSuccess(text: text)
            }
            return
        }
        shared.hud.textLabel.text = text
        shared.hud.indicatorView = JGProgressHUDSuccessIndicatorView()
        shared.hud.show(in: shared.view)
        shared.hud.dismiss(afterDelay: 0.5)
    }

    static func showFailure(text: String = "Failure") {
        if !Thread.isMainThread {
            DispatchQueue.main.async {
                showFailure(text: text)
            }
            return
        }
        shared.hud.textLabel.text = text
        shared.hud.indicatorView = JGProgressHUDErrorIndicatorView()
        shared.hud.show(in: shared.view)
        shared.hud.dismiss(afterDelay: 0.5)
    }

    static func show() {
        if !Thread.isMainThread {
            DispatchQueue.main.async {
                show()
            }
            return
        }
        shared.hud.indicatorView = JGProgressHUDIndeterminateIndicatorView()
        shared.hud.textLabel.text = "Loading"
        shared.hud.show(in: shared.view)
    }

    static func dismiss() {
        if !Thread.isMainThread {
            DispatchQueue.main.async {
                dismiss()
            }
            return
        }
        shared.hud.dismiss()
    }
}
