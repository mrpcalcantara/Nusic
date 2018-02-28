//
//  AppDelegate.swift
//  Nusic
//
//  Created by Miguel Alcantara on 28/08/2017.
//  Copyright © 2017 Miguel Alcantara. All rights reserved.
//

import UIKit
import Firebase
import SafariServices
import PopupDialog
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var auth = SPTAuth()
    var safariViewController: SFSafariViewController?
    var gcmMessageIDKey = "gcmMessageKey"
    
    var fcmTokenId = "" {
        didSet {
            if fcmTokenId != "" {
                UserDefaults.standard.set(fcmTokenId, forKey: "fcmTokenId")
            }
        }
    }
    var deviceTokenId = "" {
        didSet {
            if deviceTokenId != "" {
                UserDefaults.standard.set(deviceTokenId, forKey: "apnsDeviceTokenId")
            }
        }
    }

    func application(_ application: UIApplication, willFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey : Any]? = nil) -> Bool {
        print("WILL LAUNCH WITH OPTIONS")
        return true
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        if let notifInfo = launchOptions?[UIApplicationLaunchOptionsKey.remoteNotification] as? [AnyHashable: Any] {
            handleReceivedRemoteNotification(userInfo: notifInfo)
        }
        // Setup Firebase
        FirebaseApp.configure();
        
        Messaging.messaging().delegate = self
        registerForPushNotifications()
        
        // Setup Spotify Values
        

        auth.redirectURL     = URL(string: Spotify.redirectURI!)
        auth.sessionUserDefaultsKey = "current session"
        auth.tokenSwapURL = URL(string: Spotify.swapURL!);
        auth.tokenRefreshURL = URL(string: Spotify.refreshURL!);
        
        
        

        setupNavigationBarAppearance()
        setupPopupDialogAppearance()
        
        //NOTE: DELETE WHEN RELEASE. Suppressing the constraint errors for the cards
//        UserDefaults.standard.setValue(true, forKey:"_UIConstraintBasedLayoutLogUnsatisfiable")
//        UserDefaults.standard.setValue(false, forKey:"_UIConstraintBasedLayoutLogUnsatisfiable")
        
        UserDefaults.standard.setValue(false, forKey: "appOpened")
        
        
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
                
//                let session = URLSession.shared.
                if error != nil || session == nil {
                    print("error!: \(String(describing: error?.localizedDescription))")
                    NotificationCenter.default.post(name: Notification.Name(rawValue: "loginUnsuccessful"), object: false)
                } else {
                    // 5- Add session to User Defaults
                    let userDefaults = UserDefaults.standard
                    let sessionData = NSKeyedArchiver.archivedData(withRootObject: session!)
                    userDefaults.set(sessionData, forKey: "SpotifySession")
                    userDefaults.synchronize()
//
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
        print("APP WILL RESIGN ACTIVE")
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        print("APP DID ENTER BACKGROUND")
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
        print("APP WILL ENTER FOREGROUND")
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        
        print("APP ACTIVE")
    }

    func applicationWillTerminate(_ application: UIApplication) {
        print("APP WILL TERMINATE")
        UserDefaults.standard.setValue(false, forKey: "appOpened")
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    func applicationDidReceiveMemoryWarning(_ application: UIApplication) {
        print("MEMORY WARNING")
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Messaging.messaging().apnsToken = deviceToken
        let tokenParts = deviceToken.map { data -> String in
            return String(format: "%02.2hhx", data)
        }
        
        let token = tokenParts.joined()
        deviceTokenId = token
        print("Device Token: \(token)")
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Failed to register: \(error)")
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
        
        let buttonAppearance = DefaultButton.appearance()
        
        // Default button
        buttonAppearance.titleFont      = UIFont(name: "Futura", size: 16)!
        buttonAppearance.titleColor     = NusicDefaults.foregroundThemeColor
        buttonAppearance.buttonColor    = UIColor(white: 0.15, alpha: 1)
        buttonAppearance.separatorColor = UIColor(white: 0.9, alpha: 1)
        
        // Below, only the differences are highlighted
        
        // Default Button
        
        
        // Cancel button
        CancelButton.appearance().titleColor = UIColor.lightGray
        
        // Destructive button
        DestructiveButton.appearance().titleColor = UIColor.red
    }
    
    func registerForPushNotifications() {
        UNUserNotificationCenter.current().delegate = self
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) {
            (granted, error) in
            print("Permission granted: \(granted)")
            
            guard granted else { return }
            self.getNotificationSettings()

        }
    }
    
    func getNotificationSettings() {
        UNUserNotificationCenter.current().getNotificationSettings { (settings) in
            print("Notification settings: \(settings)")
            guard settings.authorizationStatus == .authorized else { return }
            DispatchQueue.main.async {
                UIApplication.shared.registerForRemoteNotifications()
            }
        }
    }


}

