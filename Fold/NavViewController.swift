//
//  NavViewController.swift
//  Fold
//
//  Created by Daniel Zuo on 1/12/16.
//  Copyright © 2016 Fold. All rights reserved.
//

import UIKit

class NavViewController: UINavigationController {
    
    var client: Coinbase?
    var accessToken: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        let prefs:NSUserDefaults = NSUserDefaults.standardUserDefaults()
        let userType = prefs.integerForKey("")
        if let accessToken = prefs.stringForKey("access_token") {
            
        }
        
        
        
        
        let isLoggedIn:Int = prefs.integerForKey("ISLOGGEDIN") as Int
        /* 
         0 => not logged in
         1 => user logged in
         2 => vendor logged in 
        */
        if (isLoggedIn == 0) {
            self.performSegueWithIdentifier("notLoggedIn", sender: self)
        } else if (isLoggedIn == 1) {
            self.performSegueWithIdentifier("userLoggedIn", sender: self)
        } else {
            self.performSegueWithIdentifier("vendorLoggedIn", sender: self)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
