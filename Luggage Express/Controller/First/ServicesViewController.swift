import UIKit

class ServicesViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    var arrServices = [Service]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        
        collectionView.delegate = self
        collectionView.dataSource = self

        arrServices.append(Service(photo: UIImage(named: "641c38ed-13e9-4881-9dd3-e2201ef08aa6")!, text: "Track Your Luggage"))
        arrServices.append(Service(photo: UIImage(named: "27d2844b-81aa-49f7-a38f-312e3bba9908")!, text: "Fast Arrival Luggage"))
        arrServices.append(Service(photo: UIImage(named: "ecf2277e-34b9-4570-b3e2-915ccf9ee62c")!, text: "Book Arrival Luggage"))
        arrServices.append(Service(photo: UIImage(named: "9cb6400d-b3e3-44af-9e27-5aa475e13bc8")!, text: "Lost / Damaged Report"))
        arrServices.append(Service(photo: UIImage(named: "292a641d-89bf-41c3-8f37-adffdac17ce4")!, text: "Complaints & Suggestions"))
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return arrServices.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "serviceCell", for: indexPath) as! ServiceCollectionViewCell
        let service = arrServices[indexPath.row]
        cell.setupCell(photo: service.photo, txt: service.text)
        //cell.backgroundColor = UIColor.yellow
        //let yellowColor = UIColor(red: 255/255, green: 255/255, blue: 0/255, alpha: 1.0)
        //cell.backgroundColor = yellowColor
        cell.alpha = 0
        cell.center.x -= 100
        cell.layer.transform = CATransform3DMakeScale(0.1, 0.1, 1)
        UIView.animate(withDuration: 1) {
            cell.alpha = 1
            cell.center.x += 100
        }
        UIView.animate(withDuration: 1) {
            cell.layer.transform = CATransform3DMakeScale(1, 1, 1)
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // Retrieve the selected service
        let selectedService = arrServices[indexPath.row]
        // Get the selected cell
        guard let cell = collectionView.cellForItem(at: indexPath) as? ServiceCollectionViewCell else {
            return
        }
        // Apply animations to the selected cell
        UIView.animate(withDuration: 0.3, animations: {
            cell.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
            cell.alpha = 0.5
        }) { (_) in
            // Completion block - Navigate to the next view controller
            if selectedService.text == "Track Your Luggage" {
                self.navigateToView(identifier: "MapViewController")
            } else if selectedService.text == "Fast Arrival Luggage" {
                self.navigateToView(identifier: "FastArrivalViewController")
            } else if selectedService.text == "Book Arrival Luggage" {
                self.navigateToView(identifier: "BookArrivalViewController")
            } else if selectedService.text == "Lost / Damaged Report" {
                self.navigateToView(identifier: "report_id")
            } else if selectedService.text == "Complaints & Suggestions" {
                self.navigateToView(identifier: "feedback_ID")
            } else {
                print("Service Not Found")
            }
            // Reset cell state
            UIView.animate(withDuration: 0.5) {
                cell.transform = CGAffineTransform.identity
                cell.alpha = 1.0
            }
        }
  
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
    
    func navigateToView(identifier: String) {
        guard let destinationViewController = storyboard?.instantiateViewController(withIdentifier: identifier) else {
            print("Failed to instantiate view controller with identifier: \(identifier)")
            return
        }
        // Optionally, configure destinationViewController if needed
        navigationController?.pushViewController(destinationViewController, animated: true)
    }
    
}
