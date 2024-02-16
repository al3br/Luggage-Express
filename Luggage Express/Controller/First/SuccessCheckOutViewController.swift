import UIKit
import SOTabBar

class SuccessCheckOutViewController: UIViewController {

    @IBOutlet weak var homeButton: UIButton!
    
    @IBOutlet weak var lblOrderNumber: UILabel!
    var orderNumber: Int = 10000000
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        lblOrderNumber.text = "#\(orderNumber)"
        
        let homeIcon = UIImage(systemName: "house")
        homeButton.setImage(homeIcon, for: .normal)
        homeButton.setTitle("Home", for: .normal)

    }
    
    @IBAction func onClickHome(_ sender: Any) {
        // Scale animation for the button
        UIView.animate(withDuration: 0.1, animations: {
            self.homeButton.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
        }, completion: { _ in
            UIView.animate(withDuration: 0.1) {
                self.homeButton.transform = CGAffineTransform.identity
            }
        })
        navigateToHomePage()
    }
    
    func navigateToHomePage() {
        // Force unwrap the navigation controller assuming it always exists
        guard let navigationController = navigationController else {
            fatalError("Navigation controller is unexpectedly nil")
        }

        guard let tabBarController = storyboard?.instantiateViewController(withIdentifier: "sotabbar") as? SOTabBarController else {
            print("Failed to instantiate TabBarController from storyboard")
            return
        }

        // Set the selected index of the tab bar controller to navigate to the first page
        tabBarController.selectedIndex = 0

        // Hide the back button before pushing the tab bar controller
        navigationController.navigationBar.topItem?.setHidesBackButton(true, animated: false)

        navigationController.pushViewController(tabBarController, animated: true)
    }
    

}
