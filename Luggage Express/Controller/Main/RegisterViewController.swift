import UIKit
import SOTabBar
import Firebase

class RegisterViewController: UIViewController, UITextFieldDelegate{

    @IBOutlet weak var lblError: UILabel!
    @IBOutlet weak var lblPhoneNumber: UITextField!
    @IBOutlet weak var lblEmailAddress: UITextField!
    @IBOutlet weak var lblPassword: UITextField!
    @IBOutlet weak var lblConfirmPassword: UITextField!
    @IBOutlet weak var lblFirstName: UITextField!
    @IBOutlet weak var lblLastName: UITextField!
    
    @IBOutlet weak var signUpButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        
        let signupIcon = UIImage(named: "signup_icon")
        signUpButton.setImage(signupIcon, for: .normal)
        signUpButton.setTitle("Sign Up", for: .normal)
        signUpButton.contentHorizontalAlignment = .center
    
        changePlaceHolderColor(stringText: "First Name...", placeholder: lblFirstName)
        changePlaceHolderColor(stringText: "Last Name...", placeholder: lblLastName)
        changePlaceHolderColor(stringText: "Phone Number...", placeholder: lblPhoneNumber)
        changePlaceHolderColor(stringText: "Email Address...", placeholder: lblEmailAddress)
        changePlaceHolderColor(stringText: "Password...", placeholder: lblPassword)
        changePlaceHolderColor(stringText: "Confirm Password...", placeholder: lblConfirmPassword)
    
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
    
    @IBAction func onClickSignUp(_ sender: Any) {
        // Set initial properties for the animation
        signUpButton.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
        signUpButton.alpha = 0

                UIView.animate(withDuration: 1.0, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.2, options: .curveEaseInOut, animations: {
                    // Set final properties for the animation
                    self.signUpButton.transform = .identity
                    self.signUpButton.alpha = 1
                }, completion: nil)
        // Check if any of the text fields are empty
            guard let email = lblEmailAddress.text, !email.isEmpty,
                  let password = lblPassword.text, !password.isEmpty,
                  let confirmPassword = lblConfirmPassword.text, !confirmPassword.isEmpty,
                  let firstName = lblFirstName.text, !firstName.isEmpty,
                  let lastName = lblLastName.text, !lastName.isEmpty,
                  let phoneNumber = lblPhoneNumber.text, !phoneNumber.isEmpty else {
                // Handle empty fields
                lblError.text = "Please fill in all fields"
                return
            }

            // Validate password and confirmPassword
            guard password == confirmPassword else {
                // Handle password mismatch
                lblError.text = "Passwords do not match"
                return
            }

            // Create user with email and password
            Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
                if let error = error {
                    // Handle error
                    print("Error creating user: \(error.localizedDescription)")
                    self.lblError.text = "Error creating user: \(error.localizedDescription)"
                } else {
                    // User created successfully
                    if let user = authResult?.user {
                        // Update user profile
                        let changeRequest = user.createProfileChangeRequest()
                        changeRequest.displayName = "\(firstName) \(lastName)"
                        changeRequest.commitChanges { error in
                            if let error = error {
                                // Handle profile update error
                                print("Error updating profile: \(error.localizedDescription)")
                                self.lblError.text = "Error updating profile: \(error.localizedDescription)"
                            } else {
                                // Profile updated successfully
                                print("User profile updated successfully")
                                
                                // Create a Firestore document for the user profile
                                let db = Firestore.firestore()
                                let userDocRef = db.collection("users").document(user.uid)
                                let userData: [String: Any] = [
                                    "firstName": firstName,
                                    "lastName": lastName,
                                    "email": email,
                                    "phoneNumber": phoneNumber
                                    // Add more fields as needed
                                ]
                                userDocRef.setData(userData) { error in
                                    if let error = error {
                                        // Handle Firestore document creation error
                                        print("Error creating user profile document: \(error.localizedDescription)")
                                        self.lblError.text = "Error creating user profile document: \(error.localizedDescription)"
                                    } else {
                                        // User profile document created successfully
                                        print("User profile document created successfully")
                                        // Navigate to the next screen or perform any other action
                                        self.navigateToHomePage()
                                    }
                                }
                            }
                        }
                    }
                }
            }
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
