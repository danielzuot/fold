//
//  MPViewController.swift
//  Fold
//
//  Created by Daniel Zuo on 1/13/16.
//  Copyright © 2016 Fold. All rights reserved.
//

import UIKit
import CoreBluetooth

class MPViewController: UIViewController, CBCentralManagerDelegate, CBPeripheralDelegate {
    
    @IBOutlet weak var requestedAmountLabel: UILabel!
    @IBOutlet weak var makePaymentButton: UIButton!
    
    private var centralManager: CBCentralManager?
    private var vendorPeripheral: CBPeripheral?
    
    private var client: Coinbase?
    private var primaryAccount: CoinbaseAccount?
    private var priceReceived: String?
    private var vendorAddress: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Start up the CBCentralManager
        centralManager = CBCentralManager(delegate: self, queue: nil)
        checkForRefreshToken()
        let userDefaults = NSUserDefaults.standardUserDefaults()
        if let currentAccessToken = userDefaults.stringForKey("access_token") {
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
                            self.primaryAccount = primaryAccount
                            NSLog(self.primaryAccount.debugDescription)
                        }
                    }
                }
            })
        }
    }
    

    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        NSLog("Stopping scan")
        centralManager?.stopScan()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func centralManagerDidUpdateState(central: CBCentralManager) {
        if central.state != .PoweredOn {
            return
        }
        
        scan()
    }
    
    /** Scan for peripherals - specifically for our service's 128bit CBUUID
     */
    func scan() {
        
        centralManager?.scanForPeripheralsWithServices(
            [serviceUUID], options: [
                CBCentralManagerScanOptionAllowDuplicatesKey : true
            ]
        )
        
        NSLog("Scanning started")
    }
    
    /** This callback comes whenever a peripheral that is advertising the TRANSFER_SERVICE_UUID is discovered.
     *  We check the RSSI, to make sure it's close enough that we're interested in it, and if it is,
     *  we start the connection process
     */
    func centralManager(central: CBCentralManager, didDiscoverPeripheral peripheral: CBPeripheral, advertisementData: [String : AnyObject], RSSI: NSNumber) {
        
        // Reject any where the value is above reasonable range
        // Reject if the signal strength is too low to be close enough (Close is around -22dB)
        if  RSSI.integerValue < -15 && RSSI.integerValue > -35 {
            NSLog("Device not at correct range")
            return
        }
        
        NSLog("Discovered \(peripheral.name) at \(RSSI)")
        
        // Ok, it's in range - have we already seen it?
        if vendorPeripheral != peripheral {
            // Save a local copy of the peripheral, so CoreBluetooth doesn't get rid of it
            vendorPeripheral = peripheral
            
            // And connect
            print("Connecting to peripheral \(peripheral)")
            
            centralManager?.connectPeripheral(peripheral, options: nil)
        }
    }
    
    /** If the connection fails for whatever reason, we need to deal with it.
     */
    func centralManager(central: CBCentralManager, didFailToConnectPeripheral peripheral: CBPeripheral, error: NSError?) {
        print("Failed to connect to \(peripheral). (\(error!.localizedDescription))")
        
        cleanup()
    }
    
    /** We've connected to the peripheral, now we need to discover the services and characteristics to find the 'transfer' characteristic.
     */
    func centralManager(central: CBCentralManager, didConnectPeripheral peripheral: CBPeripheral) {
        print("Peripheral Connected")
        
        // Stop scanning
        centralManager?.stopScan()
        print("Scanning stopped")
        
        // Make sure we get the discovery callbacks
        peripheral.delegate = self
        
        // Search only for services that match our UUID
        peripheral.discoverServices([serviceUUID])
    }
    
    /** The Transfer Service was discovered
     */
    func peripheral(peripheral: CBPeripheral, didDiscoverServices error: NSError?) {
        if let error = error {
            print("Error discovering services: \(error.localizedDescription)")
            cleanup()
            return
        }
        
        // Discover the characteristic we want...
        
        // Loop through the newly filled peripheral.services array, just in case there's more than one.
        for service in peripheral.services as [CBService]! {
            peripheral.discoverCharacteristics([amountUUID, addressUUID], forService: service)
        }
    }
    
    /** The Transfer characteristic was discovered.
     *  Once this has been found, we want to subscribe to it, which lets the peripheral know we want the data it contains
     */
    func peripheral(peripheral: CBPeripheral, didDiscoverCharacteristicsForService service: CBService, error: NSError?) {
        // Deal with errors (if any)
        if let error = error {
            print("Error discovering services: \(error.localizedDescription)")
            cleanup()
            return
        }
        
        // Again, we loop through the array, just in case.
        for characteristic in service.characteristics as [CBCharacteristic]! {
            // And check if it's the right one
            if characteristic.UUID.isEqual(amountUUID) || characteristic.UUID.isEqual(addressUUID) {
                // If it is, subscribe to it
                peripheral.setNotifyValue(true, forCharacteristic: characteristic)
            }
        }
        // Once this is complete, we just need to wait for the data to come in.
    }
    
    /** This callback lets us know more data has arrived via notification on the characteristic
     */
    func peripheral(peripheral: CBPeripheral, didUpdateValueForCharacteristic characteristic: CBCharacteristic, error: NSError?) {
        if let error = error {
            print("Error discovering services: \(error.localizedDescription)")
            return
        }
        
        if (characteristic.UUID.isEqual(amountUUID)) {
            priceReceived = NSString(data: characteristic.value!, encoding: NSUTF8StringEncoding) as? String
            requestedAmountLabel.text = priceReceived
        } else if (characteristic.UUID.isEqual(addressUUID)) {
            vendorAddress = NSString(data: characteristic.value!, encoding: NSUTF8StringEncoding) as? String
            NSLog(vendorAddress!)
        }
        
        if priceReceived != nil {
            if vendorAddress != nil {
                NSLog("Creating confirmation alert")
                let alert = UIAlertController(
                    title: "Payment Confirmation",
                    message: String(format: "%@%@%@%@","Sending $", self.priceReceived!, " to vendor address: ", self.vendorAddress!),
                    preferredStyle: UIAlertControllerStyle.ActionSheet
                )
                alert.addAction(UIAlertAction(title: "Confirm", style: UIAlertActionStyle.Default, handler: {
                    (alert: UIAlertAction!) -> Void in
                        NSLog("Sending payment...")
                        self.primaryAccount?.sendAmount(self.priceReceived, amountCurrencyISO: Currencies.US_DOLLARS.rawValue, to: self.vendorAddress, notes: "testing", userFee: "", referrerID: "", idem: "", instantBuy: false, orderID: "", completion: {
                            (transaction: CoinbaseTransaction?, error: NSError?) -> Void in
                                if let error = error {
                                    NSLog("Payment failed %@.", error.localizedDescription)
                                    let alert = UIAlertController(title: "Payment Error", message: error.localizedDescription, preferredStyle: UIAlertControllerStyle.Alert)
                                    alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Default, handler: nil))
                                    self.presentViewController(alert, animated: true, completion: nil)
                                }
                                NSLog("PAYMENT COMPLETE")
                                self.performSegueWithIdentifier("paymentComplete", sender: self)
                            })
                        NSLog("After the payment")

                }))
                alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Default, handler: {
                    (alert: UIAlertAction!) -> Void in
                    NSLog("Cancelled")
                }))
                self.presentViewController(alert, animated: true, completion: nil)
            }
        }
    }
    
    /** The peripheral letting us know whether our subscribe/unsubscribe happened or not
     */
    func peripheral(peripheral: CBPeripheral, didUpdateNotificationStateForCharacteristic characteristic: CBCharacteristic, error: NSError?) {
        if let error = error {
            print("Error changing notification state: \(error.localizedDescription)")
        }
        
        // Exit if it's not the transfer characteristic
        if !(characteristic.UUID.isEqual(addressUUID) || characteristic.UUID.isEqual(amountUUID)){
            return
        }
        
        // Notification has started
        if (characteristic.isNotifying) {
            print("Notification began on \(characteristic)")
        } else { // Notification has stopped
            print("Notification stopped on (\(characteristic))  Disconnecting")
            centralManager?.cancelPeripheralConnection(peripheral)
        }
    }
    
    /** Once the disconnection happens, we need to clean up our local copy of the peripheral
     */
    func centralManager(central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: NSError?) {
        print("Peripheral Disconnected")
        vendorPeripheral = nil
        
        // We're disconnected, so start scanning again
        scan()
    }
    
    /** Call this when things either go wrong, or you're done with the connection.
     *  This cancels any subscriptions if there are any, or straight disconnects if not.
     *  (didUpdateNotificationStateForCharacteristic will cancel the connection if a subscription is involved)
     */
    private func cleanup() {
        // Don't do anything if we're not connected
        // self.discoveredPeripheral.isConnected is deprecated
        if vendorPeripheral?.state != CBPeripheralState.Connected { // explicit enum required to compile here?
            return
        }
        
        // See if we are subscribed to a characteristic on the peripheral
        if let services = vendorPeripheral?.services as [CBService]? {
            for service in services {
                if let characteristics = service.characteristics as [CBCharacteristic]? {
                    for characteristic in characteristics {
                        if (characteristic.UUID.isEqual(amountUUID) || characteristic.UUID.isEqual(addressUUID)) && characteristic.isNotifying {
                            vendorPeripheral?.setNotifyValue(false, forCharacteristic: characteristic)
                            // And we're done.
                            return
                        }
                    }
                }
            }
        }
        
        // If we've got this far, we're connected, but we're not subscribed, so we just disconnect
        centralManager?.cancelPeripheralConnection(vendorPeripheral!)
    }
}