import UIKit

@UIApplicationMain
final class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    private let userDefaults = UserDefaults.standard

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        Thread.sleep(forTimeInterval: 1.2)
        window = UIWindow()
        window?.rootViewController = UINavigationController(rootViewController: MainPageViewController())
        window?.makeKeyAndVisible()
        return true
    }
}
