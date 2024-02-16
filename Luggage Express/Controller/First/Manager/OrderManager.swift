import Foundation
import Firebase
import MapKit

class OrderManager {
    
    // Function to search for orders placed by the same logged-in user ID
    func searchOrdersForUser(userID: String, mapView: MKMapView) {
        let db = Firestore.firestore()
        let ordersRef = db.collection("orders").whereField("user_id", isEqualTo: userID)
        
        ordersRef.getDocuments { (querySnapshot, error) in
            if let error = error {
                print("Error getting orders: \(error.localizedDescription)")
                return
            }
            
            guard let documents = querySnapshot?.documents else {
                print("No orders found for the user")
                return
            }
            
            for document in documents {
                guard let latitude = document.data()["latitude"] as? Double,
                      let longitude = document.data()["longitude"] as? Double,
                      let status = document.data()["status"] as? String else {
                    continue
                }
                
                // Place a marker on the map for each order
                let annotation = MKPointAnnotation()
                annotation.coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
                annotation.title = "Order Location"
                annotation.subtitle = status
                mapView.addAnnotation(annotation)
            }
        }
    }
}
