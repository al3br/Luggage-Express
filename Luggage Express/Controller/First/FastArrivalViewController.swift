import UIKit
import SOTabBar
import DropDown
import Firebase

class FastArrivalViewController: UIViewController, UITextFieldDelegate, UITextViewDelegate{
    
    @IBOutlet weak var checkOutButton: UIButton!
    @IBOutlet weak var clickButton: UIButton!
    
    @IBOutlet weak var selectLuggage: UILabel!
    @IBOutlet weak var myDropDownView: UIView!
    
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
        
        if outsideChecked == false {
            buttonOutSide.setTitleColor(UIColor(named: "Main-text"), for: .normal)
            buttonOutSide.setTitle("+", for: .normal)
            buttonInSide.setTitleColor(.red, for: .normal)
            buttonInSide.setTitle("x", for: .normal)
            checkOutButton.setTitle("Check Out", for: .normal)
        } else {
            checkOutButton.setTitle("Next", for: .normal)
        }
        
        //showAlertAndNavigateBack()
        
        // Add tap gesture recognizer to dismiss keyboard
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)

    }
    
    func configureDropDown(){
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
    
    @IBAction func onBack(_ sender: Any) {
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

    func storeDataToDatabase() {
        guard let currentUser = Auth.auth().currentUser else {
            // Handle when the user is not logged in
            return
        }

        // Assuming you have a Firestore database reference
        let db = Firestore.firestore()

        // Retrieve user details from the 'users' collection
        db.collection("users").document(currentUser.uid).getDocument { (userDocument, error) in
            if let error = error {
                print("Error getting user document: \(error)")
                return
            }

            if let userData = userDocument?.data(),
               let email = userData["email"] as? String,
               let firstName = userData["firstName"] as? String,
               let lastName = userData["lastName"] as? String,
               let phoneNumber = userData["phoneNumber"] as? String {

                
                let dataRef = db.collection("orders").document()

                // Store the values into the database along with user information
                dataRef.setData([
                    "userId": currentUser.uid,
                    "email": email,
                    "firstName": firstName,
                    "lastName": lastName,
                    "phoneNumber": phoneNumber,
                    "outsideChecked": self.outsideChecked,
                    "selectLuggage": self.selectLuggage.text ?? "",
                    "comment": self.lblComment.text ?? "",
                    "total": self.lblTotal.text ?? ""
                ]) { error in
                    if let error = error {
                        print("Error writing document: \(error)")
                    } else {
                        print("Document successfully written!")
                        self.navigateToView(identifier: "success_ID")
                    }
                }
            } else {
                print("User data not found or invalid format")
            }
        }
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
                storeDataToDatabase()
            }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    @IBAction func onClickDropDown(_ sender: Any) {
        print("Button Clicked")
        myDropDown.show()
        
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
                checkOutButton.setTitle("Check Out", for: .normal)
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
                checkOutButton.setTitle("Next", for: .normal)
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
	
