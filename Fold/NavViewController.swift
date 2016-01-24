//
//  NavViewController.swift
//  Fold
//
//  Created by Daniel Zuo on 1/12/16.
//  Copyright © 2016 Fold. All rights reserved.
//

import UIKit

class NavViewController: UINavigationController {
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        let prefs:NSUserDefaults = NSUserDefaults.standardUserDefaults()
        let isLoggedIn = prefs.integerForKey("is_logged_in")
        if (isLoggedIn == 0) {
            NSLog("Not logged in")
            self.performSegueWithIdentifier("notLoggedIn", sender: self)
        } else {
            NSLog("Logged in already...")
            let isUser = prefs.integerForKey("is_user")
            if (isUser == 0) {
                NSLog("...as vendor")
                self.performSegueWithIdentifier("vendorAlreadyLoggedIn", sender: self)
            } else {
                NSLog("...as user")
                self.performSegueWithIdentifier("userAlreadyLoggedIn", sender: self)
            }
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
