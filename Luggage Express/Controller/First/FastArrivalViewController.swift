import UIKit
import SOTabBar
import DropDown
import Firebase

class FastArrivalViewController: UIViewController, UITextFieldDelegate, UITextViewDelegate{
    
    @IBOutlet weak var checkOutButton: UIButton!
    @IBOutlet weak var clickButton: UIButton!
    
    @IBOutlet weak var selectLuggage: UILabel!
    @IBOutlet weak var myDropDownView: UIView!
    
    
    @IBOutlet weak var serialNumberDropDownView: UIView!
    @IBOutlet weak var lblSerialNumber: UILabel!
    @IBOutlet weak var lblComment: UITextView!
    
    @IBOutlet weak var lblTotal: UILabel!
    
    @IBOutlet weak var buttonOutSide: UIButton!
    @IBOutlet weak var buttonInSide: UIButton!
    
    let serialNumberDropDown = DropDown()
    let myDropDown = DropDown()

    var outsideChecked = false

    let luggagesArray = ["1", "2", "3", "4", "5", "6", "7", "8", "9", "10"]
    var serialNumbers: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        
        lblComment.delegate = self

        lblComment.text = "Optional.."
        lblComment.textColor = UIColor.lightGray
        lblComment.backgroundColor = UIColor.white
        
        fetchSerialNumbers()
        configureDropDown()
        setup()
        
        if outsideChecked == false {
            buttonOutSide.setTitleColor(UIColor(named: "Main-text"), for: .normal)
            buttonOutSide.setTitle("+", for: .normal)
            buttonInSide.setTitleColor(.red, for: .normal)
            buttonInSide.setTitle("x", for: .normal)
        }
        
