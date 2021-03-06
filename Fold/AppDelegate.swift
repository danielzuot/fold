//
//  AppDelegate.swift
//  Fold
//
//  Created by Daniel Zuo on 1/11/16.
//  Copyright © 2016 Fold. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject) -> Bool {
        if url.scheme == URL_SCHEME {
            CoinbaseOAuth.finishOAuthAuthenticationForUrl(url, clientId: CLIENT_ID, clientSecret: CLIENT_SECRET, completion: { (result : AnyObject?, error: NSError?) -> Void in
                if let error = error {
                    // Could not authenticate.
                    NSLog("Could not authenticate")
                    let alert = UIAlertController(title: "OAuth Error", message: error.localizedDescription, preferredStyle: UIAlertControllerStyle.Alert)
                    alert.addAction(UIAlertAction(title: "Click", style: UIAlertActionStyle.Default, handler: nil))
                    self.window?.rootViewController?.presentViewController(alert, animated: true, completion: nil)
                } else {
                    // Tokens successfully obtained!
                    // Do something with them (store them, etc.)
                    NSLog("Tokens successfully obtained!")
                    if let result = result as? [String : AnyObject] {
                        let userDefaults = NSUserDefaults.standardUserDefaults()
                        
                        let accessToken = result["access_token"] as? String
                        let refreshToken = result["refresh_token"] as? String
                        let expiresIn = result["expires_in"] as? Int
                        
                        userDefaults.setValue(accessToken, forKey: "access_token")
                        userDefaults.setValue(refreshToken, forKey: "refresh_token")
                        userDefaults.setInteger(expiresIn!, forKey: "expires_in")
                        userDefaults.setDouble(NSDate().timeIntervalSince1970, forKey: "start_time")
                        
                        NSNotificationCenter.defaultCenter().postNotificationName(AUTH_SUCCESS_NOTIFICATION, object: result)
                    }
                }
            })
            return true
        }
        else {
            return false
        }
    }


}

