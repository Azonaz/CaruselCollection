import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

        func application(
            _ application: UIApplication,
            didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
        ) -> Bool {
            window = UIWindow(frame: UIScreen.main.bounds) // ВАЖНО: задать frame
            window?.rootViewController = CarouselViewController()
            window?.makeKeyAndVisible()
            return true
        }
}
