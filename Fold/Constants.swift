//
//  Constants.swift
//  Fold
//
//  Created by Daniel Zuo on 1/17/16.
//  Copyright © 2016 Fold. All rights reserved.
//

import CoreBluetooth

let SERVICE_UUID = "E20A39F4-73F5-4BC4-A12F-17D1AD07A961"
let CHARACTERISTIC_UUID = "08590F7E-DB05-467E-8757-72F6FAEB13D4"
let NOTIFY_MTU = 20

let transferServiceUUID = CBUUID(string: SERVICE_UUID)
let transferCharacteristicUUID = CBUUID(string: CHARACTERISTIC_UUID)
