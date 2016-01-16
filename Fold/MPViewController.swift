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
    
    //constants
    let testServiceUUID = CBUUID(string: "56054B44-6C60-4D42-BAB3-7D1AB28498C6")
    let testCharacteristicUUID = CBUUID(string: "54D6C478-5008-4F9B-8DEB-D28A4E62AADB")
    
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
        super.viewWillDisappear(animated)
        NSLog("Leaving view and stopping scan...")
        centralManager.stopScan()
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
            central.scanForPeripheralsWithServices([testServiceUUID], options: nil)
            NSLog("Starting scan...")
            self.statusLabel.text = "Searching for Fold Vendors"
        }
        else {
            // Can have different conditions for all states if needed - print generic message for now
            NSLog("Bluetooth switched off or not initialized")
        }
    }

    // Check out the discovered peripherals to find Sensor Tag
    func centralManager(central: CBCentralManager, didDiscoverPeripheral peripheral: CBPeripheral, advertisementData: [String : AnyObject], RSSI: NSNumber) {
        
        NSLog("Discovered %@ at %@", peripheral.name!, RSSI);
        
        if (vendorPeripheral != peripheral) {
            //Save a local copy of the peripheral, so CB doesn't get rid of it
            vendorPeripheral = peripheral
            
            //And then connect
            NSLog("Connecting to peripheral %@", peripheral);
            self.centralManager.connectPeripheral(peripheral, options: nil)
        }
    }
    
    func centralManager(central: CBCentralManager, didFailToConnectPeripheral peripheral: CBPeripheral, error: NSError?) {
        NSLog("Failed to connect")
        cleanup();
    }
    
    
    func cleanup() {
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
        peripheral.discoverServices([testServiceUUID])
    }
    
    func peripheral(peripheral: CBPeripheral, didDiscoverServices error: NSError?) {
        if (error == nil) {
            cleanup()
            return
        }
        
        for service in peripheral.services! {
            peripheral.discoverCharacteristics([testCharacteristicUUID], forService: service)
        }
    }
    
    func peripheral(peripheral: CBPeripheral, didDiscoverCharacteristicsForService service: CBService, error: NSError?) {
        if (error == nil) {
            cleanup()
            return
        }
        
        for character in service.characteristics! {
            if (character.UUID .isEqual(testCharacteristicUUID)){
                peripheral.setNotifyValue(true, forCharacteristic: character)
            }
        }
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
        if !(characteristic.UUID.isEqual(testCharacteristicUUID)) {
            return
        }
        if (characteristic.isNotifying) {
            NSLog("Notification began on %@", peripheral)
        } else {
            // notification has stopped
            centralManager.cancelPeripheralConnection(peripheral)
        }
    }
    
    func centralManager(central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: NSError?) {
        vendorPeripheral = nil
        centralManager.scanForPeripheralsWithServices([testServiceUUID], options: nil)
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
