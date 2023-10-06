//
//  Constants.swift
//
//
//  Created by Joshua Moore on 10/5/23.
//

import Foundation

struct Constants {
    struct Logging {
        static let subsystem = "doordash-ios-ble"
        static let categoryCentral = "central"
        static let categoryPeripheral = "peripheral"
    }
    struct Keys {
        static let serviceUUIDArrayKey = "kCBAdvDataServiceUUIDs"
        static let serviceUUIDArrayBackgroundKey = "kCBAdvDataHashedServiceUUIDs"
    }
}
