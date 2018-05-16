//
//  AppDelegate.swift
//  Mito 1.0
//
//  Created by Benny on 2/22/18.
//  Copyright © 2018 Benny Souriyadeth. All rights reserved.
//

import UIKit
import GooglePlaces
import GoogleMaps
import Starscream

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, WebSocketDelegate {
    func websocketDidConnect(socket: WebSocketClient) {
        print("websocket is connected")
    }
    
    func websocketDidDisconnect(socket: WebSocketClient, error: Error?) {
        if let e = error as? WSError {
            print("websocket is disconnected: \(e.message)")
        } else if let e = error {
            print("websocket is disconnected: \(e.localizedDescription)")
        } else {
            print("websocket disconnected")
        }
    }
    
    func websocketDidReceiveMessage(socket: WebSocketClient, text: String) {
        
        //        print("Received text: \(text)")
        let jsonData = text.data(using: .utf8)
        let dictionary = try? JSONSerialization.jsonObject(with: jsonData!, options: .mutableLeaves) as! NSDictionary
        let dictType = dictionary!["type"] as! String
        switch dictType {
        case "friend-request":
            print("friend-request")
        case "friend-accept":
            print("friend-accept")
        case "package-accept":
            print("package-accept")
        case "package-denied":
            print("package-denied")
        default:
            print("default message")
        }
//        print(dictionary as Any)
    }
    
    func websocketDidReceiveData(socket: WebSocketClient, data: Data) {
        print("Received data: \(data.count)")
    }
    

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        let storyboard = UIStoryboard(name: "Login", bundle: nil)
        self.window?.rootViewController = storyboard.instantiateViewController(withIdentifier: "Open")
        GMSPlacesClient.provideAPIKey("AIzaSyBaLXoC_V215C_baCdiok-OSNSCJhJ1DvI")
        GMSServices.provideAPIKey("AIzaSyBaLXoC_V215C_baCdiok-OSNSCJhJ1DvI")
        UINavigationBar.appearance().barTintColor = UIColor(red:0.25, green:0.87, blue:0.49, alpha:1.0)
        UINavigationBar.appearance().tintColor = UIColor.white
        UINavigationBar.appearance().titleTextAttributes = [NSAttributedStringKey.foregroundColor : UIColor.white]
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

