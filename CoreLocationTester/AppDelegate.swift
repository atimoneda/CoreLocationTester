//
//  AppDelegate.swift
//  CoreLocationTester
//
//  Created by Arnau Timoneda Heredia on 05/04/2019.
//  Copyright © 2019 Arnau Timoneda Heredia. All rights reserved.
//

import UIKit
import WatchConnectivity

let NotificationCoreLocationWriteLog = "CLWriteLog"
let NotificationCoreLocationWriteLogTEST = "CLWriteLogTEST"

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    lazy var notificationCenter: NotificationCenter = {
        return NotificationCenter.default
    }()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        print("(I) didfinishLaunch")
        setupWatchConnectivity()
        //setupNotificationCenter()
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
        
}

// MARK: - Watch Connectivity
extension AppDelegate: WCSessionDelegate{
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        if let error = error {
            print("WC Session activation failed with errer: \(error.localizedDescription)")
            return
        }
        print("WC Session activated with state: \(activationState.rawValue)")
    }
    
    func sessionDidBecomeInactive(_ session: WCSession) {
        print("WC Session did become inactive")
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
        print("WC Session did deactivate")
        WCSession.default.activate()
    }
    
    func setupWatchConnectivity(){
        if WCSession.isSupported() {
            let session = WCSession.default
            session.delegate = self
            session.activate()
            print("(I) WC supported!")
        }
    }
    
    func sendMessageToWatch(_ notification: Notification){
        if WCSession.isSupported() {
            let session = WCSession.default
            if session.isWatchAppInstalled {
                // 4
                do {
                    let dictionary = ["test": "tests"]
                    try session.updateApplicationContext(dictionary)
                } catch {
                    print("ERROR: \(error)")
                }
            }
        }
    }
    
    func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String : Any]) {
        print("(I)se ha recibido algo")
        if let logs = applicationContext["test"] as? String {
            print("(I) Hemos obtenido: \(logs)")
            LogManager.sharedInstance.writeFileWith(line: logs)
        }
        DispatchQueue.main.async {
            let notificationCenter = NotificationCenter.default
            notificationCenter.post(
                name: NSNotification.Name(rawValue: NotificationCoreLocationWriteLog), object: nil)
            print("(I)Post notification")
        }
        
    }
    
}
