//
//  BluetoothController.swift
//  BluetoothLEPlayground
//
//  Created by Joshua Moore on 10/4/23.
//

import Foundation
import BluetoothKit
import OSLog

class BluetoothController {

    private var peripheral = BKPeripheral()
    private var central = BKCentral()
    private var logger = Logger(subsystem: "BluetoothLEPlayground", category: "BluetoothController")

    init() {
        setupPeripheral()
        setupCentral()
    }

    private func setupPeripheral() {
        peripheral.delegate = self

        do {
            let serviceUUID = UUID(uuidString: "6E6B5C64-FAF7-40AE-9C21-D4933AF45B23")!
            let characteristicUUID = UUID(uuidString: "477A2967-1FAB-4DC5-920A-DEE5DE685A3D")!
            let localName = "My Cool Peripheral"
            let configuration = BKPeripheralConfiguration(
                dataServiceUUID: serviceUUID,
                dataServiceCharacteristicUUID: characteristicUUID,
                localName: localName)
            try peripheral.startWithConfiguration(configuration)
        } catch {
            logger.log("peripheral error: \(error)")
        }
    }

    private func setupCentral() {
        do {
            central.delegate = self
            central.addAvailabilityObserver(self)

            let serviceUUID = UUID(uuidString: "6E6B5C64-FAF7-40AE-9C21-D4933AF45B23")!
            let characteristicUUID = UUID(uuidString: "477A2967-1FAB-4DC5-920A-DEE5DE685A3D")!
            let configuration = BKConfiguration(dataServiceUUID: serviceUUID, dataServiceCharacteristicUUID: characteristicUUID)
            try central.startWithConfiguration(configuration)
        } catch {
            logger.log("Central error: \(error)")
        }
    }

    func startPeripheralMode() throws {
        let data = String("Hello beloved central!").data(using: .utf8)!
        let remoteCentral = peripheral.connectedRemoteCentrals.first // Don't do this in the real world :]

        if let remoteCentral = remoteCentral {
            peripheral.sendData(data, toRemotePeer: remoteCentral) { [weak self] data, remoteCentral, error in
                // Handle error.
                // If no error, the data was all sent!
                self?.logger.log("peripheral error: \(error)")
            }
        }
    }

    func startCentralMode() throws {
        central.scanContinuouslyWithChangeHandler({ [weak self] changes, discoveries in
            // Handle changes to "availabile" discoveries, [BKDiscoveriesChange].
            // Handle current "available" discoveries, [BKDiscovery].
            // This is where you'd ie. update a table view.
            self?.logger.log("Central new discoveries: \(discoveries)")
        }, stateHandler: { [weak self] newState in
            // Handle newState, BKCentral.ContinuousScanState.
            // This is where you'd ie. start/stop an activity indicator.
            let newState = newState.hashValue
            self?.logger.log("Central new state: \(newState)")
        }, duration: 3, inBetweenDelay: 3, errorHandler: { [weak self] error in
            self?.logger.log("Central error: \(error)")
        })
    }

    func stopConnections() throws {
        try peripheral.stop()
        try central.stop()
    }
}

extension BluetoothController: BKPeripheralDelegate {
    func peripheral(_ peripheral: BluetoothKit.BKPeripheral, remoteCentralDidConnect remoteCentral: BluetoothKit.BKRemoteCentral) {
        logger.log("remoteCentralDidConnect")
    }
    
    func peripheral(_ peripheral: BluetoothKit.BKPeripheral, remoteCentralDidDisconnect remoteCentral: BluetoothKit.BKRemoteCentral) {
        logger.log("remoteCentralDidDisconnect")
    }

}

extension BluetoothController: BKCentralDelegate {
    func central(_ central: BluetoothKit.BKCentral, remotePeripheralDidDisconnect remotePeripheral: BluetoothKit.BKRemotePeripheral) {
        logger.log("remotePeripheralDidDisconnect")
    }

}

extension BluetoothController: BKAvailabilityObserver {
    func availabilityObserver(_ availabilityObservable: BluetoothKit.BKAvailabilityObservable, availabilityDidChange availability: BluetoothKit.BKAvailability) {
        logger.log("remotePeripheralDidDisconnect")
    }
    
    func availabilityObserver(_ availabilityObservable: BluetoothKit.BKAvailabilityObservable, unavailabilityCauseDidChange unavailabilityCause: BluetoothKit.BKUnavailabilityCause) {
        logger.log("remotePeripheralDidDisconnect")
    }
}
