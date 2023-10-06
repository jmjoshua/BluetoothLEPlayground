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
    func startAdvertising(serviceUUID: UUID, characteristicUUID: UUID) throws
    func sendData(_ data: Data)
    func disconnect()
}

public class PeripheralImpl: Peripheral {
    public let statusPublisher = PassthroughSubject<PeripheralStatusType, Never>()

    private let peripheral = BKPeripheral()
    private let logger = Logger(
        subsystem: Constants.Logging.subsystem,
        category: Constants.Logging.categoryPeripheral)

    public init() {
        peripheral.delegate = self
        statusPublisher.send(.ready)
    }

    public func startAdvertising(serviceUUID: UUID, characteristicUUID: UUID) throws {
        let configuration = BKPeripheralConfiguration(
            dataServiceUUID: serviceUUID,
            dataServiceCharacteristicUUID: characteristicUUID)
        try peripheral.startWithConfiguration(configuration)
        statusPublisher.send(.advertising)
    }
    
    public func sendData(_ data: Data) {
        // TODO: Update to validate the correct central.
        let remoteCentral = peripheral.connectedRemoteCentrals.first

        if let remoteCentral = remoteCentral {
            peripheral.sendData(data, toRemotePeer: remoteCentral) { [weak self] data, remoteCentral, error in
                // Handle error.
                if let error = error {
                    self?.logger.log("Data send failed: \(error)")
                    self?.statusPublisher.send(.error(error))
                }

                // If no error, the data was all sent!
                self?.logger.log("Data send complete: \(data)")
                self?.statusPublisher.send(.dataSent)
            }
        }
    }
    
    public func disconnect() {
        try? peripheral.stop()
        statusPublisher.send(.disconnected)
    }
}

extension PeripheralImpl: BKPeripheralDelegate {
    public func peripheral(_ peripheral: BluetoothKit.BKPeripheral, remoteCentralDidConnect remoteCentral: BluetoothKit.BKRemoteCentral) {
        statusPublisher.send(.connected)
    }

    public func peripheral(_ peripheral: BluetoothKit.BKPeripheral, remoteCentralDidDisconnect remoteCentral: BluetoothKit.BKRemoteCentral) {
        statusPublisher.send(.disconnected)
    }
}
