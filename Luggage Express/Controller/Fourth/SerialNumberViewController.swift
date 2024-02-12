import UIKit
import Firebase

class SerialNumberViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource  {
    
    @IBOutlet weak var addButton: UIButton!
    
    @IBOutlet weak var lblSerialNumber: UITextField!
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    var arraySerialNumber = [SerialNumber]()
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return arraySerialNumber.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "serialNumberCell", for: indexPath) as! SerialNumberCell
        let serial = arraySerialNumber[indexPath.row]
        cell.setupCell(number: serial.number)
        cell.removeAction = { [weak self] in
            self?.removeSerialNumber(at: indexPath.row)
        }
        //cell.backgroundColor = UIColor.yellow
        //let yellowColor = UIColor(red: 255/255, green: 255/255, blue: 0/255, alpha: 1.0)
        //cell.backgroundColor = yellowColor
        return cell
    }
    
    func removeSerialNumber(at index: Int) {
        let serialToRemove = arraySerialNumber[index]
        
        guard let currentUserID = Auth.auth().currentUser?.uid else {
            return
        }
        
        let db = Firestore.firestore()
        let userRef = db.collection("users").document(currentUserID).collection("serialNumbers")
        
        userRef.whereField("number", isEqualTo: serialToRemove.number).getDocuments { [weak self] (querySnapshot, error) in
            guard let self = self else { return }
            
            if let error = error {
                print("Error removing serial number: \(error)")
                return
            }
            
            for document in querySnapshot!.documents {
                document.reference.delete()
            }
            
            // Remove the serial number from the local array
            self.arraySerialNumber.remove(at: index)
            
            // Reload the collection view to reflect the changes
            self.collectionView.reloadData()
        }
    }

    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: self.view.frame.width * 0.9, height: self.view.frame.width * 0.9)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 5
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0.9
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        collectionView.delegate = self
        collectionView.dataSource = self
        
        loadDataFromFirebase()
        
        // Add tap gesture recognizer to dismiss keyboard
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }

    @IBAction func onClickBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func onClickAddSerialNumber(_ sender: Any) {
        // Scale animation for the button
        UIView.animate(withDuration: 0.1, animations: {
            self.addButton.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
        }, completion: { _ in
        UIView.animate(withDuration: 0.1) {
                self.addButton.transform = CGAffineTransform.identity
            }
        })
        guard let serialNumberText = lblSerialNumber.text, let serialNumber = Int(serialNumberText) else {
                // Handle invalid input, such as non-integer text or empty text field
                return
            }
            
        addToFirebase(number: serialNumber)
    }
    
    func addToFirebase(number: Int) {
        // Assuming you have a reference to your Firebase Firestore database
        let db = Firestore.firestore()
        
        // Assuming you have a reference to the current user
        guard let currentUserID = Auth.auth().currentUser?.uid else {
            // Handle scenario where user is not logged in
            return
        }
        
        // Reference to the document for the current user
        let userRef = db.collection("users").document(currentUserID)
        
        // Add the serial number to the subcollection 'serialNumbers'
        userRef.collection("serialNumbers").addDocument(data: ["number": number]) { error in
            if let error = error {
                print("Error adding serial number: \(error)")
            } else {
                print("Serial number added successfully!")
                self.loadDataFromFirebase()
            }
        }
    }
    
    func loadDataFromFirebase() {
        let db = Firestore.firestore()
        
        guard let currentUserID = Auth.auth().currentUser?.uid else {
            return
        }
        
        let userRef = db.collection("users").document(currentUserID)
        
        // Fetch the serial numbers for the current user from Firebase
        userRef.collection("serialNumbers").getDocuments { [weak self] (querySnapshot, error) in
            guard let self = self else { return }
            
            if let error = error {
                print("Error fetching serial numbers: \(error)")
                return
            }
            
            var updatedSerialNumbers: [SerialNumber] = []
            
            for document in querySnapshot!.documents {
                if let number = document.data()["number"] as? Int {
                    updatedSerialNumbers.append(SerialNumber(number: number))
                }
            }
            
            // Update the local array with the new serial numbers
            self.arraySerialNumber = updatedSerialNumbers
            
            // Reload the UI to reflect the changes
            DispatchQueue.main.async {
                self.collectionView.reloadData() // Assuming you have a UICollectionView
                // You can also reload other UI elements as needed
            }
        }
    }
    
    func showAlertAndNavigateBack() {
        let alert = UIAlertController(title: "Serial Number Added", message: "You  have been added serial number successfully.", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default) { _ in
            // Dismiss the alert and navigate back to the previous screen
            self.navigationController?.popViewController(animated: true)
        }
        alert.addAction(okAction)
        present(alert, animated: true, completion: nil)
    }
}

class SerialNumberCell: UICollectionViewCell {
    
    @IBOutlet weak var removeButton: UIButton!
    @IBOutlet weak var lblNumber: UILabel!
    
    var removeAction: (() -> Void)?
    
    func setupCell(number: Int) {
        lblNumber.text = "\(number)"
        removeButton.addTarget(self, action: #selector(removeButtonTapped), for: .touchUpInside)
    }
    
    @objc func removeButtonTapped() {
        removeAction?()
    }
    
    
}