extension AppDelegate : UNUserNotificationCenterDelegate {
    
    // Receive displayed notifications for iOS 10 devices.
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        let userInfo = notification.request.content.userInfo
        
        // With swizzling disabled you must let Messaging know about the message, for Analytics
        // Messaging.messaging().appDidReceiveMessage(userInfo)
        
        // Print message ID.
        if let messageID = userInfo[gcmMessageIDKey] {
            print("Message ID: \(messageID)")
        }
        
        // Print full message.
        print(userInfo)
        
        if UIApplication.shared.applicationState == .active {
            if let rootVC = UIApplication.shared.keyWindow?.rootViewController as? NusicPageViewController {
                setupPopupDialogAppearance()
                let alert = PopupDialog(title: "Test", message: "test message")
                let action1 = { () -> Void in
                    self.handleReceivedRemoteNotification(userInfo: userInfo)
                }
                
                let action2 = { () -> Void in
                    alert.dismiss(animated: true, completion: nil)
                }
                let button1 = PopupDialogButton(title: "Show Me!", action: action1)
                let button2 = PopupDialogButton(title: "Cancel", action: action2)
                alert.addButtons([button1, button2])
                
                rootVC.present(alert, animated: true, completion: nil)
            }
        }
        
        // Change this to your preferred presentation option
        completionHandler([])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        handleReceivedRemoteNotification(userInfo: userInfo)
        
        completionHandler()
    }
}

extension AppDelegate : MessagingDelegate {
    // [START refresh_token]
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String) {
        print("Firebase registration token: \(fcmToken)")
        fcmTokenId = fcmToken
        // TODO: If necessary send token to application server.
        // Note: This callback is fired at each app startup and whenever a new token is generated.
    }
    // [END refresh_token]
    
    // [START ios_10_data_message]
    // Receive data messages on iOS 10+ directly from FCM (bypassing APNs) when the app is in the foreground.
    // To enable direct data messages, you can set Messaging.messaging().shouldEstablishDirectChannel to true.
    func messaging(_ messaging: Messaging, didReceive remoteMessage: MessagingRemoteMessage) {
        print("Received data message: \(remoteMessage.appData)")
        
    }
    
    func handleReceivedRemoteNotification(userInfo: [AnyHashable: Any]) {
        // Print message ID.
        //        let mainStoryboard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        //        let initialViewController: NusicPageViewController = mainStoryboard.instantiateViewController(withIdentifier: "nusicPageViewController") as! NusicPageViewController
        UIApplication.shared.applicationIconBadgeNumber += 1
        UserDefaults.standard.set(userInfo["spotifyTrackId"] as! String, forKey: "suggestedSpotifyTrackId")
        UserDefaults.standard.synchronize()
        NotificationCenter.default.post(name: Notification.Name(rawValue: "nusicADayNotificationPushed"), object: nil)
        print(userInfo["spotifyTrackId"])
        if let messageID = userInfo[gcmMessageIDKey] {
            print("Message ID: \(messageID)")
        }
        //
        //        self.window = UIWindow(frame: UIScreen.main.bounds)
        //        self.window?.rootViewController = initialViewController
        //        self.window?.makeKeyAndVisible()
        //
        // Print full message.
        print(userInfo)
    }
    // [END ios_10_data_message]
}

