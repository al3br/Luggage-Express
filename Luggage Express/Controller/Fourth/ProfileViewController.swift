import UIKit
import SOTabBar
import Firebase

class ProfileViewController: UIViewController {
    

    @IBOutlet weak var editProfileView: UIView!
    @IBOutlet weak var lineView: UIView!
    @IBOutlet weak var logOutView: UIView!
    @IBOutlet weak var aboutUsView: UIView!
    @IBOutlet weak var getHelpView: UIView!
    @IBOutlet weak var serialNumberView: UIView!
    @IBOutlet weak var walletView: UIView!
    @IBOutlet weak var orderView: UIView!
    
    @IBOutlet weak var lblPhoneNumber: UILabel!
    @IBOutlet weak var lblName: UILabel!
    
    var activityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        
        setupActivityIndicator()
        
        loadUserData()
        
    }
    
    func setupActivityIndicator() {
        // Create the activity indicator
        activityIndicator = UIActivityIndicatorView(style: .large)
        activityIndicator.center = view.center
        activityIndicator.hidesWhenStopped = true
        view.addSubview(activityIndicator)

        // Make sure the indicator is on top of the blur view
        view.bringSubviewToFront(activityIndicator)
    }


    func startAnimating() {
        // Start animating the activity indicator
        activityIndicator.startAnimating()
    }

    func stopAnimating() {
        // Stop animating the activity indicator
        activityIndicator.stopAnimating()

        // Remove the blur effect view from the superview
        for subview in view.subviews {
            if let blurView = subview as? UIVisualEffectView {
                blurView.removeFromSuperview()
            }
        }
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        
        // Reload data or perform any necessary updates here
        loadUserData()
    }
    
    func animateView(_ view: UIView) {
        view.alpha = 0.0
        view.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
        UIView.animate(withDuration: 0.5) {
            view.alpha = 1.0
            view.transform = CGAffineTransform.identity
        }
    }

    @IBAction func onClickEditProfile(_ sender: Any) {
        animateView(editProfileView)
        navigateToView(identifier: "editprofile_id")
    }
    
    @IBAction func onClickOrderHistory(_ sender: Any) {
        animateView(orderView)
        navigateToView(identifier: "myorder_id")
    }
    
    @IBAction func onClickWallet(_ sender: Any) {
        animateView(walletView)
        //navigateToView(identifier: "ViewController")
    }
    
    @IBAction func onClickSerialNumber(_ sender: Any) {
        animateView(serialNumberView)
        navigateToView(identifier: "serialnumber_ID")
    }
    
    
    @IBAction func onClickGetHelp(_ sender: Any) {
        animateView(getHelpView)
        navigateToHomePage()
    }
    
    @IBAction func onClickAboutUs(_ sender: Any) {
        animateView(aboutUsView)
        navigateToView(identifier: "aboutus_id")
    }
    
    func navigateToView(identifier: String) {
        guard let destinationViewController = storyboard?.instantiateViewController(withIdentifier: identifier) else {
            print("Failed to instantiate view controller with identifier: \(identifier)")
            return
        }
   
        navigationController?.pushViewController(destinationViewController, animated: true)
    }
    
    func navigateToHomePage() {
        // Force unwrap the navigation controller assuming it always exists
        guard let navigationController = navigationController else {
            fatalError("Navigation controller is unexpectedly nil")
        }

        let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
        
        guard let tabBarController = mainStoryboard.instantiateViewController(withIdentifier: "sotabbar") as? SOTabBarController else {
            print("Failed to instantiate TabBarController from storyboard")
            return
        }

        // Set the selected index of the tab bar controller to navigate to the first page
        tabBarController.selectedIndex = 2

        // Hide the back button before pushing the tab bar controller
        navigationController.navigationBar.topItem?.setHidesBackButton(true, animated: false)

        navigationController.pushViewController(tabBarController, animated: true)
        print(tabBarController.viewControllers)
    }
    
    @IBAction func onLogOut(_ sender: Any) {
        animateView(logOutView)
        // Create an alert to confirm logout
            let alert = UIAlertController(title: "Log Out", message: "Are you sure you want to log out?", preferredStyle: .alert)
            
            // Add a cancel action
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            
            // Add a confirm action
            alert.addAction(UIAlertAction(title: "Log Out", style: .destructive, handler: { _ in
                do {
                    try Auth.auth().signOut()
                    // Navigate to the login screen or any other destination after logout
                    self.loginPage()
                } catch let signOutError as NSError {
                    print("Error signing out: \(signOutError.localizedDescription)")
                }
            }))
            
            // Present the alert
            present(alert, animated: true, completion: nil)
    }
    
    func loginPage() {
        // Force unwrap the navigation controller assuming it always exists
        guard let navigationController = self.navigationController else {
            fatalError("Navigation controller is unexpectedly nil")
        }

        let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
        
        guard let loginViewController = mainStoryboard.instantiateViewController(withIdentifier: "loginview") as? LoginViewController else {
            print("Failed to instantiate LoginViewController from storyboard")
            return
        }

        // Hide the back button before pushing the tab bar controller
        navigationController.navigationBar.topItem?.setHidesBackButton(true, animated: false)

        navigationController.pushViewController(loginViewController, animated: true)
    }
    
    func loadUserData() {
        self.startAnimating()
            // Get the current user
            guard let currentUser = Auth.auth().currentUser else {
                // User is not logged in
                return
            }

            // Access Firestore database
            let db = Firestore.firestore()
            
            // Reference to the user's document in the "users" collection
            let userDocRef = db.collection("users").document(currentUser.uid)
            
            // Fetch user data from Firestore
            userDocRef.getDocument { (document, error) in
                if let document = document, document.exists {
                    // Document exists, extract user data
                    let userData = document.data()
                    self.lblName.text = userData?["firstName"] as? String ?? ""
                    self.lblPhoneNumber.text = userData?["phoneNumber"] as? String ?? ""
                    self.activityIndicator.stopAnimating()
                } else {
                    // Document does not exist or error occurred
                    print("Error fetching user document: \(error?.localizedDescription ?? "Unknown error")")
                    self.stopAnimating()
                }
            }
        }
}
