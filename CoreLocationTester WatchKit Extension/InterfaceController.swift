//
//  InterfaceController.swift
//  CoreLocationTester WatchKit Extension
//
//  Created by Arnau Timoneda Heredia on 05/04/2019.
//  Copyright © 2019 Arnau Timoneda Heredia. All rights reserved.
//

import WatchKit
import Foundation
import CoreLocation
import WatchConnectivity

class InterfaceController: WKInterfaceController {

    @IBOutlet weak var textLabel: WKInterfaceLabel!
    
    private let locationManager = CLLocationManager()
    private var isUpdatingLocation = false
    private var log:String = ""
    private var lastLog:String = ""
    private let session = WCSession.default
    private var currentDistance:Double = 1
    @IBOutlet weak var OneButton: WKInterfaceButton!
    @IBOutlet weak var FiveButton: WKInterfaceButton!
    @IBOutlet weak var TenButton: WKInterfaceButton!
    
    lazy var notificationCenter: NotificationCenter = {
        return NotificationCenter.default
    }()

    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        currentDistance = 1
        // Configure interface objects here.
        locationManager.delegate = self
        locationManager.activityType = .fitness
        locationManager.distanceFilter = 1
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        //locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        locationManager.allowsBackgroundLocationUpdates = true
       
        OneButton.setBackgroundColor(.cyan)
        setupNotificationCenter()
        setupWatchConnectivity()
        print("(AW)awake method")
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        print("(AW)willActivate method")
        log += "Return from background mode..\n"
        super.willActivate()
        
        let authorizationStatus = CLLocationManager.authorizationStatus()
        handleLocationServicesAuthorizationStatus(status: authorizationStatus)
    }
    
    override func didDeactivate() {
        print("(AW)didDeactivate method")
        log += "Enter in background mode..\n"
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
    
    func handleLocationServicesAuthorizationStatus(status: CLAuthorizationStatus){
        switch status {
        case .notDetermined:
            handleLocationServicesStateNotDetermined()
        case .restricted, .denied:
            handleLocationServicesStateUnavailable()
        case .authorizedAlways, .authorizedWhenInUse:
            handleLocationServicesStateAvailable()
        @unknown default:
            print("(AW) Not knowed Auth status state")
        }
    }
    
    func handleLocationServicesStateNotDetermined() {
        textLabel.setText(TAGS.SET_LOCATION_ACCES)
        locationManager.requestWhenInUseAuthorization()
    }
    
    func handleLocationServicesStateUnavailable() {
        textLabel.setText(TAGS.LOCATION_DISABLED)
    }
    
    func handleLocationServicesStateAvailable() {
        textLabel.setText(TAGS.READY_TO_START)
    }
    
    @IBAction func setDistanceToOne() {
        if currentDistance != 1 {
            currentDistance = 1
            FiveButton.setBackgroundColor(nil)
            TenButton.setBackgroundColor(nil)
            OneButton.setBackgroundColor(.cyan)
            changeDistance()
        }
    }
    
    @IBAction func setDistanceToFive() {
        if currentDistance != 5 {
            currentDistance = 5
            OneButton.setBackgroundColor(nil)
            TenButton.setBackgroundColor(nil)
            FiveButton.setBackgroundColor(.cyan)
            changeDistance()
        }
    }
    
    @IBAction func setDistanceToTen() {
        if currentDistance != 20 {
            currentDistance = 20
            OneButton.setBackgroundColor(nil)
            FiveButton.setBackgroundColor(nil)
            TenButton.setBackgroundColor(.cyan)
            changeDistance()
        }
    }
    
    func changeDistance(){
        didPressStopButton()
        locationManager.distanceFilter = currentDistance
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.didPressStartButton()
        }
    }
    
    @IBAction func didPressStartButton() {
        if !isUpdatingLocation {
            isUpdatingLocation = true
            print("sesion activada")
            locationManager.startUpdatingLocation()
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy/MM/dd HH:mm:ss"
            let currentTime = formatter.string(from: Date())
            log = "\n\n*******New Session (\(currentTime)), with distance filter: \(currentDistance)*******\n"
        }
    }
    @IBAction func didPressStopButton() {
        if isUpdatingLocation {
            isUpdatingLocation = false
            print("sesion parada")
            locationManager.stopUpdatingLocation()
            textLabel.setText("NEW UPDATE..")
            DispatchQueue.main.async { () -> Void in
                let notificationCenter = NotificationCenter.default
                notificationCenter.post(name: Notification.Name(rawValue: NotificationCoreLocationWriteLog), object: nil)
                print("(AW)Notification posted")
            }
        }
    }
    
    func convertLocationToString(location: CLLocation) -> String{
        return "Lat/Long: (\(location.coordinate.latitude),\(location.coordinate.longitude), \(location.timestamp)) \n"
    }
    
    func sendLogsToPhone(_ notification:Notification){
        print("(AW) se ha llamado a send logs!!")
        if(WCSession.isSupported()){
            do {
                let data = ["test" : self.log]
                try session.updateApplicationContext(data)
                self.log = ""
                print("(AW) Datos enviados!")
            } catch {
                print("error")
            }
        }
    }
    
    // MARK: - Notification Center
    
    private func setupNotificationCenter() {
        print("(AW) notification service setup")
        notificationCenter.addObserver(forName: NSNotification.Name(rawValue: NotificationCoreLocationWriteLog), object: nil, queue: nil) { (notification:Notification) -> Void in
            
            self.sendLogsToPhone(notification)
            print("(AW) add observer called!")
        }
    }
    
}
// MARK: - Core Location
extension InterfaceController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        print("(AW)authorization has change to: \(status)")
        handleLocationServicesAuthorizationStatus(status: status)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let mostRecentLocation = locations.last else {
            return
        }
        let cuurentLog = convertLocationToString(location: mostRecentLocation)
        
        if lastLog != cuurentLog {
            lastLog = cuurentLog
            textLabel.setText(cuurentLog)
            print("(AW)Did update location: \(cuurentLog)")
            log += cuurentLog
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Swift.Error) {
        print("error:: \(error.localizedDescription)")
    }

}

// MARK: - Watch Connectivity
extension InterfaceController: WCSessionDelegate {
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        if let error = error {
            print("(AW) WC Session activation failed with error: \(error.localizedDescription)")
            return
        }
        print("(AW) Session activated with state:\(activationState.rawValue) ")
    }

    func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String : Any]) {
        // 2
        print("ea")
    }
    
    func setupWatchConnectivity(){
        if WCSession.isSupported() {
            print("(AW) Session is supported")
            session.delegate = self
            session.activate()
        }
    }
    
}
