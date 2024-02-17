import UIKit
import SOTabBar
import DropDown
import Firebase
import FirebaseStorage

class BookArrivalViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var checkOutButton: UIButton!
    @IBOutlet weak var datePicker: UIDatePicker!
    
    @IBOutlet weak var serialNumberDropDownView: UIView!
    @IBOutlet weak var departureDropDownView: UIView!
    @IBOutlet weak var arrivalDropDownView: UIView!
    
    @IBOutlet weak var lblSerialNumber: UILabel!
    @IBOutlet weak var departureTextField: UITextField!
    @IBOutlet weak var arrivalTextField: UITextField!
    
    let serialNumberDropDown = DropDown()
    let departureDropDown = DropDown()
    let arrivalDropDown = DropDown()
    
    var airports: [String] = []
    
    var serialNumbers: [String] = []
    
    var activityIndicator: UIActivityIndicatorView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        changePlaceHolderColor(stringText: "Departure (City-Airport-Country)", placeholder: departureTextField)
        changePlaceHolderColor(stringText: "Arrival (City-Airport-Country)", placeholder: arrivalTextField)

        datePicker.minimumDate = Date()

        departureTextField.delegate = self
        arrivalTextField.delegate = self
        
        fetchAirportsData()
        fetchSerialNumbers()
        
        configureDropDown(dropDown: departureDropDown, anchorView: departureDropDownView, textField: departureTextField)
        configureDropDown(dropDown: arrivalDropDown, anchorView: arrivalDropDownView, textField: arrivalTextField)
        configureSerialNumberDropDown()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)

        
    }
    
    func setupActivityIndicator() {
        // Create a blur effect view
        let blurEffect = UIBlurEffect(style: .light)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = view.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        blurEffectView.alpha = 0.3
        view.addSubview(blurEffectView)

        // Create the activity indicator
        activityIndicator = UIActivityIndicatorView(style: .large)
        activityIndicator.center = view.center
        activityIndicator.hidesWhenStopped = true
        view.addSubview(activityIndicator)

        // Make sure the indicator is on top of the blur view
        view.bringSubviewToFront(activityIndicator)
        
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
    
    @IBAction func onClickSelectSerialNumber(_ sender: Any) {
        print("Clicked")
        serialNumberDropDown.show()
    }
    
    func configureSerialNumberDropDown() {
        serialNumberDropDown.anchorView = serialNumberDropDownView
        serialNumberDropDown.dataSource = serialNumbers
        serialNumberDropDown.bottomOffset = CGPoint(x: 0, y: serialNumberDropDownView.bounds.height)
        serialNumberDropDown.topOffset = CGPoint(x: 0, y: -serialNumberDropDownView.bounds.height)
        serialNumberDropDown.direction = .bottom

        serialNumberDropDown.selectionAction = { [weak self] (index: Int, item: String) in
            guard let self = self else { return }
            self.lblSerialNumber.text = item
            self.lblSerialNumber.textColor = .black
        }
    }
    
    @IBAction func onClickBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func dismissKeyboard() {
            view.endEditing(true)
    }

    func generateOrderID() {
        let db = Firestore.firestore()
        let ordersRef = db.collection("orders")

        // Query to get the last order ID
        ordersRef.order(by: "order_id", descending: true).limit(to: 1).getDocuments { (snapshot, error) in
            if let error = error {
                print("Error getting documents: \(error.localizedDescription)")
                return
            }

            var lastOrderID = 1000000 // Default starting order ID if no orders exist yet

            if let snapshot = snapshot {
                for document in snapshot.documents {
                    if let orderID = document.data()["order_id"] as? Int {
                        lastOrderID = orderID + 1
                        break
                    }
                }
            }

            // Now you have the last order ID, you can use it to create a new order
            let newOrderID = lastOrderID
            let newOrderRef = ordersRef.document()

            newOrderRef.setData(["order_id": newOrderID]) { error in
                if let error = error {
                    print("Error adding document: \(error.localizedDescription)")
                } else {
                    print("Order document added with ID: \(newOrderRef.documentID), Order ID: \(newOrderID)")
                }
            }
        }
    }
    
    func generateQRCode(from string: String) -> UIImage {
        let data = string.data(using: String.Encoding.ascii)
        if let QRFilter = CIFilter(name: "CIQRCodeGenerator") {
            QRFilter.setValue(data, forKey: "inputMessage")
            guard let QRImage = QRFilter.outputImage else {return UIImage(systemName: "xmark.circle") ?? UIImage()}
            
            let transformScale = CGAffineTransform(scaleX: 5.0, y: 5.0)
            let scaledQRImage = QRImage.transformed(by: transformScale)
            
            return UIImage(ciImage: scaledQRImage)
        }
        return UIImage(systemName: "xmark.circle") ?? UIImage()
    }

    func generateAndStoreQRCode(orderNumber: Int, completion: @escaping () -> Void) {
        // Upload the QR code image to Firebase Storage
        let storage = Storage.storage()
        let storageRef = storage.reference()
        let qrCodeRef = storageRef.child("qr_codes/\(orderNumber).png")
        
        guard let imageData = generateQRCode(from: "\(orderNumber)").pngData() else {
            print("Failed to convert QR code image to data.")
            return
        }
        
        let metadata = StorageMetadata()
        metadata.contentType = "image/png"
        
        qrCodeRef.putData(imageData, metadata: metadata) { metadata, error in
            if let error = error {
                print("Error uploading QR code image: \(error)")
            } else {
                print("QR code image uploaded successfully.")
                completion() // Call the completion handler
            }
        }
    }

    func storeDataToDatabase() {
        self.setupActivityIndicator()
        guard let currentUser = Auth.auth().currentUser else {
            // Handle when the user is not logged in
            return
        }
        
        // Assuming you have a Firestore database reference
        let db = Firestore.firestore()
        
        let ordersRef = db.collection("orders")

        // Query to get the last order ID
        ordersRef.order(by: "order_id", descending: true).limit(to: 1).getDocuments { (snapshot, error) in
            if let error = error {
                print("Error getting documents: \(error.localizedDescription)")
                return
            }
            
            var lastOrderID = 1000000 // Default starting order ID if no orders exist yet
            
            if let snapshot = snapshot {
                for document in snapshot.documents {
                    if let orderID = document.data()["order_id"] as? Int {
                        lastOrderID = orderID + 1
                        
                        break
                    }
                }
            }
            
            // Now you have the last order ID, you can use it to create a new order
            let newOrderID = lastOrderID
            
            // Convert your date string to a Timestamp object
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss Z"
            let date = dateFormatter.date(from: Date().description)

            // Create a Timestamp object
            let timestamp = Timestamp(date: date!)
            
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
                    
                    // Create a new order document
                    let orderData: [String: Any] = [
                        "user_id": currentUser.uid,
                        "email": email,
                        "firstName": firstName,
                        "lastName": lastName,
                        "phoneNumber": phoneNumber,
                        "status": "pending",
                        "date": timestamp,
                        "departure": self.departureTextField.text!,
                        "arrival": self.arrivalTextField.text!,
                        "serial_number": self.lblSerialNumber.text!,
                        "order_id": newOrderID
                    ]
                    
                    // Save the data to Firestore
                    ordersRef.addDocument(data: orderData) { error in
                        if let error = error {
                            print("Error writing document: \(error)")
                        } else {
                            print("Document successfully written!")
                            self.generateAndStoreQRCode(orderNumber: newOrderID) {
                                // This closure will be executed after the QR code image is uploaded successfully
                                DispatchQueue.main.async {
                                    guard let vcSuccess = self.storyboard?.instantiateViewController(withIdentifier: "success_ID") as? SuccessCheckOutViewController else {
                                        return
                                    }
                                    self.stopAnimating()
                                    // Pass data to CheckOutViewController
                                    vcSuccess.orderNumber = newOrderID
                                    self.navigationController?.pushViewController(vcSuccess, animated: true)
                                }
                            }
                        }
                    }
                } else {
                    print("User data not found or invalid format")
                }
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
        storeDataToDatabase()
    }
    
    func navigateToView(identifier: String) {
        guard let destinationViewController = storyboard?.instantiateViewController(withIdentifier: identifier) else {
            print("Failed to instantiate view controller with identifier: \(identifier)")
            return
        }
   
        navigationController?.pushViewController(destinationViewController, animated: true)
    }
    
    func configureDropDown(dropDown: DropDown, anchorView: UIView, textField: UITextField) {
        dropDown.anchorView = anchorView
        dropDown.bottomOffset = CGPoint(x: 0, y: anchorView.plainView.bounds.height)
        dropDown.topOffset = CGPoint(x: 0, y: anchorView.plainView.bounds.height)
        dropDown.direction = .bottom
        
        dropDown.selectionAction = { (index: Int, item: String) in
            let filteredAirports = dropDown.dataSource
            textField.text = filteredAirports[index]
            textField.textColor = .black
        }

    }
    
    func fetchAirportsData() {
        guard let url = URL(string: "https://www.jsonkeeper.com/b/92OZ") else {
            print("Invalid URL")
            return
        }

        URLSession.shared.dataTask(with: url) { [weak self] (data, response, error) in
            guard let data = data, error == nil else {
                print("Error fetching data: \(error?.localizedDescription ?? "Unknown error")")
                return
            }

            do {
                let decoder = JSONDecoder()
                let airportData = try decoder.decode([String].self, from: data)
                self?.airports = airportData

                DispatchQueue.main.async {
                    self?.departureDropDown.dataSource = airportData
                    self?.arrivalDropDown.dataSource = airportData
                }
            } catch {
                print("Error decoding data: \(error)")
            }
        }.resume()
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
            if updatedSerialNumbers.isEmpty {
                self.showAlertAndNavigateBack()
            }
        }

    }

    func showAlertAndNavigateBack() {
        let alert = UIAlertController(title: "Serial Number Not Found!", message: "Please add serial number first by navigating to Barcode Reader Page or Profile then Serial Number.", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Back", style: .default) { _ in
            // Dismiss the alert and navigate back to the previous screen
            self.navigationController?.popViewController(animated: true)
        }
        alert.addAction(okAction)
        present(alert, animated: true, completion: nil)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let updatedText = (textField.text as NSString?)?.replacingCharacters(in: range, with: string) ?? string
        let filteredAirports = airports.filter { $0.lowercased().contains(updatedText.lowercased()) }

        if textField == departureTextField {
            departureDropDown.dataSource = filteredAirports
            departureDropDown.show()
        } else if textField == arrivalTextField {
            arrivalDropDown.dataSource = filteredAirports
            arrivalDropDown.show()
        }

        return true
    }
    
    func changePlaceHolderColor(stringText: String, placeholder: UITextField) {
        let darkGrayPlaceholderText = NSAttributedString(string: stringText, attributes: [NSAttributedString.Key.foregroundColor: UIColor.darkGray])
        placeholder.attributedPlaceholder = darkGrayPlaceholderText
    }
}
