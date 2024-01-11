/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
The sample app's main view controller that manages the scanning process.
*/

import UIKit
import RoomPlan
import SceneKit

class RoomCaptureViewController: UIViewController, RoomCaptureViewDelegate, RoomCaptureSessionDelegate {
    
    @IBOutlet var exportButton: UIButton?
    
    @IBOutlet var doneButton: UIBarButtonItem?
    @IBOutlet var cancelButton: UIBarButtonItem?
    @IBOutlet var activityIndicator: UIActivityIndicatorView?
    
    private var isScanning: Bool = false
    
    private var roomCaptureView: RoomCaptureView!
    private var roomCaptureSessionConfig: RoomCaptureSession.Configuration = RoomCaptureSession.Configuration()
    
    private var finalResults: CapturedRoom?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        
        // Set up after loading the view.
        setupRoomCaptureView()
        activityIndicator?.stopAnimating()
    }
    
    private func setupRoomCaptureView() {
        roomCaptureView = RoomCaptureView(frame: view.bounds)
        roomCaptureView.captureSession.delegate = self
        roomCaptureView.delegate = self
        
        view.insertSubview(roomCaptureView, at: 0)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        startSession()
    }
    
    override func viewWillDisappear(_ flag: Bool) {
        super.viewWillDisappear(flag)
        stopSession()
    }
    
    private func startSession() {
        isScanning = true
        roomCaptureView?.captureSession.run(configuration: roomCaptureSessionConfig)
        
        setActiveNavBar()
    }
    
    private func stopSession() {
        isScanning = false
        roomCaptureView?.captureSession.stop()
        
        setCompleteNavBar()
    }
    
    // Decide to post-process and show the final results.
    func captureView(shouldPresent roomDataForProcessing: CapturedRoomData, error: Error?) -> Bool {
        return true
    }
    
    // Access the final post-processed results.
    func captureView(didPresent processedResult: CapturedRoom, error: Error?) {
        finalResults = processedResult
        self.exportButton?.isEnabled = true
        self.activityIndicator?.stopAnimating()
    }
    
    @IBAction func doneScanning(_ sender: UIBarButtonItem) {
        if isScanning { stopSession() } else { cancelScanning(sender) }
        self.exportButton?.isEnabled = false
        self.activityIndicator?.startAnimating()
    }

    @IBAction func cancelScanning(_ sender: UIBarButtonItem) {
        navigationController?.dismiss(animated: true)
    }
    
    // Export the USDZ output by specifying the `.parametric` export option.
    // Alternatively, `.mesh` exports a nonparametric file and `.all`
    // exports both in a single USDZ.
    @IBAction func exportResults(_ sender: UIButton) {
        showEmailAlert()
    }
    
    func finalizeResults() {
        let destinationFolderURL = FileManager.default.temporaryDirectory.appending(path: "Export")
        let destinationURL = destinationFolderURL.appending(path: "Room.usdz")
        let capturedRoomURL = destinationFolderURL.appending(path: "Room.json")
        do {
            try FileManager.default.createDirectory(at: destinationFolderURL, withIntermediateDirectories: true)
            let jsonEncoder = JSONEncoder()
            let jsonData = try jsonEncoder.encode(finalResults)
            try jsonData.write(to: capturedRoomURL)
            try finalResults?.export(to: destinationURL, exportOptions: .parametric)
            
//            let sceneModalVC = SceneModalViewController()
//            sceneModalVC.modalPresentationStyle = .automatic
//            sceneModalVC.usdzFileURL = destinationURL
//            present(sceneModalVC, animated: true) {
//                sceneModalVC.loadUSDZFile(fileURL: destinationURL)
//            }
            //loadUSDZInSceneView(fileURL: destinationURL)
            
//            let activityVC = UIActivityViewController(activityItems: [destinationFolderURL], applicationActivities: nil)
            
            // ONLY USDZ
            let activityVC = UIActivityViewController(activityItems: [destinationURL], applicationActivities: nil)
            activityVC.modalPresentationStyle = .popover
            
            present(activityVC, animated: true, completion: nil)
            if let popOver = activityVC.popoverPresentationController {
                popOver.sourceView = self.exportButton
            }
        } catch {
            print("Error = \(error)")
        }
    }
    
    func showEmailAlert() {
        // Create the alert controller
        let alertController = UIAlertController(title: "Enter Email", message: "Please enter your email address to join our mailing list", preferredStyle: .alert)

        // Add a text field
        alertController.addTextField { textField in
            textField.placeholder = "Email"
            textField.keyboardType = .emailAddress // Set the keyboard type to email
        }

        // Add a Submit action
        let submitAction = UIAlertAction(title: "Submit", style: .default) { [weak alertController] _ in
            // Retrieve the email from the text field
            if let email = alertController?.textFields?.first?.text {
                // Do something with the email
                print("Email entered: \(email)")
                self.finalizeResults()
            }
        }
        alertController.addAction(submitAction)

        // Add a Cancel action
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)

        // Present the alert
        self.present(alertController, animated: true)
    }
    
    // Function to load the USDZ file into a SCNView
    func loadUSDZInSceneView(fileURL: URL) {
        let sceneView = SCNView(frame: self.view.bounds)
        self.view.addSubview(sceneView)

        let scene = SCNScene(named: fileURL.path)
        sceneView.scene = scene
    }
    
    private func setActiveNavBar() {
        UIView.animate(withDuration: 1.0, animations: {
            self.cancelButton?.tintColor = .white
            self.doneButton?.tintColor = .white
            self.exportButton?.alpha = 0.0
        }, completion: { complete in
            self.exportButton?.isHidden = true
        })
    }
    
    private func setCompleteNavBar() {
        self.exportButton?.isHidden = false
        UIView.animate(withDuration: 1.0) {
            self.cancelButton?.tintColor = .systemBlue
            self.doneButton?.tintColor = .systemBlue
            self.exportButton?.alpha = 1.0
        }
    }
}

