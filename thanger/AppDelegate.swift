//
//  AppDelegate.swift
//  thanger
//
//  Created by Bill on 10/28/19.
//  Copyright © 2019 Bill. All rights reserved.
//

import UIKit

let clientId = "365104d205e7a9bb37ce6d185c4212b8c91cfaf4e499ef5b47a573c05e43c8e9"
let clientSecret = "0e242e11dfe27fd14cd80200a256fcdeac0813112487c734da64e8d65c664773"
let completionDeepLink = "com.bluoma.thanger://oauth/verification_complete"

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        return true
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

