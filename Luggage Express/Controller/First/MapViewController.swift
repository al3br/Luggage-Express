import UIKit
import MapKit
import Firebase

class MapViewController: UIViewController, MKMapViewDelegate {

    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let initialLoc = CLLocation(latitude: 25.2450944, longitude: 55.347221)
        setStartingLocation(location: initialLoc, distance: 200000)
        
        mapView.delegate = self

        // Initialize OrderManager instance
        let orderManager = OrderManager()

        // Call the function to search for orders for the logged-in user
        if let userID = getCurrentUserID() {
            orderManager.searchOrdersForUser(userID: userID, mapView: mapView)
        }
    }
    
    // Function to get the current user ID (you need to implement this)
    func getCurrentUserID() -> String? {
        guard let currentUser = Auth.auth().currentUser else {
            // Handle when the user is not logged in
            return ""
        }
        return currentUser.uid
    }
    
    @IBAction func onClickBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    func setStartingLocation(location: CLLocation, distance: CLLocationDistance) {
        let region = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: distance, longitudinalMeters: distance)
        mapView.setRegion(region, animated: true)
        mapView.setCameraBoundary(MKMapView.CameraBoundary(coordinateRegion: region), animated: true)
        let zoomRange = MKMapView.CameraZoomRange(maxCenterCoordinateDistance: 300000)
        mapView.setCameraZoomRange(zoomRange, animated: true)
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: "myCustomPin")
        annotationView.markerTintColor = UIColor(named: "Button")
        annotationView.tintColor = UIColor(named: "Icons")
        annotationView.glyphImage = UIImage(systemName: "suitcase")
        annotationView.glyphTintColor = UIColor.white
        return annotationView
    }
    
}
