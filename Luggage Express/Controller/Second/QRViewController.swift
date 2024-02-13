import UIKit
import SOTabBar
import AVFoundation
import Firebase

class QRViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    
    var captureSession: AVCaptureSession!
    var previewLayer: AVCaptureVideoPreviewLayer!
    var activityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupActivityIndicator()
        
        startCameraSession()
    }
    
    func setupActivityIndicator() {
        activityIndicator = UIActivityIndicatorView(style: .large)
        activityIndicator.center = view.center
        activityIndicator.hidesWhenStopped = true
        view.addSubview(activityIndicator)
    }
    
    func startCameraSession() {
            activityIndicator.startAnimating()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else {
                    print("Your device is not applicable for video processing")
                    self.showAlertAndNavigateBack(title: "Device Not Supported", message: "Your device is not applicable for video processing", action: "OK")
                    return
                }
                
                do {
                    let videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
                    self.captureSession = AVCaptureSession()
                    
                    if self.captureSession.canAddInput(videoInput) {
                        self.captureSession.addInput(videoInput)
                    } else {
                        print("Your device can not add input in capture session")
                        self.showAlertAndNavigateBack(title: "Error", message: "Your device can not add input in capture session", action: "OK")
                        return
                    }
                    
                    let metadataOutput = AVCaptureMetadataOutput()
                    
                    if self.captureSession.canAddOutput(metadataOutput) {
                        self.captureSession.addOutput(metadataOutput)
                        metadataOutput.metadataObjectTypes = [.ean8, .ean13, .pdf417]
                        metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
                    } else {
                        return
                    }
                    
                    // Add UIImageView for camera_corners
                    let imageView = UIImageView(image: UIImage(named: "camera_corners"))
                    imageView.contentMode = .center
                    imageView.frame = CGRect(x: (self.view.bounds.width - 100) / 2, y: (self.view.bounds.height - 100) / 2, width: 200, height: 200) // Adjust size and position as needed
                    self.view.addSubview(imageView)
                    
                    self.previewLayer = AVCaptureVideoPreviewLayer(session: self.captureSession)
                    self.previewLayer.frame = self.view.layer.bounds
                    self.previewLayer.videoGravity = .resizeAspectFill
                    self.view.layer.addSublayer(self.previewLayer)
                    
                    
                    
                    print("Running")
                    self.captureSession.startRunning()
                    self.activityIndicator.stopAnimating()
                } catch {
                    print("Your device can not give video input")
                    self.showAlertAndNavigateBack(title: "Error", message: "Your device can not give video input", action: "OK")
                    return
                }
            }
        }

    func showAlertAndNavigateBack(title: String, message: String, action: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: action, style: .default) { _ in
            // Dismiss the alert and navigate back to the previous screen
            // Force unwrap the navigation controller assuming it always exists
            guard let navigationController = self.navigationController else {
                fatalError("Navigation controller is unexpectedly nil")
            }

            guard let tabBarController = self.storyboard?.instantiateViewController(withIdentifier: "sotabbar") as? SOTabBarController else {
                print("Failed to instantiate TabBarController from storyboard")
                return
            }

            // Set the selected index of the tab bar controller to navigate to the first page
            tabBarController.selectedIndex = 0

            // Hide the back button before pushing the tab bar controller
            navigationController.navigationBar.topItem?.setHidesBackButton(true, animated: false)

            navigationController.pushViewController(tabBarController, animated: true)
        }
        alert.addAction(okAction)
        present(alert, animated: true, completion: nil)
    }
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        
        if let first = metadataObjects.first {
            guard let readableObject = first as? AVMetadataMachineReadableCodeObject else {
                return
            }
            guard let stringValue = readableObject.stringValue else {
                return
            }
            found(code: stringValue)
        } else {
            print("Not able to read the code! Please try again or be keep your device Bar Code or Scanner Code!")
        }
    }
    
    func found(code: String) {
        print(code)
        self.captureSession.stopRunning()
        let serialNumberText = code
        let serialNumber = Int(serialNumberText)!
        addToFirebase(number: serialNumber)
        showAlertAndNavigateBack(title: "Serial Number Detected", message: "Press add to add the serial number for your profile.", action: "Add")
    }
    
    func addToFirebase(number: Int) {
        // Assuming you have a reference to your Firebase Firestore database
        let db = Firestore.firestore()
        
        // Assuming you have a reference to the current user
        guard let currentUserID = Auth.auth().currentUser?.uid else {
            // Handle scenario where user is not logged in
            return
        }
        
        // Reference to the document for the current user
        let userRef = db.collection("users").document(currentUserID)
        
        // Add the serial number to the subcollection 'serialNumbers'
        userRef.collection("serialNumbers").addDocument(data: ["number": number]) { error in
            if let error = error {
                print("Error adding serial number: \(error)")
            } else {
                print("Serial number added successfully!")
            }
        }
    }
    


}
