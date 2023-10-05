//
//  BluetoothController.swift
//  BluetoothLEPlayground
//
//  Created by Joshua Moore on 10/4/23.
//

import Foundation
import BluetoothKit
import OSLog
import CoreBluetooth
import Combine

class BluetoothController {

    let statusMessage = CurrentValueSubject<String?, Never>(nil)
    let isLoading = CurrentValueSubject<Bool, Never>(false)
    let peripheralCanSendData = CurrentValueSubject<Bool, Never>(false)

    private var peripheral = BKPeripheral()
    private var central = BKCentral()
    private var logger = Logger(subsystem: "BluetoothLEPlayground", category: "BluetoothController")

    private let serviceUUIDArrayKey = "kCBAdvDataServiceUUIDs"
    private let serviceID = UUID(uuidString: "6E6B5C64-FAF7-40AE-9C21-D4933AF45B23")!

    init() {
        setupPeripheral()
        setupCentral()
    }

    private func setupPeripheral() {
        peripheral.delegate = self

        do {
            let serviceUUID = serviceID
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

            let serviceUUID = serviceID
            let characteristicUUID = UUID(uuidString: "477A2967-1FAB-4DC5-920A-DEE5DE685A3D")!
            let configuration = BKConfiguration(dataServiceUUID: serviceUUID, dataServiceCharacteristicUUID: characteristicUUID)
            try central.startWithConfiguration(configuration)
        } catch {
            logger.log("Central error: \(error)")
        }
    }

    func sendPeripheralData() throws {
        let data = String("Hello beloved central!").data(using: .utf8)!
        let remoteCentral = peripheral.connectedRemoteCentrals.first // Don't do this in the real world :]

        if let remoteCentral = remoteCentral {
            peripheral.sendData(data, toRemotePeer: remoteCentral) { [weak self] data, remoteCentral, error in
                // Handle error.
                if let error = error {
                    self?.logger.log("Data send failed: \(error)")
                    self?.updateStatus("Failed to send data: \(error.localizedDescription)")
                    self?.updateIsLoading(false)
                }

                // If no error, the data was all sent!
                self?.logger.log("Data send complete: \(data)")
                self?.updateStatus("Data sent!")
                self?.updateIsLoading(false)
            }
        }
    }

    func startCentralMode() throws {

        central.scanContinuouslyWithChangeHandler({ [weak self] changes, discoveries in
            guard let self = self else { return }

            // Handle changes to "availabile" discoveries, [BKDiscoveriesChange].
            // Handle current "available" discoveries, [BKDiscovery].
            // This is where you'd ie. update a table view.
            self.logger.log("Central new discoveries: \(discoveries)")

            if !discoveries.isEmpty {
                let peripheralsAndServiceIDs = discoveries
                    .compactMap { 
                        (peripheral: $0.remotePeripheral,
                         serviceIDs: $0.advertisementData[self.serviceUUIDArrayKey] as? [CBUUID])
                    }
                guard let peripheralPair = peripheralsAndServiceIDs.first(where: { pair in
                    if let serviceIds = pair.serviceIDs {
                        return serviceIds.contains(.init(nsuuid: self.serviceID))
                    } else {
                        return false
                    }
                }) else { return }
                let peripheral = peripheralPair.peripheral

                guard !central.connectedRemotePeripherals.contains(peripheral) else { return }

                central.connect(remotePeripheral: peripheral) { remotePeripheral, error in
                    self.logger.log("Connected to peripheral: \(remotePeripheral.identifier.uuidString)")
                    self.updateStatus("Connected to peripheral: \(remotePeripheral.identifier.uuidString)")
                    remotePeripheral.delegate = self
                    try? self.central.stop()
                }
            }
        }, stateHandler: { [weak self] newState in
            // Handle newState, BKCentral.ContinuousScanState.
            // This is where you'd ie. start/stop an activity indicator.
            switch newState {
            case .scanning:
                self?.updateStatus("Scanning...")
                self?.updateIsLoading(true)
                self?.logger.log("Central new state: Scanning")
            case .waiting:
                self?.updateStatus("Waiting...")
                self?.updateIsLoading(false)
                self?.logger.log("Central new state: Waiting")
            case .stopped:
                self?.updateStatus("Stopped...")
                self?.updateIsLoading(false)
                self?.logger.log("Central new state: Stopped")
            }
        }, duration: 3, inBetweenDelay: 3, errorHandler: { [weak self] error in
            self?.logger.log("Central error: \(error)")
            self?.updateStatus("Error while scanning: \(error.localizedDescription)")
            self?.updateIsLoading(false)
        })
    }

    func stopConnections() throws {
        try peripheral.stop()
        try central.stop()
        updateStatus("Connection stopped.")
    }
}

// MARK: Helpers

private extension BluetoothController {
    func updateStatus(_ message: String) {
        statusMessage.value = message
    }

    func clearStatus() {
        statusMessage.value = nil
    }

    func updateIsLoading(_ loading: Bool) {
        isLoading.value = loading
    }

    func updatePeripheralCanSend(_ canSend: Bool) {
        peripheralCanSendData.value = canSend
    }
}

extension BluetoothController: BKPeripheralDelegate {
    func peripheral(_ peripheral: BluetoothKit.BKPeripheral, remoteCentralDidConnect remoteCentral: BluetoothKit.BKRemoteCentral) {
        logger.log("remoteCentralDidConnect")

        updatePeripheralCanSend(true)
    }
    
    func peripheral(_ peripheral: BluetoothKit.BKPeripheral, remoteCentralDidDisconnect remoteCentral: BluetoothKit.BKRemoteCentral) {
        logger.log("remoteCentralDidDisconnect")

        updatePeripheralCanSend(false)
    }

}

extension BluetoothController: BKRemotePeerDelegate {
    func remotePeer(_ remotePeer: BluetoothKit.BKRemotePeer, didSendArbitraryData data: Data) {
        logger.log("Remote peer sent data: \(data)")

        updateStatus("Data sent from remote peer: \(data.base64EncodedString())")
    }
}

extension BluetoothController: BKCentralDelegate {
    func central(_ central: BluetoothKit.BKCentral, remotePeripheralDidDisconnect remotePeripheral: BluetoothKit.BKRemotePeripheral) {
        logger.log("remotePeripheralDidDisconnect")

        updateStatus("Peripheral disconnected.")
        try? startCentralMode()
    }
}

extension BluetoothController: BKAvailabilityObserver {
    func availabilityObserver(_ availabilityObservable: BluetoothKit.BKAvailabilityObservable, availabilityDidChange availability: BluetoothKit.BKAvailability) {
        logger.log("availabilityDidChange")
    }
    
    func availabilityObserver(_ availabilityObservable: BluetoothKit.BKAvailabilityObservable, unavailabilityCauseDidChange unavailabilityCause: BluetoothKit.BKUnavailabilityCause) {
        logger.log("unavailabilityCauseDidChange: \(unavailabilityCause.hashValue)")
    }
}
