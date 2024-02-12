import UIKit
import Firebase

class LostReportViewController: UIViewController, UITextViewDelegate{
    
    let db = Firestore.firestore()
    
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var additionalInfoView: UITextView!
    @IBOutlet weak var dateView: UIDatePicker!
    @IBOutlet weak var lblSerialNumber: UITextField!
    @IBOutlet weak var descriptionView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dateView.maximumDate = Date.now
        dateView.semanticContentAttribute = .forceLeftToRight
        
        descriptionView.delegate = self
        descriptionView.text = "Please provide details about the lost or damaged item/report..."
        descriptionView.textColor = UIColor.lightGray
        descriptionView.backgroundColor = UIColor.white
        
        additionalInfoView.delegate = self
        additionalInfoView.text = "Optional..."
        additionalInfoView.textColor = UIColor.lightGray
        additionalInfoView.backgroundColor = UIColor.white

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
            if textView.tag == 1 {
                textView.text = "Please provide details about the lost or damaged item/report..."
            } else if textView.tag == 2 {
                textView.text = "Optional..."
            }
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
        insertDataToFirebase()
    }
    
    func insertDataToFirebase() {
        guard let currentUser = Auth.auth().currentUser else {
            print("No current user")
            return
        }

        let additionalInfo = additionalInfoView.text ?? ""
        let date = dateView.date
        let serialNumber = lblSerialNumber.text ?? ""
        let description = descriptionView.text ?? ""

        // Fetch additional user data from Firestore users collection
        let userRef = db.collection("users").document(currentUser.uid)
        userRef.getDocument { document, error in
            if let document = document, document.exists {
                let userData = document.data()
                let userPhoneNumber = userData?["phoneNumber"] as? String ?? "Unknown"
                let firstName = userData?["firstName"] as? String ?? "Unknown"
                let lastName = userData?["lastName"] as? String ?? "Unknown"

                let data: [String: Any] = [
                    "additionalInfo": additionalInfo,
                    "date": date,
                    "serialNumber": serialNumber,
                    "description": description,
                    "systemDate": FieldValue.serverTimestamp(),
                    "userEmail": currentUser.email ?? "Unknown",
                    "userName": "\(firstName) \(lastName)",
                    "userPhoneNumber": userPhoneNumber
                ]

                self.db.collection("reports").addDocument(data: data) { error in
                    if let error = error {
                        print("Error adding document: \(error)")
                    } else {
                        print("Document added successfully")
                    }
                }
            } else {
                print("User document does not exist")
            }
        }
    }


}
