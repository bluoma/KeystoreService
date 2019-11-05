//
//  AppDelegate.swift
//  thanger
//
//  Created by Bill on 10/28/19.
//  Copyright © 2019 Bill. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    
    var window: UIWindow?
    let secretService = SecretService()
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        let status = storeSecrets()
        precondition(status > 0, "error loading secrets")
        
        NetworkPlatform.load()
        
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
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        
        dlog("url: \(url), options: \(options)")
        let notifName = Notification.Name(rawValue: oauthRedirectNotification)
        NotificationCenter.default.post(name: notifName, object: url, userInfo: options)
        
        return true
    }
    
    private func storeSecrets() -> Int {
        var status = -1
        
        let secretsPlist = readPropertyList("secrets")
        guard let coinbaseDict = secretsPlist["Coinbase"] as? [String: AnyObject],
            let clientId = coinbaseDict["CoinbaseClientId"] as? String,
            let clientSecret = coinbaseDict["CoinbaseClientSecret"] as? String else {
                dlog("error getting coinbase client strings")
                return status
        }
        
        dlog("secrets.plist: \(secretsPlist)")
        
        let clientIdSecret = Secret(secretKey: SecretKeys.coinbaseClientIdKey, secretType: .string, secretValue: clientId)
        
        let clientSecretSecret = Secret(secretKey: SecretKeys.coinbaseClientSecretKey, secretType: .string, secretValue: clientSecret)
        
        secretService.storeSecret(clientIdSecret) { (secret: Secret?, error: Error?) in
            
            if let error = error {
                dlog("error storing clientId secret: \(error)")
                status = -2
            }
            else {
                dlog("stored clientId secret: \(String(describing: secret))")
                status = 2
            }
        }
        
        secretService.storeSecret(clientSecretSecret) { (secret: Secret?, error: Error?) in
            
            if let error = error {
                dlog("error storing clientSecret secret: \(error)")
                status = -3
            }
            else {
                dlog("stored clientSecret secret: \(String(describing: secret))")
                status = 3
            }
        }
        
        return status
    }
    
    // MARK: UISceneSession Lifecycle
    
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
    
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    
    
}

