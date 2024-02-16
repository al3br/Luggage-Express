import UIKit
import Firebase

class MyOrderViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    var arrMyOrders = [MyOrder]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        collectionView.delegate = self
        collectionView.dataSource = self

        fetchOrdersForCurrentUser()
        
        
    }
    
    func fetchOrdersForCurrentUser() {
        guard let currentUser = Auth.auth().currentUser else {
            return
        }

        var myOrders: [MyOrder] = []

        let db = Firestore.firestore()
        let ordersRef = db.collection("orders")

        ordersRef.whereField("user_id", isEqualTo: currentUser.uid)
            .order(by: "date", descending: true)
            .getDocuments { (snapshot, error) in
            if let error = error {
                print("Error: \(error)")
                return
            }

            guard let snapshot = snapshot else {
                
                return
            }

            for document in snapshot.documents {
                if let orderID = document.data()["order_id"] as? Int,
                   let status = document.data()["status"] as? String {
                    
                    // Assuming you have a QR code image
                    let qrCodeImage = UIImage(named: "qr_code")!

                    let myOrder = MyOrder(number: "\(orderID)", status: "Status: \(status)", image: qrCodeImage)
                    myOrders.append(myOrder)
                }
            }
            // Assign the fetched orders to arrMyOrders
            self.arrMyOrders = myOrders

            self.collectionView.reloadData()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return arrMyOrders.count
    }
    
    // Implement the delegate method to set the size for each item (cell)
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        // Adjust the size of your cell here
        return CGSize(width: self.view.frame.width * 0.9, height: self.view.frame.width * 0.5) // Adjust the width and height as needed
    }
        
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 50
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "myOrderCell", for: indexPath) as! MyOrderCollectionViewCell
        let order = arrMyOrders[indexPath.row]
        cell.setupCell(number: order.number, status: order.status, photo: order.image)
        cell.alpha = 0
        cell.center.x -= 100
        cell.layer.transform = CATransform3DMakeScale(0.1, 0.1, 1)
        UIView.animate(withDuration: 0.5) {
            cell.alpha = 1
            cell.center.x += 100
        }
        UIView.animate(withDuration: 0.5) {
            cell.layer.transform = CATransform3DMakeScale(1, 1, 1)
        }
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
        // Add constraints to qrImage here if using Auto Layout
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
