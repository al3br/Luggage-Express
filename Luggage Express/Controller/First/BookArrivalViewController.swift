import UIKit
import DropDown
import Firebase

class BookArrivalViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var checkOutButton: UIButton!
    @IBOutlet weak var datePicker: UIDatePicker!
    
    @IBOutlet weak var departureDropDownView: UIView!
    @IBOutlet weak var arrivalDropDownView: UIView!
    
    @IBOutlet weak var serialNumberTextField: UITextField!
    @IBOutlet weak var departureTextField: UITextField!
    @IBOutlet weak var arrivalTextField: UITextField!
    
    let departureDropDown = DropDown()
    let arrivalDropDown = DropDown()
    
    var airports: [String] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        changePlaceHolderColor(stringText: "Departure (City-Airport-Country)", placeholder: departureTextField)
        changePlaceHolderColor(stringText: "Arrival (City-Airport-Country)", placeholder: arrivalTextField)
        changePlaceHolderColor(stringText: "Serial Number", placeholder: serialNumberTextField)

        datePicker.minimumDate = Date()

        departureTextField.delegate = self
        arrivalTextField.delegate = self
        
        fetchAirportsData()
        
        configureDropDown(dropDown: departureDropDown, anchorView: departureDropDownView, textField: departureTextField)
        configureDropDown(dropDown: arrivalDropDown, anchorView: arrivalDropDownView, textField: arrivalTextField)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)

        
    }
    
    @IBAction func onClickBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func dismissKeyboard() {
            view.endEditing(true)
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
        navigateToView(identifier: "success_ID")
    }
    
    func navigateToView(identifier: String) {
        guard let destinationViewController = storyboard?.instantiateViewController(withIdentifier: identifier) else {
            print("Failed to instantiate view controller with identifier: \(identifier)")
            return
        }
   
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
                    
                    // Assuming you have a 'data' collection in Firestore
                    let dataRef = db.collection("orders").document()

                    // Store the provided fields along with user details into the database
                    dataRef.setData([
                        "email": email,
                        "firstName": firstName,
                        "lastName": lastName,
                        "phoneNumber": phoneNumber,
                        "serialNumber": self.serialNumberTextField.text ?? "",
                        "departure": self.departureTextField.text ?? "",
                        "arrival": self.arrivalTextField.text ?? "",
                        "status": "pending",
                        "date": Date().description
                    ]) { error in
                        if let error = error {
                            print("Error writing document: \(error)")
                        } else {
                            print("Document successfully written!")
                        }
                    }
                } else {
                    print("User data not found or invalid format")
                }
            }
    }
    
    func configureDropDown(dropDown: DropDown, anchorView: UIView, textField: UITextField) {
        dropDown.anchorView = anchorView
        dropDown.bottomOffset = CGPoint(x: 0, y: anchorView.plainView.bounds.height)
        dropDown.topOffset = CGPoint(x: 0, y: anchorView.plainView.bounds.height)
        dropDown.direction = .bottom
        
        dropDown.selectionAction = { [weak self] (index: Int, item: String) in
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
