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
    
    //IBOutlets
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    
    //globals
    var centralManager : CBCentralManager!
    var vendorPeripheral : CBPeripheral!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        // Initialize central manager on load
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }

    override func viewWillDisappear(animated: Bool) {
        NSLog("Leaving view and stopping scan...")
        centralManager.stopScan()
        super.viewWillDisappear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func searchDevices(sender: AnyObject) {
        NSLog("hello world")
    }
    
     /******* CBCentralManagerDelegate *******/
    
    // Check status of BLE hardware
    func centralManagerDidUpdateState(central: CBCentralManager) {
        if central.state == CBCentralManagerState.PoweredOn {
            // Scan for peripherals if BLE is turned on
            //central.scanForPeripheralsWithServices([CBUUID(string: testServiceUUID)], options: [CBCentralManagerScanOptionAllowDuplicatesKey : true])
            central.scanForPeripheralsWithServices(nil, options: nil)
            NSLog("Starting scan...")
            self.statusLabel.text = "Searching for Fold Vendors"
        }
        else {
            // Can have different conditions for all states if needed - print generic message for now
            NSLog("Bluetooth switched off or not initialized")
        }
    }

    func centralManager(central: CBCentralManager, didDiscoverPeripheral peripheral: CBPeripheral, advertisementData: [String : AnyObject], RSSI: NSNumber) {
        if let peripheralName = peripheral.name {
            NSLog("Discovered %@ at %@", peripheralName, RSSI);
        }
        
        // Reject any where the value is above reasonable range
        if (RSSI.integerValue > -15) {
            NSLog("RSSI of %i is above reasonable range.", RSSI.integerValue);
            return;
        }
        
        // Reject if the signal strength is too low to be close enough (Close is around -22dB)
        if (RSSI.integerValue < -35) {
            NSLog("RSSI of %i is too low to be close enough.", RSSI.integerValue);
            return;
        }
        
        if (self.vendorPeripheral != peripheral) {
            //Save a local copy of the peripheral, so CB doesn't get rid of it
            self.vendorPeripheral = peripheral
            
            //And then connect
            NSLog("Connecting to peripheral %@", peripheral);
            //self.centralManager.connectPeripheral(peripheral, options: nil)
        }
    }
    
    func centralManager(central: CBCentralManager, didFailToConnectPeripheral peripheral: CBPeripheral, error: NSError?) {
        NSLog("Failed to connect")
        cleanup();
    }
    
    
    func cleanup() {
        NSLog("Cleaning up...")
        // Don't do anything if we're not connected
        if (self.vendorPeripheral.state != CBPeripheralState.Connected) {
            return;
        }
        
        // See if we are subscribed to a characteristic on the peripheral
        if let peripheralServices = vendorPeripheral.services {
            for service in peripheralServices {
                if let serviceCharacteristics = service.characteristics {
                    for charac in serviceCharacteristics {
                        if (charac.isNotifying){
                            vendorPeripheral.setNotifyValue(false, forCharacteristic: charac)
                            return
                        }
                    }
                }
            }
        }
        centralManager.cancelPeripheralConnection(vendorPeripheral)
    }
    
    func centralManager(central: CBCentralManager, didConnectPeripheral peripheral: CBPeripheral) {
        NSLog("Connected to vendor")
        self.statusLabel.text = "Connected to vendor."
        
        centralManager.stopScan()
        peripheral.delegate = self
        peripheral.discoverServices([CBUUID(string: testServiceUUID)])
    }
    
    func peripheral(peripheral: CBPeripheral, didDiscoverServices error: NSError?) {
        if (error == nil) {
            cleanup()
            return
        }
        NSLog("Discovered correct service")
        for service in peripheral.services! {
            peripheral.discoverCharacteristics([CBUUID(string: testServiceUUID)], forService: service)
        }
    }
    
    func peripheral(peripheral: CBPeripheral, didDiscoverCharacteristicsForService service: CBService, error: NSError?) {
        if (error == nil) {
            cleanup()
            return
        }
        
        NSLog("Searching service %@ for characteristic with UUID %@...", service, testCharacteristicUUID)
        for character in service.characteristics! {
            NSLog("Found characteristic with UUID: %@", character.UUID)
            if (character.UUID.isEqual(CBUUID(string: testCharacteristicUUID))){
                NSLog("It's the right characteristic!")
                peripheral.setNotifyValue(true, forCharacteristic: character)
            }
        }
        NSLog("Couldn't find it.")
    }
    
    func peripheral(peripheral: CBPeripheral, didUpdateValueForCharacteristic characteristic: CBCharacteristic, error: NSError?) {
        if (error == nil) {
            NSLog("Error!")
            return
        }
        
        let dataString = NSString(data: characteristic.value!, encoding: NSUTF8StringEncoding) as! String
        
        if (dataString != "") {
            self.amountLabel.text = dataString
            NSLog("Got data, disconnecting from peripheral...")
            peripheral.setNotifyValue(false, forCharacteristic: characteristic)
            centralManager.cancelPeripheralConnection(peripheral)
        }
    }
    
    func peripheral(peripheral: CBPeripheral, didUpdateNotificationStateForCharacteristic characteristic: CBCharacteristic, error: NSError?) {
        if !(characteristic.UUID.isEqual(CBUUID(string: testCharacteristicUUID))) {
            return
        }
        if (characteristic.isNotifying) {
            NSLog("Notification began on %@", peripheral)
        } else {
            // notification has stopped
            NSLog("Notification stopped on %@.  Disconnecting", characteristic);
            centralManager.cancelPeripheralConnection(peripheral)
        }
    }
    
    func centralManager(central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: NSError?) {
        self.vendorPeripheral = nil
        centralManager.scanForPeripheralsWithServices([CBUUID(string: testServiceUUID)], options: nil)
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
