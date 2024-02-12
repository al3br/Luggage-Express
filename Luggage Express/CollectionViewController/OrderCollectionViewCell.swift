import UIKit

class OrderCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var lblDescription: UILabel!
    @IBOutlet weak var lblTime: UILabel!
    @IBOutlet weak var lblDate: UILabel!
    
    
    func setupCell(date: String, time: String, description: String) {
        lblDate.text = date
        lblTime.text = time
        lblDescription.text = description
        
    }
    
    
}

