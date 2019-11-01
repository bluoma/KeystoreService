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
        dlog("store secrets status: \(status)")
        if status < 0 {
            return false
        }
        
        
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
        
        let clientIdSecret = Secret(secretKey: SecretKeys.coinbaseClientIdKey, secretVal: clientId, secretType: .clientId)
        let clientSecretSecret = Secret(secretKey: SecretKeys.coinbaseClientSecretKey, secretVal: clientSecret, secretType: .clientSecret)
        
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

