//
//  AppDelegate.swift
//  CookieCutterCutter
//
//  Created by Andrew Pouliot on 8/23/14.
//
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
                            
  var window: UIWindow?

  func application(application: UIApplication!, didFinishLaunchingWithOptions launchOptions: NSDictionary!) -> Bool {

    window = UIWindow(frame: UIScreen.mainScreen().applicationFrame)

    var vc : UIViewController = ViewController()
    window?.rootViewController = vc

    window?.makeKeyAndVisible()

    return true
  }
}

