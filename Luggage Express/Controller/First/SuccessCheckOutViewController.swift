import UIKit
import SOTabBar
import FirebaseStorage

class SuccessCheckOutViewController: UIViewController {

    @IBOutlet weak var homeButton: UIButton!
    
    
    @IBOutlet weak var qrcodeImage: UIImageView!
    
    @IBOutlet weak var lblOrderNumber: UILabel!
    var orderNumber: Int = 10000000
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the placeholder image
        qrcodeImage.image = UIImage(named: "placeholder_image")
        
        lblOrderNumber.text = "#\(orderNumber)"
        
        let homeIcon = UIImage(systemName: "house")
        homeButton.setImage(homeIcon, for: .normal)
        homeButton.setTitle("Home", for: .normal)
        
        fetchQRCodeImageFromStorage(for: orderNumber)

    }
    
    func fetchQRCodeImageFromStorage(for orderNumber: Int) {
        // Create a reference to the Firebase Storage location where the QR code image is stored
        let storage = Storage.storage()
        let storageRef = storage.reference()
        let qrCodeRef = storageRef.child("qr_codes/\(orderNumber).png")
        
        // Download the image data
        qrCodeRef.getData(maxSize: 1 * 1024 * 1024) { data, error in
            if let error = error {
                print("Error downloading QR code image: \(error.localizedDescription)")
                // Handle the error condition, such as displaying an error message to the user
            } else if let imageData = data, let image = UIImage(data: imageData) {
                // Update the UIImageView with the downloaded image
                DispatchQueue.main.async {
                    self.qrcodeImage.image = image
                }
            } else {
                print("Error: Downloaded data is not in a valid image format.")
                // Handle the error condition, such as displaying an error message to the user
            }
        }
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
