//
//  AppDelegate.swift
//  Newsic
//
//  Created by Miguel Alcantara on 28/08/2017.
//  Copyright © 2017 Miguel Alcantara. All rights reserved.
//

import UIKit
import Firebase
import SafariServices
import PopupDialog

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var auth = SPTAuth()
    var safariViewController: SFSafariViewController?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Setup Spotify Values
        
        auth.redirectURL     = URL(string: Spotify.redirectURI!)
        auth.sessionUserDefaultsKey = "current session"
        auth.tokenSwapURL = URL(string: Spotify.swapURL!);
        auth.tokenRefreshURL = URL(string: Spotify.refreshURL!);
        
        
        // Setup Firebase
        FirebaseApp.configure();

        setupNavigationBarAppearance()
        setupPopupDialogAppearance()
        
        //NOTE: DELETE WHEN RELEASE. Suppressing the constraint errors for the cards
//        UserDefaults.standard.setValue(true, forKey:"_UIConstraintBasedLayoutLogUnsatisfiable")
//        UserDefaults.standard.setValue(false, forKey:"_UIConstraintBasedLayoutLogUnsatisfiable")
        
        
        // Override point for customization after application launch.
        return true
    }
    
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        safariViewController?.dismiss(animated: true, completion: nil)
        // 2- check if app can handle redirect URL
        if auth.canHandle(url) {
            // 3 - handle callback in closure
            auth.handleAuthCallback(withTriggeredAuthURL: url, callback: { (error, session) in
                // 4- handle error
                
                if error != nil || session == nil {
                    print("error!: \(String(describing: error?.localizedDescription))")
                    NotificationCenter.default.post(name: Notification.Name(rawValue: "loginUnsuccessful"), object: false)
                } else {
                    // 5- Add session to User Defaults
                    
                    let userDefaults = UserDefaults.standard
                    let sessionData = NSKeyedArchiver.archivedData(withRootObject: session!)
                    userDefaults.set(sessionData, forKey: "SpotifySession")
                    userDefaults.synchronize()
                    
                    // 6 - Tell notification center login is successful
                    NotificationCenter.default.post(name: Notification.Name(rawValue: "loginSuccessful"), object: true)
                }
                
            })
            
            return true
        }
        return false
        
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

    func setupNavigationBarAppearance() {
        let navigationBarAppearance = UINavigationBar.appearance()
        navigationBarAppearance.shadowImage = UIImage();
        navigationBarAppearance.setBackgroundImage(UIImage(), for: .default);
        navigationBarAppearance.tintColor = UIColor.white
        navigationBarAppearance.barTintColor = UIColor.white
        // change navigation item title color
        navigationBarAppearance.titleTextAttributes = [NSAttributedStringKey.foregroundColor:UIColor.black]
    }
    
    func setupPopupDialogAppearance() {
        let dialogAppearance = PopupDialogDefaultView.appearance()
        dialogAppearance.titleFont            = UIFont(name: "Futura", size: 16)!
        dialogAppearance.titleColor           = UIColor(white: 1, alpha: 1)
        dialogAppearance.titleTextAlignment   = .center
        dialogAppearance.messageFont          = UIFont(name: "Futura", size: 16)!
        dialogAppearance.messageColor         = UIColor(white: 0.6, alpha: 1)
        dialogAppearance.messageTextAlignment = .center
        
        let containerAppearance = PopupDialogContainerView.appearance()
        
        containerAppearance.backgroundColor = UIColor(white: 0.15, alpha: 1)
        containerAppearance.cornerRadius    = 2
        containerAppearance.shadowEnabled   = true
        containerAppearance.shadowColor     = UIColor.black
        
        //        let overlayAppearance = PopupDialogOverlayView.appearance()
        //
        //        overlayAppearance.color       = UIColor.black
        //        overlayAppearance.blurRadius  = 20
        //        overlayAppearance.blurEnabled = true
        //        overlayAppearance.liveBlur    = false
        //        overlayAppearance.opacity     = 0.7
        
        let buttonAppearance = DefaultButton.appearance()
        
        // Default button
        buttonAppearance.titleFont      = UIFont(name: "Futura", size: 16)!
        buttonAppearance.titleColor     = UIColor.green
        buttonAppearance.buttonColor    = UIColor(white: 0.15, alpha: 1)
        buttonAppearance.separatorColor = UIColor(white: 0.9, alpha: 1)
        
        // Below, only the differences are highlighted
        
        // Default Button
        
        
        // Cancel button
        CancelButton.appearance().titleColor = UIColor.lightGray
        
        // Destructive button
        DestructiveButton.appearance().titleColor = UIColor.red
    }
}

