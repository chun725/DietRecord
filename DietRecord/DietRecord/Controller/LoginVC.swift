//
//  LoginVC.swift
//  DietRecord
//
//  Created by chun on 2022/11/15.
//

import UIKit
import FirebaseAuth
import AuthenticationServices
import CryptoKit
import Lottie
import SafariServices

class LoginVC: UIViewController, SFSafariViewControllerDelegate {
    @IBOutlet weak var noteLabel: UILabel!
    @IBOutlet weak var animationView: LottieAnimationView! {
        didSet {
            animationView.loopMode = .loop
            animationView.animationSpeed = 1.25
            animationView.play()
        }
    }
    @IBOutlet weak var privacyPolicyStackView: UIStackView!
    
    private var currentNonce: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setSignInWithAppleBtn()
        self.navigationController?.navigationBar.isHidden = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        animationView.play()
    }
    
    func setSignInWithAppleBtn() {
        let signInWithAppleBtn = ASAuthorizationAppleIDButton(
            authorizationButtonType: .signIn,
            authorizationButtonStyle: chooseAppleButtonStyle())
        view.addSubview(signInWithAppleBtn)
        signInWithAppleBtn.cornerRadius = 20
        signInWithAppleBtn.addTarget(self, action: #selector(signInWithApple), for: .touchUpInside)
        signInWithAppleBtn.translatesAutoresizingMaskIntoConstraints = false
        signInWithAppleBtn.heightAnchor.constraint(equalToConstant: 50).isActive = true
        signInWithAppleBtn.widthAnchor.constraint(equalToConstant: 280).isActive = true
        signInWithAppleBtn.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        signInWithAppleBtn.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -90).isActive = true
        setUpPrivacyPolicyStackView(button: signInWithAppleBtn)
    }
    
    func setUpPrivacyPolicyStackView(button: ASAuthorizationAppleIDButton) {
        noteLabel.translatesAutoresizingMaskIntoConstraints = false
        noteLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        noteLabel.topAnchor.constraint(equalTo: button.bottomAnchor, constant: 20).isActive = true
        privacyPolicyStackView.translatesAutoresizingMaskIntoConstraints = false
        privacyPolicyStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        privacyPolicyStackView.topAnchor.constraint(equalTo: noteLabel.bottomAnchor).isActive = true
    }
    
    @IBAction func goToPrivacyPolicyPage(_ sender: Any) {
        if let url = URL(string: "https://www.privacypolicies.com/live/0c52d156-f8ce-45f0-a5b0-74476275c555") {
            let safari = SFSafariViewController(url: url)
            safari.preferredControlTintColor = .drDarkGray
            safari.dismissButtonStyle = .close
            safari.delegate = self
            self.navigationController?.pushViewController(safari, animated: true)
        }
    }
    
    func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        self.navigationController?.popViewController(animated: true)
    }
    
    func chooseAppleButtonStyle() -> ASAuthorizationAppleIDButton.Style {
        return (UITraitCollection.current.userInterfaceStyle == .light) ? .black : .white // 淺色模式就顯示黑色的按鈕，深色模式就顯示白色的按鈕
    }
    
    @objc func signInWithApple(sender: Any) {
        let nonce = randomNonceString()
        currentNonce = nonce
        let provider = ASAuthorizationAppleIDProvider()
        let request = provider.createRequest()
        request.requestedScopes = [.fullName, .email]
        request.nonce = sha256(nonce)
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
    }
    
    private func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        let charset = Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        var result = ""
        var remainingLength = length

        while remainingLength > 0 {
            let randoms: [UInt8] = (0 ..< 16).map { _ in
                var random: UInt8 = 0
                let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
                if errorCode != errSecSuccess {
                    fatalError("Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)")
                }
                return random
            }

            randoms.forEach { random in
                if remainingLength == 0 {
                    return
                }

                if random < charset.count {
                    result.append(charset[Int(random)])
                    remainingLength -= 1
                }
            }
        }
        return result
    }

    private func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        let hashString = hashedData.compactMap { String(format: "%02x", $0) }.joined()
        return hashString
    }
}

extension LoginVC: ASAuthorizationControllerDelegate {
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if let credential = authorization.credential as? ASAuthorizationAppleIDCredential {
            let userId = credential.user
            let fullname = credential.fullName
            let email = credential.email
            guard let idToken = credential.identityToken,
                let nonce = currentNonce,
                let idTokenString = String(data: idToken, encoding: .utf8)
            else { return }
            print("---------\(userId)")
            print("---------\(String(describing: fullname))")
            print("---------\(email ?? "")")
            print("---------\(idToken)")
            print("---------\(idTokenString)")
            let credential = OAuthProvider.credential(withProviderID: "apple.com", idToken: idTokenString, rawNonce: nonce)

            firebaseSignInWithApple(credential: credential)
        }
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        print(error.localizedDescription)
        DRProgressHUD.showFailure(text: "登入失敗")
    }
}

// MARK: - ASAuthorizationControllerPresentationContextProviding
// 在畫面上顯示授權畫面
extension LoginVC: ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return view.window!
    }
}

extension LoginVC {
    // MARK: - 透過 Credential 與 Firebase Auth 串接
    func firebaseSignInWithApple(credential: AuthCredential) {
        Auth.auth().signIn(with: credential) { _, error in
            guard error == nil else {
                return
            }
            self.getFirebaseUserInfo()
        }
    }
    
    // MARK: - Firebase 取得登入使用者的資訊
    func getFirebaseUserInfo() {
        let currentUser = Auth.auth().currentUser
        guard let user = currentUser else {
            print("----error")
            return
        }
        let uid = user.uid
        DRConstant.userID = uid
        let email = user.email
        print("------\(uid)")
        print("------\(email ?? "")")
        DRProgressHUD.show()
        FirebaseManager.shared.fetchUserData(userID: DRConstant.userID) { [weak self] userData in
            guard let self = self else { return }
            if let userData = userData {
                DRConstant.userData = userData
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                if let tabbarController = storyboard.instantiateViewController(
                    withIdentifier: "\(TabBarController.self)")
                    as? TabBarController {
                    self.navigationController?.pushViewController(tabbarController, animated: true)
                }
            } else {
                let storyboard = UIStoryboard(name: DRConstant.profile, bundle: nil)
                if let profileInfoPage = storyboard.instantiateViewController(
                    withIdentifier: "\(ProfileInformationVC.self)")
                    as? ProfileInformationVC {
                    self.navigationController?.pushViewController(profileInfoPage, animated: true)
                }
            }
        }
    }
}
