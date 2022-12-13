//
//  SettingInfoCell.swift
//  DietRecord
//
//  Created by chun on 2022/11/16.
//

import UIKit
import FirebaseAuth
import SafariServices
import CryptoKit
import AuthenticationServices

class ProfileSettingCell: UITableViewCell, SFSafariViewControllerDelegate {
    @IBOutlet weak var infoBackgroundView: UIView! {
        didSet {
            infoBackgroundView.setShadowAndRadius(radius: 15)
        }
    }
    @IBOutlet weak var userImageView: UIImageView! {
        didSet {
            userImageView.layer.cornerRadius = DRConstant.fullScreenSize.width / 414 * 100 / 2
        }
    }
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var waterGoalLabel: UILabel!
    @IBOutlet weak var weightGoalLabel: UILabel!
    @IBOutlet weak var dietGoalLabel: UILabel!
    
    private var currentNonce: String?
    weak var controller: ProfileSettingVC?
    
    func layoutCell() {
        guard let userData = DRConstant.userData else { return }
        usernameLabel.text = userData.username
        waterGoalLabel.text = userData.waterGoal.transform(unit: Units.mLUnit.rawValue)
        weightGoalLabel.text = userData.weightGoal.transform(unit: Units.kgUnit.rawValue)
        dietGoalLabel.text = userData.goal[0].transform(unit: Units.kcalUnit.rawValue)
        userImageView.loadImage(userData.userImageURL)
    }
    
    // MARK: - Action -
    @IBAction func editInfo(_ sender: Any) {
        if let profileInfoPage = UIStoryboard.profile.instantiateViewController(
            withIdentifier: ProfileInformationVC.reuseIdentifier)
            as? ProfileInformationVC {
            profileInfoPage.isUpdated = true
            controller?.navigationController?.pushViewController(profileInfoPage, animated: true)
        }
    }
    
    @IBAction func blockUsers(_ sender: Any) {
        if let blockUsersPage = UIStoryboard.profile.instantiateViewController(
            withIdentifier: CheckRequestVC.reuseIdentifier) as? CheckRequestVC {
            blockUsersPage.need = FollowString.blockUsers.rawValue
            controller?.navigationController?.pushViewController(blockUsersPage, animated: true)
        }
    }
    
    @IBAction func goToPrivacyPolicy(_ sender: Any) {
        if let url = URL(string: DRConstant.privacyPolicyURL) {
            let safari = SFSafariViewController(url: url)
            safari.preferredControlTintColor = .drDarkGray
            safari.dismissButtonStyle = .close
            safari.delegate = self
            controller?.navigationController?.pushViewController(safari, animated: true)
            safari.navigationController?.navigationBar.isHidden = true
        }
    }
    
    func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        controller.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func logout(_ sender: Any) {
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
            DRConstant.userID = ""
            DRConstant.userData = nil
            controller?.tabBarController?.navigationController?.popToRootViewController(animated: true)
        } catch let signOutError as NSError {
            print("Error signing out: %@", signOutError)
        }
    }
    
    @IBAction func deleteOptions(_ sender: Any) {
        let alert = UIAlertController(
            title: "警告",
            message: "刪除您的帳號將清除您的個人資料及應用程式內的分析資料，並撤回您同意處理此資料的許可，且刪除帳號後您將無法復原此帳戶。",
            preferredStyle: .actionSheet)
        let deleteAction = UIAlertAction(title: "確定刪除", style: .destructive) { [weak self] _ in
            self?.signInWithApple()
        }
        let cancelAction = UIAlertAction(title: "取消", style: .cancel)
        alert.addAction(deleteAction)
        alert.addAction(cancelAction)
        controller?.present(alert, animated: true)
    }
    
    private func deleteAccount() {
        DRProgressHUD.show()
        let firebaseAuth = Auth.auth()
        guard let nowUserData = DRConstant.userData else { return }
        let users = nowUserData.followers + nowUserData.following
        var allUsers: [String] = []
        for user in users where !allUsers.contains(user) {
            allUsers.append(user)
        }
        FirebaseManager.shared.removeFollow(allUsers: allUsers) { [weak self] in
            guard let self = self else { return }
            FirebaseManager.shared.deleteAccount { result in
                switch result {
                case .success:
                    firebaseAuth.currentUser?.delete()
                    DRConstant.userID = ""
                    DRConstant.userData = nil
                    DRProgressHUD.showSuccess(text: "刪除帳號完成")
                    sleep(2)
                    self.controller?
                        .tabBarController?
                        .navigationController?
                        .popToRootViewController(animated: true)
                    print("刪除帳號")
                case .failure(let error):
                    DRProgressHUD.showFailure(text: "刪除帳號失敗")
                    print("Error Info: \(error) in deleting account.")
                }
            }
        }
    }
}

extension ProfileSettingCell: ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        guard let profileSettingVC = self.controller else { fatalError("完蛋") }
        return profileSettingVC.view.window!
    }
    
    private func signInWithApple() {
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
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if let credential = authorization.credential as? ASAuthorizationAppleIDCredential,
            let authorizationCode = credential.authorizationCode {
            self.getRefreshToken(authorizationCode: String(data: authorizationCode, encoding: .utf8) ?? "")
        }
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        print(error.localizedDescription)
        DRProgressHUD.showFailure(text: "登入失敗")
    }
    
    private func getRefreshToken(authorizationCode: String) {
        guard let clientSecret = GenerateJWT.shared.fetchClientSecret(),
            let url = URL(string: "https://appleid.apple.com/auth/token?client_id=com.Chun.DietRecord&client_secret=\(clientSecret)&code=\(authorizationCode)&grant_type=authorization_code")
        else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let response = response as? HTTPURLResponse, error == nil else {
                print("======error", error ?? URLError(.badServerResponse))
                return
            }
            
            guard (200 ... 299) ~= response.statusCode,
                let data = data,
                let refreshToken = try? DRConstant.decoder.decode(TokenResponse.self, from: data).refreshToken
            else {
                print("=======statusCode should be 2xx, but is \(response.statusCode)")
                print("response = \(response)")
                return
            }
            KeyChainManager.shared.setToken(token: refreshToken)
            self.deleteAccount()
        }
        task.resume()
    }
}
