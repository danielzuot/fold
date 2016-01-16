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
    //constants
    let testServiceUUID = CBUUID(string: "56054B44-6C60-4D42-BAB3-7D1AB28498C6")
    let testCharacteristicUUID = CBUUID(string: "54D6C478-5008-4F9B-8DEB-D28A4E62AADB")
    
    //globals
    var peripheralManager : CBPeripheralManager!
    var testCharacteristic : CBMutableCharacteristic!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        peripheralManager = CBPeripheralManager(delegate: self, queue: nil)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        peripheralManager.stopAdvertising()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func broadcastTapped(sender: AnyObject) {
        NSLog("Starting to broadcast...")
        peripheralManager.startAdvertising([CBAdvertisementDataServiceUUIDsKey : testServiceUUID])
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
        } else {
            //TODO change initial value to value in text field
            NSLog("Creating service/characteristic tree...")
            self.testCharacteristic = CBMutableCharacteristic(type: testCharacteristicUUID, properties: CBCharacteristicProperties.Notify, value: nil, permissions: CBAttributePermissions.Readable)
            let testService = CBMutableService(type: testServiceUUID, primary: true)
            testService.characteristics = [self.testCharacteristic]
            peripheralManager.addService(testService)
        }
    }
    
    func peripheralManager(peripheral: CBPeripheralManager, central: CBCentral, didSubscribeToCharacteristic characteristic: CBCharacteristic) {
        NSLog("User has subscribed, updating amount requested value...")
        let amountReqData = (amountRequested.text! as NSString).dataUsingEncoding(NSUTF8StringEncoding)
        peripheralManager.updateValue(amountReqData!, forCharacteristic: self.testCharacteristic, onSubscribedCentrals: nil)
    }
    
    func peripheralManagerIsReadyToUpdateSubscribers(peripheral: CBPeripheralManager) {
        NSLog("Vendor ready to update again, updating amount requested value...")
        let amountReqData = (amountRequested.text! as NSString).dataUsingEncoding(NSUTF8StringEncoding)
        peripheralManager.updateValue(amountReqData!, forCharacteristic: self.testCharacteristic, onSubscribedCentrals: nil)
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
