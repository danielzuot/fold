//
//  RPViewController.swift
//  Fold
//
//  Created by Daniel Zuo on 1/15/16.
//  Copyright © 2016 Fold. All rights reserved.
//

import UIKit
import CoreBluetooth

class RPViewController: UIViewController, CBPeripheralManagerDelegate, UITextFieldDelegate {
    
    @IBOutlet private weak var priceText: UITextField!
    @IBOutlet private weak var broadcastingSwitch: UISwitch!
    
    private var peripheralManager: CBPeripheralManager?
    private var amountCharacteristic: CBMutableCharacteristic?
    private var addressCharacteristic: CBMutableCharacteristic?
    
    private var priceToSend: String?
    private var orderAddress: String?
    private var client: Coinbase?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // Start up the CBPeripheralManager
        peripheralManager = CBPeripheralManager(delegate: self, queue: nil)
        self.priceText.delegate = self
        
        // Load Coinbase client
        checkForRefreshToken()
        let userDefaults = NSUserDefaults.standardUserDefaults()
        if let currentAccessToken = userDefaults.stringForKey("access_token") {
            self.client = Coinbase(OAuthAccessToken: currentAccessToken)
        }
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        
        // Don't keep it going while we're not showing.
        peripheralManager?.stopAdvertising()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func switchChanged(sender: AnyObject) {
        if broadcastingSwitch.on {
            // All we advertise is our service's UUID
            peripheralManager!.startAdvertising([
                CBAdvertisementDataServiceUUIDsKey : [serviceUUID]
            ])
            print("Peripheral trying to start advertising")
        } else {
            peripheralManager?.stopAdvertising()
            print("Peripheral stopped advertising")
        }
    }
    /** Required protocol method.  A full app should take care of all the possible states,
     *  but we're just waiting for  to know when the CBPeripheralManager is ready
     */
    func peripheralManagerDidUpdateState(peripheral: CBPeripheralManager) {
        // Opt out from any other state
        if (peripheral.state != CBPeripheralManagerState.PoweredOn) {
            return
        }
        
        // We're in CBPeripheralManagerStatePoweredOn state...
        print("self.peripheralManager powered on.")
        
        // ... so build our service.
        
        // Start with the CBMutableCharacteristic
        amountCharacteristic = CBMutableCharacteristic(
            type: amountUUID,
            properties: CBCharacteristicProperties.Notify,
            value: nil,
            permissions: CBAttributePermissions.Readable
        )
        
        addressCharacteristic = CBMutableCharacteristic(
            type: addressUUID,
            properties: CBCharacteristicProperties.Notify,
            value: nil,
            permissions: CBAttributePermissions.Readable
        )
        
        // Then the service
        let transferService = CBMutableService(
            type: serviceUUID,
            primary: true
        )
        
        // Add the characteristic to the service
        transferService.characteristics = [addressCharacteristic!, amountCharacteristic!]
        
        // And add it to the peripheral manager
        peripheralManager!.addService(transferService)
    }
    
    /** Catch when someone subscribes to our characteristic, then start sending them data
     */
    func peripheralManager(peripheral: CBPeripheralManager, central: CBCentral, didSubscribeToCharacteristic characteristic: CBCharacteristic) {
        print("Central subscribed to characteristic")
        
        // TODO Generate an order and then get the amount and address
        priceToSend = priceText.text!
        client?.createBitcoinAddress(
            {(cbaddress: CoinbaseAddress?, error: NSError?) -> Void in
                if let error = error {
                    NSLog("Could not generate new receipt address.")
                    let alert = UIAlertController(title: "New Address Error", message: error.localizedDescription, preferredStyle: UIAlertControllerStyle.Alert)
                    alert.addAction(UIAlertAction(title: "Click", style: UIAlertActionStyle.Default, handler: nil))
                    self.presentViewController(alert, animated: true, completion: nil)
                }
                if let cbaddress = cbaddress {
                    self.orderAddress = cbaddress.addressID
                }
        })
        
        peripheralManager?.updateValue(
            (priceToSend! as NSString).dataUsingEncoding(NSUTF8StringEncoding)!,
            forCharacteristic: amountCharacteristic!,
            onSubscribedCentrals: nil
        )
        
        peripheralManager?.updateValue(
            (orderAddress! as NSString).dataUsingEncoding(NSUTF8StringEncoding)!,
            forCharacteristic: addressCharacteristic!,
            onSubscribedCentrals: nil
        )
    }
    
    /** Recognise when the central unsubscribes
     */
    func peripheralManager(peripheral: CBPeripheralManager, central: CBCentral, didUnsubscribeFromCharacteristic characteristic: CBCharacteristic) {
        print("Central unsubscribed from characteristic")
    }
    
    /** This callback comes in when the PeripheralManager is ready to send the next chunk of data.
     *  This is to ensure that packets will arrive in the order they are sent
     */
    func peripheralManagerIsReadyToUpdateSubscribers(peripheral: CBPeripheralManager) {
        // Start sending again
        //sendData()
    }
    
    /** This is called when a change happens, so we know to stop advertising
     */
    func textViewDidChange(textView: UITextView) {
        // If we're already advertising, stop
        if (broadcastingSwitch.on) {
            broadcastingSwitch.setOn(false, animated: true)
            peripheralManager?.stopAdvertising()
        }
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return false
    }
    
    @IBAction func priceChanged(sender: AnyObject) {
        // If we're already advertising, stop
        if (broadcastingSwitch.on) {
            broadcastingSwitch.setOn(false, animated: true)
            peripheralManager?.stopAdvertising()
        }
    }
    
    func peripheralManagerDidStartAdvertising(peripheral: CBPeripheralManager, error: NSError?) {
        if let error = error {
            print("Error advertising: \(error.localizedDescription)")
            return
        }
        
        print("Peripheral started advertising.")
    }
}
