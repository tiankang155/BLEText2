//
//  ScannedPeripheral.swift
//  BLEText2
//
//  Created by yarui on 2017/11/6.
//  Copyright © 2017年 Tiankang. All rights reserved.
//

import UIKit
import CoreBluetooth
@objc class ScannedPeripheral: NSObject {
    
    var peripheral  : CBPeripheral
    var RSSI        : Int32
    var isConnected : Bool
    
    init(withPeripheral aPeripheral: CBPeripheral, andRSSI anRSSI:Int32 = 0, andIsConnected aConnectionStatus: Bool) {
        peripheral = aPeripheral
        RSSI = anRSSI
        isConnected = aConnectionStatus
    }
    
    func name()->String{
        let peripheralName = peripheral.name
        if peripheral.name == nil {
            return "No name"
        }else{
            return peripheralName!
        }
    }
    
    override func isEqual(_ object: Any?) -> Bool {
        if let otherPeripheral = object as? ScannedPeripheral {
            return peripheral == otherPeripheral.peripheral
        }
        return false
    }
}
