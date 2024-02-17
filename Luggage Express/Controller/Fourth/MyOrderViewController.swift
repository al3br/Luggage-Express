import UIKit
import Firebase
import FirebaseStorage

class MyOrderViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    
    var activityIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    var arrMyOrders = [MyOrder]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupActivityIndicator()
        
        collectionView.delegate = self
        collectionView.dataSource = self

        fetchOrdersForCurrentUser()
        
        
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
    }

    func startAnimating() {
        // Start animating the activity indicator
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
    
    func fetchOrdersForCurrentUser() {
        
        self.startAnimating()
        guard let currentUser = Auth.auth().currentUser else {
            return
        }

        var myOrders: [MyOrder] = []

        let db = Firestore.firestore()
        let ordersRef = db.collection("orders")
        let storage = Storage.storage()
        let storageRef = storage.reference()

        ordersRef.whereField("user_id", isEqualTo: currentUser.uid)
            .order(by: "order_id", descending: true)
            .getDocuments { (snapshot, error) in
            if let error = error {
                print("Error: \(error)")
                return
            }

            guard let snapshot = snapshot else {
                
                return
            }
            var totalOrdersCount = 0
            var fetchedOrdersCount = 0
                
            for document in snapshot.documents {
                totalOrdersCount += 1 // Increment the total count
                
                if let orderID = document.data()["order_id"] as? Int,
                   let status = document.data()["status"] as? String {
                    let qrCodeRef = storageRef.child("qr_codes/\(orderID).png")
                    qrCodeRef.getData(maxSize: 1 * 1024 * 1024) { data, error in
                        fetchedOrdersCount += 1 // Increment the fetched count
                        if let error = error {
                            print("Error downloading QR code image for order \(orderID): \(error.localizedDescription)")
                            // Use the default qr_code image
                            let myOrder = MyOrder(number: "\(orderID)", status: "Status: \(status)", image: UIImage(named: "qr_code")!)
                            myOrders.append(myOrder)
                        } else if let imageData = data, let imageD = UIImage(data: imageData) {
                            // Create a MyOrder object with the fetched image
                            let myOrder = MyOrder(number: "\(orderID)", status: "Status: \(status)", image: imageD)
                            // Append the created MyOrder object to the myOrders array
                            myOrders.append(myOrder)
                        } else {
                            print("Error: Downloaded data is not in a valid image format.")
                        }
                            // Check if all orders have been fetched
                            if fetchedOrdersCount == totalOrdersCount {
                            // If all orders have been fetched, assign the fetched orders to arrMyOrders
                            self.arrMyOrders = myOrders
                            // Reload the collection view when all data is fetched
                            self.collectionView.reloadData()
                            self.stopAnimating()
                        }
                    }
                }
            }
        }
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return arrMyOrders.count
    }
    
    // Implement the delegate method to set the size for each item (cell)
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = self.view.frame.width * 0.4 // Set the width of the cell to 50% of the collectionView's width
        let height = self.view.frame.width * 0.45
        return CGSize(width: width, height: height)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 20
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }

    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let myOrderCell = cell as? MyOrderCollectionViewCell else {
            return
        }
        myOrderCell.alpha = 0
        myOrderCell.center.x -= 100
        myOrderCell.layer.transform = CATransform3DMakeScale(0.1, 0.1, 1)
            
        UIView.animate(withDuration: 0.5) {
            myOrderCell.alpha = 1
            myOrderCell.center.x += 100
        }
        UIView.animate(withDuration: 0.5) {
            myOrderCell.layer.transform = CATransform3DMakeScale(1, 1, 1)
        }
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "myOrderCell", for: indexPath) as! MyOrderCollectionViewCell
        let order = arrMyOrders[indexPath.row]
        cell.setupCell(number: order.number, status: order.status, photo: order.image)
        return cell
    }

    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
            let selectedOrder = arrMyOrders[indexPath.row]
            
            // Access the serial number from the selected order
        let serialNumber = selectedOrder.number
            print("Selected Serial Number: \(serialNumber)")

            guard let cell = collectionView.cellForItem(at: indexPath) as? MyOrderCollectionViewCell else {
                return
            }

            // Apply animations to the selected cell
            UIView.animate(withDuration: 0.3, animations: {
                cell.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
                cell.alpha = 0.5
            }) { (_) in
                // Reset cell state
                UIView.animate(withDuration: 0.5) {
                    cell.transform = CGAffineTransform.identity
                    cell.alpha = 1.0
                    
                    guard let vcOrderHistory = self.storyboard?.instantiateViewController(withIdentifier: "ordershistory_ID") as? OrdersHistoryViewController else {
                        return
                    }
                        
                    // Pass data to CheckOutViewController
                    vcOrderHistory.orderNumber = serialNumber

                    // Push CheckOutViewController onto the navigation stack
                    self.navigationController?.pushViewController(vcOrderHistory, animated: true)
                }
            }
        }

    @IBAction func onClickBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
}


class MyOrderCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var qrImage: UIImageView!
    @IBOutlet weak var lblStatus: UILabel!
    @IBOutlet weak var lblOrderNumber: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupLayout()
        contentView.backgroundColor = UIColor.white // Set your desired background color
    }
        
    private func setupLayout() {
        qrImage.contentMode = .scaleAspectFit
        qrImage.translatesAutoresizingMaskIntoConstraints = false
        qrImage.widthAnchor.constraint(equalToConstant: 100).isActive = true // Set your desired width
        qrImage.heightAnchor.constraint(equalToConstant: 100).isActive = true // Set your desired height
    }
        
    func setupCell(number: String, status: String, photo: UIImage) {
        lblOrderNumber.text = "#\(number)"
        lblStatus.text = status
        qrImage.image = photo
    }
        
    override func layoutSubviews() {
        super.layoutSubviews()
        // Reset frame or update constraints here if needed
        qrImage.frame = CGRect(x: 0, y: 0, width: contentView.bounds.width, height: contentView.bounds.height)
    }
    
}
