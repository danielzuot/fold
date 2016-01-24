//
//  WalletViewController.swift
//  Fold
//
//  Created by Daniel Zuo on 1/14/16.
//  Copyright © 2016 Fold. All rights reserved.
//

import UIKit

class WalletViewController: UIViewController {

    private var client: Coinbase?
    private var accessToken: String?
    
    @IBOutlet weak var balanceLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let userDefaults = NSUserDefaults.standardUserDefaults()
        if let currentAccessToken = userDefaults.stringForKey("access_token") {
            self.accessToken = currentAccessToken
            self.client = Coinbase(OAuthAccessToken: currentAccessToken)
            
            client?.getAccountsList({ (accounts: [AnyObject]!, paging: CoinbasePagingHelper!, error: NSError!) -> Void in
                if let error = error {
                    NSLog("Could not get accounts list")
                    let alert = UIAlertController(title: "Accounts List Error", message: error.localizedDescription, preferredStyle: UIAlertControllerStyle.Alert)
                    alert.addAction(UIAlertAction(title: "Click", style: UIAlertActionStyle.Default, handler: nil))
                    self.presentViewController(alert, animated: true, completion: nil)
                } else {
                    for primaryAccount in accounts as! [CoinbaseAccount]{
                        if (primaryAccount.primary) {
                            self.balanceLabel.text = String(format: "%@ %@",
                                primaryAccount.balance.amount,
                                primaryAccount.balance.currency
                            )
                        }
                    }
                }
            })
        } else {
            NSLog("ERROR: reached wallet without valid access token")
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
