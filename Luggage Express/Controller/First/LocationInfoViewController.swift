import UIKit
import MapKit

class LocationInfoViewController: UIViewController, MKMapViewDelegate {

    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var mapView: MKMapView!
    
    var prevLocation : CLLocation? = nil
    var Longitude: Double = 0.0
    var Latitude: Double = 0.0
    
    var outsideChecked: Bool = true
    var selectedLuggage: String = ""
    var comment: String = ""
    var total: Double = 0.0
    var serialNumber: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        mapView.delegate = self
    }
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        let newLocation = CLLocation(latitude: mapView.centerCoordinate.latitude, longitude: mapView.centerCoordinate.longitude)
        if prevLocation == nil || prevLocation!.distance(from: newLocation) > 10 {
            if prevLocation != nil {
                //print("distance: \(prevLocation!.distance(from: newLocation))")
            }
        }
        Longitude = newLocation.coordinate.longitude
        Latitude = newLocation.coordinate.latitude
        getLocationInfo(location: newLocation)
    }
    

    func getLocationInfo(location: CLLocation) {
        prevLocation = location
        let geoCoder = CLGeocoder()
        geoCoder.reverseGeocodeLocation(location) { places, error in
            guard let place = places?.first, error == nil else {return}
            
            print("-----")
            print("place name \(place.name ?? "no name to display")")
            print("Longitude: \(self.Longitude), Latitude: \(self.Latitude)")
        }
    }
    
    
    @IBAction func onClickNext(_ sender: Any) {
        // Scale animation for the button
            UIView.animate(withDuration: 0.1, animations: {
                self.nextButton.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
            }, completion: { _ in
                UIView.animate(withDuration: 0.1) {
                    self.nextButton.transform = CGAffineTransform.identity
                }
            })
        guard let vcCheckOut = storyboard?.instantiateViewController(withIdentifier: "checkout_ID") as? CheckOutViewController else {
                return
            }
            
            // Pass data to CheckOutViewController
            vcCheckOut.outsideChecked = outsideChecked
            vcCheckOut.selectedLuggage = selectedLuggage
            vcCheckOut.comment = comment
            vcCheckOut.total = total
            vcCheckOut.Longitude = Longitude
            vcCheckOut.Latitude = Latitude
            
            // Push CheckOutViewController onto the navigation stack
            navigationController?.pushViewController(vcCheckOut, animated: true)
    }
    
}
