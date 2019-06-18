//
//  ViewController.swift
//  CoreLocationTester
//
//  Created by Arnau Timoneda Heredia on 05/04/2019.
//  Copyright © 2019 Arnau Timoneda Heredia. All rights reserved.
//

import UIKit
import CoreLocation

class CLTViewController: UIViewController {
    
    private let locationManager = CLLocationManager()
    @IBOutlet weak var textView: UITextView!
    
    lazy var notificationCenter: NotificationCenter = {
        return NotificationCenter.default
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        locationManager.delegate = self
        print("(I)viewDidLoad")
        let authorizationStatus = CLLocationManager.authorizationStatus()
        switch authorizationStatus {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .restricted, .denied:
            promptUserForAuthorizationStatusOtherThanAuthorized()
        case .authorizedAlways, .authorizedWhenInUse:
            print("Authorized OK")
        @unknown default:
            print("(I) Not knowed Auth status state")
        }
        textView.text = "Let's Go!"
        setupNotificationCenter()
    }
    
    private func promptUserForAuthorizationStatusOtherThanAuthorized() {
        let title = TAGS.LOCATION_ACCES_DISABLED
        let message = TAGS.AUTHORIZATHION_MESSAGE
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: TAGS.CANCEL, style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        
        let openAction = UIAlertAction(title: TAGS.OPEN_SETTINGS, style: .default) { (action) in
            if let url = URL(string:UIApplication.openSettingsURLString) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }
        alertController.addAction(openAction)
        present(alertController, animated: true, completion: nil)
    }
    
    
    @IBAction func readLogs(_ sender: Any) {
        let logs = LogManager.sharedInstance.readFile()
        print("(I) LOGS READED: \(logs)")
        self.textView.text = logs
    }
    
    @IBAction func deleteLogs(_ sender: Any) {
        LogManager.sharedInstance.clearFile()
        self.textView.text = ""
    }
    // MARK: - Notification Center
    

    private func setupNotificationCenter() {
        notificationCenter.addObserver(forName: NSNotification.Name(rawValue: NotificationCoreLocationWriteLog), object: nil, queue: nil) { (notification:Notification) -> Void in
            print("(I)add observer!")
            self.textView.text = "ieep! counter: nah"
        }
    }

    
}

// MARK: CoreLocation
extension CLTViewController: CLLocationManagerDelegate{
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .authorizedAlways, .authorizedWhenInUse:
            print("Authorization did change to OK")
        case .notDetermined:
            manager.requestWhenInUseAuthorization()
        case .restricted, .denied:
            promptUserForAuthorizationStatusOtherThanAuthorized()
        @unknown default:
             print("(AW) Not knowed Auth status state")
        }
    }
}
