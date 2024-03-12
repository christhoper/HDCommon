//
//  AppDelegate.swift
//  HDCommon
//
//  Created by hendy on 02/20/2024.
//  Copyright (c) 2024 hendy. All rights reserved.
//

import UIKit
import HDCommon

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var list: [UIImage] = []
    var window: UIWindow?
    var task: UIBackgroundTaskIdentifier?
    enum Test: Error {
    case one
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        let rootController = ViewController()
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = UINavigationController(rootViewController: rootController)
        window?.makeKeyAndVisible()
        HDCrashManager.shared.register()
        
        return true
    }

    func test(_ content: Int) -> Result<Bool, Test> {
        if content > 0 {
            return .success(true)
        } else {
            return .failure(.one)
        }
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        task = application.beginBackgroundTask(withName: "HDTask")
        
        DispatchQueue.global().async {
            for index in 0..<10000000000 {
                let image = UIImage()
                self.list.append(image)
                print("创建大对象\(index)")
            }
            
            application.endBackgroundTask(self.task!)
        }
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

