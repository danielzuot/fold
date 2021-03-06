//
//  TransactionTableViewController.swift
//  Fold
//
//  Created by David Doan on 2/1/16.
//  Copyright © 2016 Fold. All rights reserved.
//

import UIKit

class TransactionTableViewController: UITableViewController {

    private var client: Coinbase?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        checkForRefreshToken()
        // Do any additional setup after loading the view.
        let userDefaults = NSUserDefaults.standardUserDefaults()
        if let currentAccessToken = userDefaults.stringForKey("access_token") {
            self.client = Coinbase(OAuthAccessToken: currentAccessToken)
            
            client?.getTransactions({ (transactions: [AnyObject]!, user: CoinbaseUser!, balance: CoinbaseBalance!, negativebalance:CoinbaseBalance!, paging:CoinbasePagingHelper!, error:NSError!) -> Void in
                if let error = error {
                    NSLog("Could not get current user")
                    let alert = UIAlertController(title: "Current User Error", message: error.localizedDescription, preferredStyle: UIAlertControllerStyle.Alert)
                    alert.addAction(UIAlertAction(title: "Click", style: UIAlertActionStyle.Default, handler: nil))
                    self.presentViewController(alert, animated: true, completion: nil)
                } else {
                    NSLog(transactions.description)
                }
                
            })
            
        } else {
            NSLog("ERROR: reached transaction without valid access token")
        }
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 0
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 5
    }


    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("reuseIdentifier", forIndexPath: indexPath)
        let userDefaults = NSUserDefaults.standardUserDefaults()

        // Configure the cell...
        let transactions = userDefaults.arrayForKey("transactions")
        cell.textLabel?.text = transactions![indexPath.item] as? String

        return cell
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
