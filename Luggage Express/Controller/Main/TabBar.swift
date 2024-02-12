import UIKit
import SOTabBar

class TabBar: SOTabBarController  {
    
    override func loadView() {
            super.loadView()
            SOTabBarSetting.tabBarBackground = UIColor(named: "Background")!
            SOTabBarSetting.tabBarTintColor = UIColor(named: "Main-text")!
            SOTabBarSetting.tabBarCircleSize = CGSize(width: 60, height: 60)
            SOTabBarSetting.tabBarSizeImage = 40.0
            SOTabBarSetting.tabBarSizeSelectedImage = 40.0
        }
        
        override func viewDidLoad() {
            super.viewDidLoad()
            
            //self.delegate = self
            let homeStoryboard = UIStoryboard(name: "First", bundle: nil).instantiateViewController(withIdentifier: "ServicesViewController")
            let qrStoryboard = UIStoryboard(name: "Second", bundle: nil).instantiateViewController(withIdentifier: "QRViewController")
            let chatStoryboard = UIStoryboard(name: "Third", bundle: nil).instantiateViewController(withIdentifier: "ChatViewController")
            let profileStoryboard = UIStoryboard(name: "Fourth", bundle: nil).instantiateViewController(withIdentifier: "ProfileViewController")
            
            homeStoryboard.tabBarItem = UITabBarItem(title: "Services", image: UIImage(named: "select_service"), selectedImage: UIImage(named: "service"))
            qrStoryboard.tabBarItem = UITabBarItem(title: "QR Reader", image: UIImage(named: "select_qr"), selectedImage: UIImage(named: "qr"))
            chatStoryboard.tabBarItem = UITabBarItem(title: "Chat", image: UIImage(named: "select_chat"), selectedImage: UIImage(named: "chat"))
            profileStoryboard.tabBarItem = UITabBarItem(title: "Profile", image: UIImage(named: "select_profile"), selectedImage: UIImage(named: "profile"))
            
            viewControllers = [homeStoryboard, qrStoryboard, chatStoryboard, profileStoryboard]
        }

}
