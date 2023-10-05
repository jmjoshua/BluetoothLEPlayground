//
//  CentralStatusType.swift
//  
//
//  Created by Joshua Moore on 10/5/23.
//

import Foundation
import BluetoothKit

public enum CentralStatusType: CustomDebugStringConvertible {
    case none, ready, connected, disconnected
    case peripheralsFound(_ peripherals: [BKRemotePeripheral])
    case dataReceived(_ data: Data)
    case error(_ error: Error)

    public var debugDescription: String {
        switch self {
        case .none:
            return "none"
        case .ready:
            return "ready"
        case .connected:
            return "connected"
        case .disconnected:
            return "disconnected"
        case .peripheralsFound(_):
            return "peripheralsFound"
        case .dataReceived(_):
            return "dataReceived"
        case .error(_):
            return "error"
        }
    }
}

public enum CentralScanStatusType: String {
    case scanning, waiting, stopped
}
