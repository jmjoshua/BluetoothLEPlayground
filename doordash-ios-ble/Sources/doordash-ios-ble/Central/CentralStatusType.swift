//
//  CentralStatusType.swift
//  
//
//  Created by Joshua Moore on 10/5/23.
//

import Foundation
import BluetoothKit

public enum CentralStatusType {
    case none, ready, connected, disconnected
    case peripheralsFound(_ peripherals: [BKRemotePeripheral])
    case dataReceived(_ data: Data)
    case error(_ error: Error)
}

public enum CentralScanStatusType {
    case scanning, waiting, stopped
}
