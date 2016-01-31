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
    private var isUser = true
    
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
        self.isUser = true
        CoinbaseOAuth.startOAuthAuthenticationWithClientId(
            CLIENT_ID,
            scope: USER_SCOPE,
            redirectUri: REDIRECT_URI,
            meta: USER_META
        )
    }
    
    @IBAction func authenticateVendorLogin(sender: AnyObject) {
        self.isUser = false
        CoinbaseOAuth.startOAuthAuthenticationWithClientId(
            CLIENT_ID,
            scope: VENDOR_SCOPE,
            redirectUri: REDIRECT_URI,
            meta: VENDOR_META
        )
    }
    
    dynamic private func authenticationSuccessful(notification: NSNotification) {
        NSLog("Notification received: Authentication successful! Tokens retrieved.")
        if let response = notification.object as? [String : AnyObject] {
            let userDefaults = NSUserDefaults.standardUserDefaults()
            c
            userDefaults.setValue(1, forKey: "is_logged_in")
            if (isUser) {
                userDefaults.setValue(1, forKey: "is_user")
                userDefaults.setValue(0, forKey: "is_vendor")
                userDefaults.synchronize()
                self.performSegueWithIdentifier("userLoggedIn", sender: self)
            } else {
                userDefaults.setValue(0, forKey: "is_user")
                userDefaults.setValue(1, forKey: "is_vendor")
                userDefaults.synchronize()
                self.performSegueWithIdentifier("vendorLoggedIn", sender: self)
            }
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
