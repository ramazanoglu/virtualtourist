//
//  AppDelegate.swift
//  VirtualTourist
//
//  Created by Gokturk Ramazanoglu on 29.11.17.
//  Copyright © 2017 udacity. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func checkIfFirstLaunch() {
        if UserDefaults.standard.bool(forKey: "HasLaunchedBefore") {
            print("App has launched before")
        } else {
            print("This is the first launch ever!")
            UserDefaults.standard.set(true, forKey: "HasLaunchedBefore")
            UserDefaults.standard.set(48.774515, forKey: "centerLat")
            UserDefaults.standard.set(9.173, forKey: "centerLong")
            UserDefaults.standard.set(2, forKey: "latDelta")
            UserDefaults.standard.set(2, forKey: "longDelta")
            UserDefaults.standard.synchronize()
        }
    }


    func application(_ application: UIApplication, willFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey : Any]? = nil) -> Bool {
        checkIfFirstLaunch()
        return true
    }


}

