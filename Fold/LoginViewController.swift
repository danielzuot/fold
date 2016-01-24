//
//  LoginViewController.swift
//  Fold
//
//  Created by Daniel Zuo on 1/15/16.
//  Copyright © 2016 Fold. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {
    
    @IBOutlet weak var loginButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "authenticationSuccessful:", name: AUTH_SUCCESS_NOTIFICATION, object: nil)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    
    }
    
    @IBAction func authenticateLogin(sender: AnyObject) {
        CoinbaseOAuth.startOAuthAuthenticationWithClientId(
            CLIENT_ID,
            scope: USER_SCOPE,
            redirectUri: REDIRECT_URI,
            meta: nil
        )
    }
    
    dynamic private func authenticationSuccessful(notification: NSNotification) {
        NSLog("Notification received: Authentication successful! Tokens retrieved.")
        if let response = notification.object as? [String : AnyObject] {
            let userDefaults = NSUserDefaults.standardUserDefaults()
            
            let accessToken = response["access_token"] as? String
            let refreshToken = response["refresh_token"] as? String
            let expiresIn = response["expires_in"] as? String
            
            userDefaults.setValue(accessToken, forKey: "access_token")
            userDefaults.setValue(refreshToken, forKey: "refresh_token")
            userDefaults.setValue(expiresIn, forKey: "expires_in")
            
            // TODO check if user or vendor
            // for now assuming user
            userDefaults.setValue(1, forKey: "is_logged_in")
            userDefaults.setValue(1, forKey: "is_user")
            userDefaults.setValue(0, forKey: "is_vendor")
            
            userDefaults.synchronize()
            
            self.performSegueWithIdentifier("userLoggedIn", sender: self)
        } else {
            NSLog("Didn't recognize object")
        }
        
        
        
        
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
