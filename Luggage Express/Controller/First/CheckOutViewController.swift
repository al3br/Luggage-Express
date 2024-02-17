import UIKit
import Firebase
import CoreImage.CIFilterBuiltins
import FirebaseStorage

class CheckOutViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    var activityIndicator: UIActivityIndicatorView!
    
    let context = CIContext()
    let filter = CIFilter.qrCodeGenerator()
    
    var fastArrival: Bool = true
    var outsideChecked: Bool = true
    var selectedLuggage: String = ""
    var comment: String = ""
    var total: Double = 0.0
    var Longitude: Double = 0.0
    var Latitude: Double = 0.0
    var airportName: String = ""
    var locationDescription: String = ""
    var serialNumber: String = ""

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
            } else {
                arrayOrder.append(CheckOutOrder(type: "Inside the Airport Service", price: "0 AED"))
            }
        } else {
            
        }
        lblTotal.text = "\(total * 1.05) AED"
        
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
                        "fastArrival": self.fastArrival.description,
                        "outsideChecked": self.outsideChecked.description,
                        "selectedLuggage": self.selectedLuggage,
                        "comment": self.comment.description,
                        "total": self.total,
                        "longitude": self.Longitude,
                        "latitude": self.Latitude,
                        "order_id": newOrderID,
                        "serial_number": self.serialNumber
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

extension UIImage {
    func qrCodeImage() -> UIImage? {
        guard let ciImage = CIImage(image: self) else { return nil }
        let transform = CGAffineTransform(scaleX: 10, y: 10)
        let scaledCIImage = ciImage.transformed(by: transform)
        return UIImage(ciImage: scaledCIImage)
    }
}