        // Add tap gesture recognizer to dismiss keyboard
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)

    }
    private func setup() {
        setupDismissKeyboardGesture()
        setupKeyboardHiding()
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
            view.frame.origin.y = newFrameY+80
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

    
    func changePlaceHolderColor(stringText: String, placeholder: UITextField) {
        let darkGrayPlaceholderText = NSAttributedString(string: stringText, attributes: [NSAttributedString.Key.foregroundColor: UIColor.darkGray])
        placeholder.attributedPlaceholder = darkGrayPlaceholderText
    }
    
    
    func configureDropDown(){
        serialNumberDropDown.anchorView = serialNumberDropDownView
        serialNumberDropDown.dataSource = serialNumbers
        
        
        serialNumberDropDown.bottomOffset = CGPoint(x: 0, y: (serialNumberDropDown.anchorView?.plainView.bounds.height)!)
        serialNumberDropDown.topOffset = CGPoint(x: 0, y: (serialNumberDropDown.anchorView?.plainView.bounds.height)!)
        
        serialNumberDropDown.direction = .bottom
        
        serialNumberDropDown.selectionAction = { (index: Int, item: String) in
            self.lblSerialNumber.text = self.serialNumbers[index]
            self.lblSerialNumber.textColor = .black
        }
        
        myDropDown.anchorView = myDropDownView
        myDropDown.dataSource = luggagesArray
        
        
        myDropDown.bottomOffset = CGPoint(x: 0, y: (myDropDown.anchorView?.plainView.bounds.height)!)
        myDropDown.topOffset = CGPoint(x: 0, y: (myDropDown.anchorView?.plainView.bounds.height)!)
        
        myDropDown.direction = .bottom
        
        myDropDown.selectionAction = { (index: Int, item: String) in
            self.selectLuggage.text = self.luggagesArray[index]
            self.selectLuggage.textColor = .black
        }
    }
    
    func fetchSerialNumbers() {
        print("Fetching serial numbers...")
        
        guard let currentUserID = Auth.auth().currentUser?.uid else {
            print("Error: Current user ID is nil.")
            return
        }
        
        let db = Firestore.firestore()
        let userRef = db.collection("users").document(currentUserID)
        
        userRef.collection("serialNumbers").getDocuments { [weak self] (querySnapshot, error) in
            guard let self = self else { return }

            if let error = error {
                print("Error fetching serial numbers: \(error)")
                return
            }

            guard let querySnapshot = querySnapshot else {
                print("Error: Query snapshot is nil.")
                return
            }

            print("Number of documents: \(querySnapshot.documents.count)")

            var updatedSerialNumbers: [String] = []

            for document in querySnapshot.documents {
                print("Document ID: \(document.documentID)")
                print("Document data: \(document.data())")

                if let number = document.data()["number"] {
                    if let numberString = number as? String {
                        updatedSerialNumbers.append(numberString)
                    } else if let numberInt = number as? Int {
                        let numberString = String(numberInt)
                        updatedSerialNumbers.append(numberString)
                    } else {
                        print("Error: Unable to convert number to String.")
                    }
                } else {
                    print("Error: 'number' field not found in document.")
                }
            }

            print("Fetched serial numbers: \(updatedSerialNumbers)")

            // Update the local array with the new serial numbers
            self.serialNumbers = updatedSerialNumbers
            self.serialNumberDropDown.dataSource = self.serialNumbers
        }

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
            textView.text = "Optional.."
            textView.textColor = UIColor.lightGray
        }
    }
    
    @IBAction func onClickBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    func showAlertAndNavigateBack() {
        let alert = UIAlertController(title: "Serial Number Not Found!", message: "You have to add serial number first!", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Scan a Serial Number", style: .default) { _ in
            // Dismiss the alert and navigate back to the previous screen
            self.navigateToHomePage()
        }
        alert.addAction(okAction)
        present(alert, animated: true, completion: nil)
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
        tabBarController.selectedIndex = 2

        // Hide the back button before pushing the tab bar controller
        navigationController.navigationBar.topItem?.setHidesBackButton(true, animated: false)

        navigationController.pushViewController(tabBarController, animated: true)
    }
    
    func navigateToView(identifier: String) {
        guard let destinationViewController = storyboard?.instantiateViewController(withIdentifier: identifier) else {
            print("Failed to instantiate view controller with identifier: \(identifier)")
            return
        }

        // Optionally, configure destinationViewController if needed
        
        navigationController?.pushViewController(destinationViewController, animated: true)
    }

    
        
    @IBAction func onClickCheckOut(_ sender: Any) {
        
        // Scale animation for the button
            UIView.animate(withDuration: 0.1, animations: {
                self.checkOutButton.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
            }, completion: { _ in
                UIView.animate(withDuration: 0.1) {
                    self.checkOutButton.transform = CGAffineTransform.identity
                }
            })
        if fieldsAreEmpty() {
            displayAlert(message: "Please select how many luggages.")
        } else {
            if outsideChecked {
                // Instantiate LocationInfoViewController from storyboard
                guard let vcLocation = storyboard?.instantiateViewController(withIdentifier: "location_ID") as? LocationInfoViewController else {
                    return
                }

                // Pass data to LocationInfoViewController
                vcLocation.outsideChecked = outsideChecked
                vcLocation.selectedLuggage = selectLuggage.text ?? ""
                vcLocation.comment = lblComment.text
                if let stringText = lblTotal.text, let totalValue = Double(stringText) {
                    vcLocation.total = totalValue
                }

                // Push LocationInfoViewController onto the navigation stack
                navigationController?.pushViewController(vcLocation, animated: true)
            } else {
                // Instantiate LocationInfoViewController from storyboard
                guard let vcInsideAirport = storyboard?.instantiateViewController(withIdentifier: "insideairport_ID") as? InsideAirportViewController else {
                    return
                }

                // Pass data to LocationInfoViewController
                vcInsideAirport.outsideChecked = outsideChecked
                vcInsideAirport.selectedLuggage = selectLuggage.text!
                vcInsideAirport.comment = lblComment.text
                vcInsideAirport.serialNumber = lblSerialNumber.text!
                if let stringText = lblTotal.text, let totalValue = Double(stringText) {
                    vcInsideAirport.total = totalValue
                }

                // Push LocationInfoViewController onto the navigation stack
                navigationController?.pushViewController(vcInsideAirport, animated: true)
            }
        }
    }
    
    func displayAlert(message: String) {
        let alert = UIAlertController(title: "Alert", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    func fieldsAreEmpty() -> Bool {
        if selectLuggage.text == "Select Luggage" || selectLuggage.text!.isEmpty {
            return true
        }
        return false
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    @IBAction func onClickDropDown(_ sender: Any) {
        myDropDown.show()
        
    }
    
    @IBAction func onClickSelectSerial(_ sender: Any) {
        serialNumberDropDown.show()
    }
    
    
    @IBAction func onClickOutside(_ sender: Any) {
        if outsideChecked {
            outsideChecked = false
            if let text = self.lblTotal.text, var value = Int(text) {
                    value = value - 30
                lblTotal.text = "\(value)"
                buttonOutSide.setTitleColor(UIColor(named: "Main-text"), for: .normal)
                buttonOutSide.setTitle("+", for: .normal)
                buttonInSide.setTitleColor(.red, for: .normal)
                buttonInSide.setTitle("x", for: .normal)
            }
        } else {
            outsideChecked = true
            if let text = self.lblTotal.text, var value = Int(text) {
                    value = value + 30
                lblTotal.text = "\(value)"
                buttonOutSide.setTitleColor(.red, for: .normal)
                buttonOutSide.setTitle("x", for: .normal)
                buttonInSide.setTitleColor(UIColor(named: "Main-text"), for: .normal)
                buttonInSide.setTitle("+", for: .normal)
            }
        }
    }
    

    @IBAction func onClickInside(_ sender: Any) {
        if outsideChecked == true {
            outsideChecked = false
            if let text = self.lblTotal.text, var value = Int(text) {
                    value = value - 30
                lblTotal.text = "\(value)"
                buttonOutSide.setTitleColor(UIColor(named: "Main-text"), for: .normal)
                buttonOutSide.setTitle("+", for: .normal)
            }
            buttonInSide.setTitleColor(.red, for: .normal)
            buttonInSide.setTitle("x", for: .normal)
            
        }
    }
    
    
    
}
	
