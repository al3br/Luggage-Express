import UIKit
import Firebase

class EditProfileViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var saveButton: UIButton!
    
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var emailAddress: UITextField!
    @IBOutlet weak var phoneNumber: UITextField!
    @IBOutlet weak var lastName: UITextField!
    @IBOutlet weak var firstName: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.setNavigationBarHidden(true, animated: false)

        loadUserData()
        
        changePlaceHolderColor(stringText: "First Name", placeholder: firstName)
        changePlaceHolderColor(stringText: "Last Name", placeholder: lastName)
        changePlaceHolderColor(stringText: "Phone Number", placeholder: phoneNumber)
        changePlaceHolderColor(stringText: "Email Address", placeholder: emailAddress)
        changePlaceHolderColor(stringText: "***********", placeholder: password)
        
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
    
    @IBAction func onClickSave(_ sender: Any) {
        // Scale animation for the button
        UIView.animate(withDuration: 0.1, animations: {
            self.saveButton.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
        }, completion: { _ in
        UIView.animate(withDuration: 0.1) {
                self.saveButton.transform = CGAffineTransform.identity
            }
        })
        saveUserData()
    }
    
    
    @IBAction func onClickBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    func loadUserData() {
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
                    self.firstName.text = userData?["firstName"] as? String ?? ""
                    self.lastName.text = userData?["lastName"] as? String ?? ""
                    self.phoneNumber.text = userData?["phoneNumber"] as? String ?? ""
                } else {
                    // Document does not exist or error occurred
                    print("Error fetching user document: \(error?.localizedDescription ?? "Unknown error")")
                }
            }
            
            // Fill email address from Firebase Authentication
            emailAddress.text = currentUser.email
        }
    
    // Function to save user data to Firestore
    func saveUserData() {
        // Get the current user
        guard let currentUser = Auth.auth().currentUser else {
            // User is not logged in
            return
        }

        // Access Firestore database
        let db = Firestore.firestore()
        
        // Reference to the user's document in the "users" collection
        let userDocRef = db.collection("users").document(currentUser.uid)
        
        // Update the user document with the new data
        userDocRef.updateData([
            "firstName": firstName.text ?? "",
            "lastName": lastName.text ?? "",
            "phoneNumber": phoneNumber.text ?? ""
        ]) { error in
            if let error = error {
                // Error occurred while updating the document
                print("Error updating user document: \(error.localizedDescription)")
            } else {
                // Document updated successfully
                print("User document updated successfully")
                // You can optionally show an alert or perform any other action to notify the user
                self.showAlertAndNavigateBack()
            }
        }
    }
    
    // Function to show an alert confirming that changes have been saved
    func showAlertAndNavigateBack() {
        let alert = UIAlertController(title: "Changes Saved", message: "Your changes have been saved successfully.", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default) { _ in
            // Dismiss the alert and navigate back to the previous screen
            self.navigationController?.popViewController(animated: true)
        }
        alert.addAction(okAction)
        present(alert, animated: true, completion: nil)
    }



}
