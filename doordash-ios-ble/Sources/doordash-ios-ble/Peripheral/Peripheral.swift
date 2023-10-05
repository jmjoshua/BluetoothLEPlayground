//
//  Peripheral.swift
//
//
//  Created by Joshua Moore on 10/5/23.
//

// Peripheral (Cx)
// - Start advertising (ServiceID, CharacteristicID)
// - Send data (Swift.Data)
// - Disconnect
//  - Do this when we deallocate the view just for the demo.

import BluetoothKit
import Combine
import Foundation
import OSLog

public protocol Peripheral {
    var statusPublisher: PassthroughSubject<PeripheralStatusType, Never> { get }
    func startAdvertising()
    func sendData(_ data: Data)
    func disconnect()
}

public struct PeripheralImpl: Peripheral {
    public let statusPublisher = PassthroughSubject<PeripheralStatusType, Never>()

    private let logger = Logger(
        subsystem: Constants.Logging.subsystem,
        category: Constants.Logging.categoryPeripheral)

    public func startAdvertising() {
        // Unimplemented
    }
    
    public func sendData(_ data: Data) {
        // Unimplemented
    }
    
    public func disconnect() {
        // Unimplemented
    }
}
