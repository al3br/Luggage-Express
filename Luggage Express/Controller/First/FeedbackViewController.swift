import UIKit
import Firebase

class FeedbackViewController: UIViewController, UITextViewDelegate {
    
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var textArea: UITextView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        textArea.delegate = self

        textArea.text = "Any compliants and suggestion for our application.."
        textArea.textColor = UIColor.lightGray
        textArea.backgroundColor = UIColor.white
        
        // Add tap gesture recognizer to dismiss keyboard
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc func dismissKeyboard() {
            view.endEditing(true)
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.lightGray {
            textView.text = nil
            textView.textColor = UIColor.black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "Any compliants and suggestion for our application.."
            textView.textColor = UIColor.lightGray
        }
    }

    @IBAction func onClickBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func onClickSubmit(_ sender: Any) {
        // Scale animation for the button
        UIView.animate(withDuration: 0.1, animations: {
            self.submitButton.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
        }, completion: { _ in
        UIView.animate(withDuration: 0.1) {
                self.submitButton.transform = CGAffineTransform.identity
            }
        })
        if textArea.text != nil {
            fetchUserDetailsAndSubmitFeedback()
        } else {
            showAlert(message: "Please enter your feedback before submitting.")
        }
    }
    
    func showAlert(message: String) {
        let alertController = UIAlertController(title: "Feedback Submission", message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(okAction)
        present(alertController, animated: true, completion: nil)
    }
    
    func fetchUserDetailsAndSubmitFeedback() {
            // Assuming you have a reference to your Firebase Firestore
            let db = Firestore.firestore()
            
            // Retrieve the current user's ID or any identifier you use to associate feedback with the user
            guard let userID = Auth.auth().currentUser?.uid else {
                print("User not authenticated.")
                return
            }
            
            // Reference to the "users" collection
            let usersCollection = db.collection("users")
            
            // Get the user document
            usersCollection.document(userID).getDocument { (document, error) in
                if let document = document, document.exists {
                    // User document exists, extract user information
                    if let userFirstName = document["firstName"] as? String,
                       let userLastName = document["lastName"] as? String,
                       let userEmail = document["email"] as? String,
                       let userPhoneNumber = document["phoneNumber"] as? String {
                        
                        // Submit feedback to the "feedback" collection
                        self.submitFeedback(userName: "\(userFirstName) \(userLastName)", userEmail: userEmail, userPhoneNumber: userPhoneNumber)
                    } else {
                        print("Error: Unable to retrieve user information.")
                    }
                } else {
                    print("Error: User document does not exist.")
                }
            }
        }
        
        func submitFeedback(userName: String, userEmail: String, userPhoneNumber: String) {
            let db = Firestore.firestore()
            
            // Reference to the "feedback" collection
            let feedbackCollection = db.collection("feedback")
            
            // Prepare data to be submitted
            let feedbackData: [String: Any] = [
                "text": textArea.text ?? "",
                "userName": userName,
                "userEmail": userEmail,
                "userPhoneNumber": userPhoneNumber,
                "timestamp": Timestamp()
            ]
            
            // Add the feedback data to the "feedback" collection
            feedbackCollection.addDocument(data: feedbackData) { error in
                if let error = error {
                    print("Error adding document: \(error)")
                } else {
                    print("Feedback submitted successfully.")
                    // Optionally, you can perform any actions upon successful submission
                    // Create an alert controller
                    let alertController = UIAlertController(title: "Feedback Submitted", message: "We appreciate your feedback.", preferredStyle: .alert)
                        
                    // Add an action to the alert controller
                    let okAction = UIAlertAction(title: "OK", style: .default) { _ in
                        // Dismiss the current view controller from the navigation stack
                        self.navigationController?.popViewController(animated: true)
                    }
                    alertController.addAction(okAction)
                        
                    // Present the alert controller
                    self.present(alertController, animated: true, completion: nil)
                }
            }
        }
    
}
