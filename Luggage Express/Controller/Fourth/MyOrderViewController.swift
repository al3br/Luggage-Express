import UIKit

class MyOrderViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    var arrMyOrders = [MyOrder]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        collectionView.delegate = self
        collectionView.dataSource = self

        arrMyOrders.append(MyOrder(number: "#1000024", status: "Status: Approved", image: UIImage(named: "qr_code")!))
        arrMyOrders.append(MyOrder(number: "#1000026", status: "Status: Pending", image: UIImage(named: "qr_code")!))
        arrMyOrders.append(MyOrder(number: "#1000028", status: "Status: Canceled", image: UIImage(named: "qr_code")!))
        arrMyOrders.append(MyOrder(number: "#1000030", status: "Status: Pending", image: UIImage(named: "qr_code")!))
        arrMyOrders.append(MyOrder(number: "#1000035", status: "Status: Pending", image: UIImage(named: "qr_code")!))

        
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
        lblOrderNumber.text = number
        lblStatus.text = status
        qrImage.image = photo
    }
        
    override func layoutSubviews() {
        super.layoutSubviews()
        // Reset frame or update constraints here if needed
        qrImage.frame = CGRect(x: 0, y: 0, width: contentView.bounds.width, height: contentView.bounds.height)
    }
    
}
