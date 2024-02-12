import UIKit

class ServiceCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var imgServicePhoto: UIImageView!
    @IBOutlet weak var lblServiceText: UILabel!
    
    func setupCell(photo: UIImage, txt: String) {
        imgServicePhoto.image = photo
        lblServiceText.text = txt
        
    }
    
}
