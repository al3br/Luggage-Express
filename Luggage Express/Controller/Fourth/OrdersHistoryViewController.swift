import UIKit
import Firebase

class OrdersHistoryViewController: UIViewController {
    
    var arrayUpdates = [String]()
    
    var arrayOrderHistory = [OrderHistory]()
    
    var orderNumber: String = ""
    
    var timelineItems = [TimelineItemView]() // Array to hold timeline items
 
    override func viewDidLoad() {
        super.viewDidLoad()
        
        arrayOrderHistory.reverse()
        
        // Call the function to fetch orders history
        fetchOrderHistory()
        
    }
    
    func fetchOrderHistory() {
        print("Fetching order history...")
        let db = Firestore.firestore()
        let ordersCollection = db.collection("orders")
        
        guard let orderIdNumber = Int(orderNumber) else {
            print("Failed to convert orderNumber to a numeric type.")
            return
        }
        
        ordersCollection.whereField("order_id", isEqualTo: orderIdNumber).getDocuments { (querySnapshot, error) in
            if let error = error {
                print("Error getting documents: \(error)")
            } else {
                guard let documents = querySnapshot?.documents else {
                    print("No documents")
                    return
                }
                
                for document in documents {
                    let trackingUpdatesCollection = document.reference.collection("trackingUpdates")
                    
                    trackingUpdatesCollection.getDocuments { (subCollectionSnapshot, subCollectionError) in
                        if let subCollectionError = subCollectionError {
                            print("Error getting subcollection documents: \(subCollectionError)")
                        } else {
                            guard let subCollectionDocuments = subCollectionSnapshot?.documents else {
                                print("No subcollection documents")
                                self.showAlertAndNavigateBack()
                                return
                            }
                            
                            for subDocument in subCollectionDocuments {
                                let data = subDocument.data()
                                if let date = data["date"] as? String,
                                   let time = data["time"] as? String,
                                   let description = data["description"] as? String {
                                    let timelineItem = TimelineItemView()
                                    timelineItem.configure(title: description, dateTime: "\(date) \(time)", hasData: true)
                                    
                                    // Append the timeline item to the array
                                    self.timelineItems.append(timelineItem)
                                    self.timelineItems.reverse()
                                }
                            }
                            
                            // Check if there are no subcollection documents
                            if subCollectionDocuments.isEmpty {
                                print("No subcollection documents")
                                self.showAlertAndNavigateBack()
                            } else {
                                // Once all data is fetched and processed, update the UI
                                DispatchQueue.main.async {
                                    self.setupTimelineItems()
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    func setupTimelineItems() {
        print("Setting up timeline items...")
        // Assuming you have a reference to the superview
        guard let superview = view else { return }
        
        // Add each TimelineItemView to the superview
        for (index, timelineItem) in timelineItems.enumerated() {
            superview.addSubview(timelineItem)
            timelineItem.translatesAutoresizingMaskIntoConstraints = false
            
            // Set constraints based on the index
            let topConstraint = CGFloat(120 + (80 * index))
            
            timelineItem.leadingAnchor.constraint(equalTo: superview.leadingAnchor, constant: 16).isActive = true
            timelineItem.topAnchor.constraint(equalTo: superview.topAnchor, constant: topConstraint).isActive = true
        }
        
        // Trigger a layout update to refresh the UI
        superview.setNeedsLayout()
        superview.layoutIfNeeded()
        print("Timeline items setup completed.")
    }


    
    func showAlertAndNavigateBack() {
        let alert = UIAlertController(title: "Update Not Found!", message: "There is no update for your order.", preferredStyle: .alert)
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
