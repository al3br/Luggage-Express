import UIKit
import Firebase

class CheckOutViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    var fastArrival: Bool = true
    var outsideChecked: Bool = true
    var selectedLuggage: String = ""
    var comment: String = ""
    var total: Double = 0.0
    var Longitude: Double = 0.0
    var Latitude: Double = 0.0

    @IBOutlet weak var payButton: UIButton!
    @IBOutlet weak var lblTotal: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    
    var arrayOrder = [CheckOutOrder]()
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return arrayOrder.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "checkOutCell", for: indexPath) as! CheckOutCell
        let order = arrayOrder[indexPath.row]
        cell.setupCell(type: order.type, price: order.price)
        //cell.backgroundColor = UIColor.yellow
        //let yellowColor = UIColor(red: 255/255, green: 255/255, blue: 0/255, alpha: 1.0)
        //cell.backgroundColor = yellowColor
        return cell
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let appleIcon = UIImage(systemName: "applelogo")
        payButton.setImage(appleIcon, for: .normal)
        payButton.setTitle("Pay", for: .normal)
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
        if fastArrival == true {
            arrayOrder.append(CheckOutOrder(type: "Fast Arrival", price: "20 AED"))
            if outsideChecked == true {
                arrayOrder.append(CheckOutOrder(type: "Outside the Airport Service", price: "30 AED"))
            }
        } else {
            
        }
        lblTotal.text = "\(total * 1.05) AED"
        
    }

    @IBAction func onClickPay(_ sender: Any) {
        // Scale animation for the button
            UIView.animate(withDuration: 0.1, animations: {
                self.payButton.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
            }, completion: { _ in
                UIView.animate(withDuration: 0.1) {
                    self.payButton.transform = CGAffineTransform.identity
                }
            })
        storeDataToDatabase()
    }
    
    func navigateToView(identifier: String) {

        guard let destinationViewController = storyboard?.instantiateViewController(withIdentifier: identifier) else {
            print("Failed to instantiate view controller with identifier: \(identifier)")
            return
        }
   
        if let navigationController = navigationController {
            // Navigation code
            navigationController.pushViewController(destinationViewController, animated: true)
        } else {
            print("Navigation controller is nil")
        }

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
                        "user_id": currentUser.uid,
                        "email": email,
                        "firstName": firstName,
                        "lastName": lastName,
                        "phoneNumber": phoneNumber,
                        "status": "pending",
                        "date": Date().description,
                        "fastArrival": self.fastArrival.description,
                        "outsideChecked": self.outsideChecked.description,
                        "selectedLuggage": self.selectedLuggage,
                        "comment": self.comment.description,
                        "total": self.total,
                        "longitude": self.Longitude,
                        "latitude": self.Latitude
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
    
    @IBAction func onClickBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
}

class CheckOutCell: UICollectionViewCell {
    

    @IBOutlet weak var lblType: UILabel!
    @IBOutlet weak var lblPrice: UILabel!
    
    func setupCell(type: String, price: String) {
        lblType.text = type
        lblPrice.text = price
    }
    
}
