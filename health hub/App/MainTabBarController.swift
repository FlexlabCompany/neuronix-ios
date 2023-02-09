import UIKit

class MainTabBarController: UITabBarController {
    override func viewDidLoad() {
        tabBar.backgroundColor = .systemBackground

        viewControllers = [
            UINavigationController(rootViewController: DevicesViewController()),
//            UINavigationController(rootViewController: HistoryViewController()),
            UINavigationController(rootViewController: SettingsViewController()),
        ]
        
        viewControllers![0].tabBarItem.title = "Устройства"
        viewControllers![0].tabBarItem.image = UIImage(systemName: "rectangle.compress.vertical")!
//        viewControllers![1].tabBarItem.title = "История"
//        viewControllers![1].tabBarItem.image = UIImage.init(systemName: "book")!
        viewControllers![1].tabBarItem.title = "Настройки"
        viewControllers![1].tabBarItem.image = UIImage.init(systemName: "gear")!

        
        self.tabBar.isHidden = true
    }
}

