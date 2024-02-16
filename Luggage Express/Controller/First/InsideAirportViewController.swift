import UIKit
import DropDown
import Firebase

class InsideAirportViewController: UIViewController, UITextFieldDelegate, UITextViewDelegate {
    
    var outsideChecked: Bool = true
    var selectedLuggage: String = ""
    var comment: String = ""
    var total: Double = 0.0
    
    @IBOutlet weak var lblDescription: UITextView!
    @IBOutlet weak var arrivalTextField: UITextField!
    @IBOutlet weak var arrivalDropDownView: UIView!
    
    let arrivalDropDown = DropDown()
    
    var airports: [String] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        lblDescription.delegate = self
        arrivalTextField.delegate = self
        
        fetchAirportsData()

        changePlaceHolderColor(stringText: "Arrival (City-Airport-Country)", placeholder: arrivalTextField)
        
        configureDropDown(dropDown: arrivalDropDown, anchorView: arrivalDropDownView, textField: arrivalTextField)
    }
    
    func changePlaceHolderColor(stringText: String, placeholder: UITextField) {
        let darkGrayPlaceholderText = NSAttributedString(string: stringText, attributes: [NSAttributedString.Key.foregroundColor: UIColor.darkGray])
        placeholder.attributedPlaceholder = darkGrayPlaceholderText
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
                    print("Fetched data")
                    self?.arrivalDropDown.dataSource = airportData
                }
            } catch {
                print("Error decoding data: \(error)")
            }
        }.resume()
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
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let updatedText = (textField.text as NSString?)?.replacingCharacters(in: range, with: string) ?? string
        let filteredAirports = airports.filter { $0.lowercased().contains(updatedText.lowercased()) }

        arrivalDropDown.dataSource = filteredAirports
        arrivalDropDown.show()

        return true
    }
    
    func navigateToView(identifier: String) {
        guard let destinationViewController = storyboard?.instantiateViewController(withIdentifier: identifier) else {
            print("Failed to instantiate view controller with identifier: \(identifier)")
            return
        }
        navigationController?.pushViewController(destinationViewController, animated: true)
    }
    
    func fieldsAreEmpty() -> Bool {
        if lblDescription.text.isEmpty || arrivalTextField.text!.isEmpty {
            return true
        }
        return false
    }
    
    func displayAlert(message: String) {
        let alert = UIAlertController(title: "Alert", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    @IBAction func onClickNext(_ sender: Any) {
        if fieldsAreEmpty() {
            displayAlert(message: "Please fill in all fields.")
        } else {
            guard let vcCheckOut = storyboard?.instantiateViewController(withIdentifier: "checkout_ID") as? CheckOutViewController else {
                return
            }
            // Pass data to CheckOutViewController
            vcCheckOut.outsideChecked = outsideChecked
            vcCheckOut.selectedLuggage = selectedLuggage
            vcCheckOut.comment = comment
            vcCheckOut.total = total
            vcCheckOut.locationDescription = lblDescription.text
            vcCheckOut.airportName = arrivalTextField.text ?? ""
            // Push CheckOutViewController onto the navigation stack
            navigationController?.pushViewController(vcCheckOut, animated: true)
        }
        
    }
    
    @IBAction func onClickBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
}
