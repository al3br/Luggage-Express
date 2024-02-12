import UIKit
import Firebase

class OrdersHistoryViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    var arrayOrderHistory = [OrderHistory]()
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return arrayOrderHistory.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let reversedIndex = arrayOrderHistory.count - indexPath.row - 1
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "orderCell", for: indexPath) as! OrderCell
            let order = arrayOrderHistory[reversedIndex]
            cell.setupCell(date: order.date, time: order.time, description: order.description)
            return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // Retrieve the selected service
        let selectedOrder = arrayOrderHistory[indexPath.row]
        
        // Perform actions based on the selected service
        print("Selected order: \(selectedOrder.description)")
        
        
    }

    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: self.view.frame.width * 0.49, height: self.view.frame.width * 0.5)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 5
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0.1
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.delegate = self
        collectionView.dataSource = self
   
        arrayOrderHistory.removeAll()
        arrayOrderHistory.reverse()
     
        // Call the function to fetch orders history
        fetchOrderHistory()
    }

    func fetchOrderHistory() {
        
        guard let currentUser = Auth.auth().currentUser else {
            print("No signed-in user")
            return
        }
            
        let userEmail = currentUser.email ?? ""
        let db = Firestore.firestore()

        
        // Assuming you have a collection named "Orders"
        let ordersCollection = db.collection("orders")
        
        // Query orders where the user email field matches signed-in user email
        ordersCollection.whereField("email", isEqualTo: userEmail).getDocuments { (querySnapshot, error) in
            if let error = error {
                print("Error getting documents: \(error)")
            } else {
                guard let documents = querySnapshot?.documents else {
                    print("No documents")
                    return
                }
                
                for document in documents {
                    // Access the subcollection "trackingUpdates" for each document
                    let trackingUpdatesCollection = document.reference.collection("trackingUpdates")
                    
                    // Fetch documents from the subcollection
                    trackingUpdatesCollection.getDocuments { (subCollectionSnapshot, subCollectionError) in
                        if let subCollectionError = subCollectionError {
                            print("Error getting subcollection documents: \(subCollectionError)")
                        } else {
                            guard let subCollectionDocuments = subCollectionSnapshot?.documents else {
                                print("No subcollection documents")
                                self.showAlertAndNavigateBack()
                                return
                            }
                            
                            // Parse and process the subcollection documents
                            for subDocument in subCollectionDocuments {
                                let data = subDocument.data()
                                if let date = data["date"] as? String,
                                   let time = data["time"] as? String,
                                   let description = data["description"] as? String {
                                    let orderHistory = OrderHistory(date: date, time: time, description: description)
                                    // Append the order history to your array
                                    self.arrayOrderHistory.append(orderHistory)
                                    
                                }
                            }
                            
                            // Here you can perform any UI updates or further processing
                            // as needed after fetching the order history
                            DispatchQueue.main.async {
                                self.collectionView.reloadData()
                            }
                            
                        }
                    }
                }
            }
        }
    }
    
    func showAlertAndNavigateBack() {
        let alert = UIAlertController(title: "Order Not Found!", message: "There is no order found by your email.", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Go Back", style: .default) { _ in
            // Dismiss the alert and navigate back to the previous screen
            self.navigationController?.popViewController(animated: true)
        }
        alert.addAction(okAction)
        present(alert, animated: true, completion: nil)
    }



    @IBAction func onClickBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    

    




    
    
}

class OrderCell: UICollectionViewCell {
    
    @IBOutlet weak var lblDescription: UILabel!
    @IBOutlet weak var lblTime: UILabel!
    @IBOutlet weak var lblDate: UILabel!
    
    
    func setupCell(date: String, time: String, description: String) {
        lblDate.text = date
        lblTime.text = time
        lblDescription.text = description
        
    }
    
}
