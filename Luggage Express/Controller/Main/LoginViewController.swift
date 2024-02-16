import UIKit
import Firebase
import SOTabBar

class LoginViewController: UIViewController, UITextFieldDelegate {
    
    
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var loginButton: UIButton!
    
    @IBOutlet weak var lblMessage: UILabel!
    
    @IBOutlet weak var lblPassword: UITextField!
    @IBOutlet weak var lblEmailAddress: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        lblPassword.textContentType = .oneTimeCode
        
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        
        // Set the login icon and text for the button
        let loginIcon = UIImage(named: "login_icon") // Make sure you have the login icon image in your assets
        loginButton.setImage(loginIcon, for: .normal)
        loginButton.setTitle("Login", for: .normal)
                
        // Adjust the content edge insets to position the image and text
        loginButton.contentHorizontalAlignment = .center
        
            
        
        if Auth.auth().currentUser != nil {
            // User is already signed in, navigate to the home page or any other destination
            navigateToHomePage()
        }
        
        changePlaceHolderColor(stringText: "Email Address...", placeholder: lblEmailAddress)
        changePlaceHolderColor(stringText: "Password...", placeholder: lblPassword)
        
        // Add tap gesture recognizer to dismiss keyboard
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    func changePlaceHolderColor(stringText: String, placeholder: UITextField) {
        let darkGrayPlaceholderText = NSAttributedString(string: stringText, attributes: [NSAttributedString.Key.foregroundColor: UIColor.darkGray])
        placeholder.attributedPlaceholder = darkGrayPlaceholderText
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
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

    @IBAction func onClickSignIn(_ sender: Any) {
        // Set initial properties for the animation
                loginButton.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
                loginButton.alpha = 0

                UIView.animate(withDuration: 1.0, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.2, options: .curveEaseInOut, animations: {
                    // Set final properties for the animation
                    self.loginButton.transform = .identity
                    self.loginButton.alpha = 1
                }, completion: nil)
        guard let email = lblEmailAddress.text, let password = lblPassword.text else {
                    // Handle invalid input
                    return
                }

                // Sign in the user using Firebase Authentication
                Auth.auth().signIn(withEmail: email, password: password) { [weak self] authResult, error in
                    guard let self = self else { return }

                    if let error = error {
                        // Handle sign-in error
                        print("Error signing in: \(error.localizedDescription)")
                        // Display an alert or handle the error according to your app's requirements
                        lblMessage.text = "\(error.localizedDescription)"
                    } else {
                        // Sign-in successful
                        print("User signed in successfully")
                        navigateToHomePage()
                        // Navigate to the next screen or perform any other action after successful sign-in
                    }
                }
    }
    
}
