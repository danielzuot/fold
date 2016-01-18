//
//  RPViewController.swift
//  Fold
//
//  Created by Daniel Zuo on 1/15/16.
//  Copyright © 2016 Fold. All rights reserved.
//

import UIKit
import CoreBluetooth

class RPViewController: UIViewController, CBPeripheralManagerDelegate, UITextViewDelegate {

    @IBOutlet weak var amountRequested: UITextField!
    @IBOutlet weak var broadcastingSwitch: UISwitch!
    
    
    //globals
    var peripheralManager : CBPeripheralManager?
    var testCharacteristic : CBMutableCharacteristic?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        peripheralManager = CBPeripheralManager(delegate: self, queue: nil)
        broadcastingSwitch.addTarget(self, action: Selector("stateChanged:"), forControlEvents: UIControlEvents.ValueChanged)
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func stateChanged(switchState: UISwitch) {
        if switchState.on {
            NSLog("Starting to broadcast...")
            peripheralManager!.startAdvertising([CBAdvertisementDataServiceUUIDsKey : serviceUUID])
        } else {
            NSLog("Stopping broadcast...")
            peripheralManager?.stopAdvertising()
        }
    }
    
    
    @IBAction func requestedAmountUpdated(sender: AnyObject) {
        NSLog("Requested value changed, updating subscribers...")
        let amountReqData = (amountRequested.text! as NSString).dataUsingEncoding(NSUTF8StringEncoding)
        peripheralManager!.updateValue(amountReqData!, forCharacteristic: self.testCharacteristic!, onSubscribedCentrals: nil)
    }
    
    /******* CBPeripheralManagerDelegate *******/
    
    func peripheralManager(peripheral: CBPeripheralManager, didAddService service: CBService, error: NSError?) {
        if (error != nil) {
            NSLog("Error publishing service: %@", error!)
        }
        
        NSLog("Service has been published to database.")
    }
    
    func peripheralManagerDidUpdateState(peripheral: CBPeripheralManager) {
        if peripheral.state != CBPeripheralManagerState.PoweredOn {
            NSLog("Bluetooth switched off or not initialized")
            return
        }
        //TODO change initial value to value in text field
        NSLog("Creating service/characteristic tree...")
        
        self.testCharacteristic = CBMutableCharacteristic(
            type: characteristicUUID,
            properties: CBCharacteristicProperties.Notify,
            value: nil,
            permissions: CBAttributePermissions.Readable
        )
        
        let testService = CBMutableService(
            type: serviceUUID,
            primary: true
        )
        
        testService.characteristics = [self.testCharacteristic!]
        peripheralManager!.addService(testService)
        
    }
    
    func peripheralManager(peripheral: CBPeripheralManager, central: CBCentral, didSubscribeToCharacteristic characteristic: CBCharacteristic) {
        NSLog("User has subscribed, updating amount requested value...")
        
        let amountReqData = (amountRequested.text! as NSString).dataUsingEncoding(NSUTF8StringEncoding)
        peripheralManager!.updateValue(
            amountReqData!,
            forCharacteristic: self.testCharacteristic!,
            onSubscribedCentrals: nil
        )
    }
    
    func peripheralManager(peripheral: CBPeripheralManager, central: CBCentral, didUnsubscribeFromCharacteristic characteristic: CBCharacteristic) {
        NSLog("User unsubscribed from vendor characteristic...")
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
