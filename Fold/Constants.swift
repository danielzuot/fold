//
//  Constants.swift
//  Fold
//
//  Created by Daniel Zuo on 1/17/16.
//  Copyright © 2016 Fold. All rights reserved.
//

import CoreBluetooth

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////                    BLUETOOTH                           //////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

let SERVICE_UUID = "E20A39F4-73F5-4BC4-A12F-17D1AD07A961"
let CHARACTERISTIC_UUID = "08590F7E-DB05-467E-8757-72F6FAEB13D4"
let NOTIFY_MTU = 20

let serviceUUID = CBUUID(string: SERVICE_UUID)
let characteristicUUID = CBUUID(string: CHARACTERISTIC_UUID)

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////                    OAuth                           //////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

let CLIENT_ID = "fa908ac547fc45176e3e735851cd6c504fd853cf1f0d91e2a5192d9fa6f3e89a"
let CLIENT_SECRET = "03dcc5dde881365e012ae61da754b63b41371d2bf5b0c9712b92d93c522c1b2b"
let USER_SCOPE = "wallet:accounts:read wallet:accounts:update wallet:accounts:create wallet:accounts:delete wallet:addresses:read wallet:addresses:create wallet:buys:read wallet:buys:create wallet:deposits:read wallet:deposits:create wallet:notifications:read wallet:payment-methods:read wallet:payment-methods:delete wallet:payment-methods:limits wallet:sells:read wallet:sells:create wallet:transactions:read wallet:transactions:send wallet:transactions:request wallet:transactions:transfer wallet:user:read wallet:user:update wallet:user:email wallet:withdrawals:read wallet:withdrawals:create"
let VENDOR_SCOPE = ""
let USER_META = ["send_limit_amount": "50", "send_limit_currency": "USD", "send_limit_period": "day"]
let VENDOR_META = ["send_limit_amount": "50", "send_limit_currency": "USD", "send_limit_period": "day"]
let REDIRECT_URI = "com.fold.app.coinbase-oath://coinbase-oauth"
let AUTH_SUCCESS_NOTIFICATION = "com.fold.app.coinbase-oauth.success"


func checkForRefreshToken(){
    let userDefaults = NSUserDefaults.standardUserDefaults()
    let expiresIn: Int? = Int(userDefaults.stringForKey("expires_in")!)
    let refreshToken = userDefaults.stringForKey("refresh_token");
    if (expiresIn < 10) {
        CoinbaseOAuth.getOAuthTokensForRefreshToken(refreshToken , clientId: CLIENT_ID, clientSecret: CLIENT_SECRET, completion: { (result : AnyObject?, error: NSError?) -> Void in
        })
    }
}