//import UIKit
//import SceneKit

class SceneModalViewController: UIViewController {
    var sceneView: SCNView!
    var shareButton: UIButton!
    var usdzFileURL: URL?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    private func setupUI() {
        // Scene View setup
        sceneView = SCNView(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: view.bounds.height - 50))
        sceneView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(sceneView)

        // Share Button setup
        shareButton = UIButton(frame: CGRect(x: 0, y: view.bounds.height - 50, width: view.bounds.width, height: 50))
        shareButton.setTitle("Share", for: .normal)
        shareButton.backgroundColor = .systemBlue
        shareButton.addTarget(self, action: #selector(shareButtonTapped), for: .touchUpInside)
        view.addSubview(shareButton)
    }

    @objc func shareButtonTapped() {
        guard let url = usdzFileURL else { return }
        let activityVC = UIActivityViewController(activityItems: [url], applicationActivities: nil)
        activityVC.modalPresentationStyle = .popover
        present(activityVC, animated: true, completion: nil)
    }

    func loadUSDZFile(fileURL: URL) {
        usdzFileURL = fileURL
        do {
            let scene = try SCNScene(url: fileURL, options: nil)
            sceneView.scene = scene
            // Additional setup...
        } catch {
            print("Error loading scene: \(error)")
        }
    }
    
    func loadUSDZFile2(fileURL: URL) {
        usdzFileURL = fileURL
        let scene = SCNScene(named: fileURL.path)
        sceneView.scene = scene
        // Add additional SceneKit setup here if needed

//        // Basic camera setup
//        let cameraNode = SCNNode()
//        cameraNode.camera = SCNCamera()
//        cameraNode.position = SCNVector3(x: 0, y: 5, z: 15)
//        scene?.rootNode.addChildNode(cameraNode)
//
//        // Basic lighting
//        let lightNode = SCNNode()
//        lightNode.light = SCNLight()
//        lightNode.light?.type = .omni
//        lightNode.position = SCNVector3(x: 0, y: 10, z: 10)
//        scene?.rootNode.addChildNode(lightNode)
//        
//        // Default spin animation
//        let spin = CABasicAnimation(keyPath: "rotation")
//        spin.toValue = NSValue(scnVector4: SCNVector4(x: 0, y: 1, z: 0, w: Float.pi * 2))
//        spin.duration = 10 // Adjust duration for the desired speed
//        spin.repeatCount = .infinity
//        scene?.rootNode.addAnimation(spin, forKey: "spin around")
    }
}
