import UIKit

/// Adopts the UIScene lifecycle required when building with the iOS 27 SDK.
/// SDL still owns the game window; this delegate only boots Empo's SwiftUI shell
/// once UIKit has connected a `UIWindowScene`.
@objc(EmpoSceneDelegate)
final class EmpoSceneDelegate: UIResponder, UIWindowSceneDelegate {

    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        guard scene is UIWindowScene else { return }
        AppWindow.install()
    }
}
