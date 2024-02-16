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
        
        setup()
    }
    
    private func setup() {
        setupDismissKeyboardGesture()
        setupKeyboardHiding()
        setupPlaceHolderAndDate()
    }
    
    private func setupKeyboardHiding() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func keyboardWillShow(sender: NSNotification) {
        guard let userInfo = sender.userInfo,
              let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue,
              let currentInput = findFirstResponder() else {
            return
        }
        
        let keyboardTopY = keyboardFrame.cgRectValue.origin.y
        let convertedInputFrame = view.convert(currentInput.frame, from: currentInput.superview)
        let inputBottomY = convertedInputFrame.origin.y + convertedInputFrame.size.height
        
        if inputBottomY > keyboardTopY {
            let inputY = convertedInputFrame.origin.y
            let newFrameY = (inputY - keyboardTopY / 2) * -1
            view.frame.origin.y = newFrameY + 80
        }
    }

    func findFirstResponder() -> UIView? {
        for view in view.subviews {
            if view.isFirstResponder {
                return view
            }
            if let responder = findFirstResponder(in: view) {
                return responder
            }
        }
        return nil
    }

    func findFirstResponder(in view: UIView) -> UIView? {
        for subview in view.subviews {
            if subview.isFirstResponder {
                return subview
            }
            if let responder = findFirstResponder(in: subview) {
                return responder
            }
        }
        return nil
    }


    @objc func keyboardWillHide(notification: NSNotification)
    {
        view.frame.origin.y = 0
    }
    
    private func setupDismissKeyboardGesture() {
        let dismissKeyboardTap = UITapGestureRecognizer(target: self, action: #selector(viewTapped(_: )))
        view.addGestureRecognizer(dismissKeyboardTap)
    }
        
    @objc func viewTapped(_ recognizer: UITapGestureRecognizer) {
        if recognizer.state == UIGestureRecognizer.State.ended {
            view.endEditing(true) // resign first responder
        }
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    private func setupPlaceHolderAndDate() {
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
