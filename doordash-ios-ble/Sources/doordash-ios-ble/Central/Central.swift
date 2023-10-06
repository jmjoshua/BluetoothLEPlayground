//
//  Central.swift
//
//
//  Created by Joshua Moore on 10/5/23.
//

// Central (Dx)
// - Scan for peripherals (ServiceID, CharacteristicID)
// - Connect to peripherals (wait for any updates)
// - When message has been received, stop connection
// - Disconnect

import BluetoothKit
import Combine
import Foundation
import OSLog
import CoreBluetooth

public protocol Central {
    var statusPublisher: PassthroughSubject<CentralStatusType, Never> { get }
    var scanStatusPublisher: PassthroughSubject<CentralScanStatusType, Never> { get }
    func configure(serviceUUID: UUID, characteristicUUID: UUID) throws
    func beginScanningForPeripherals()
    func connect(to peripheral: BKRemotePeripheral)
    func disconnect()
}

public class CentralImpl: Central {
    public let statusPublisher = PassthroughSubject<CentralStatusType, Never>()
    public let scanStatusPublisher = PassthroughSubject<CentralScanStatusType, Never>()

    private let central = BKCentral()
    private var serviceUUID: UUID?
    private var characteristicUUID: UUID?
    private let logger = Logger(
        subsystem: Constants.Logging.subsystem,
        category: Constants.Logging.categoryCentral)

    public init() {
        central.delegate = self
        central.addAvailabilityObserver(self)
    }

    public func configure(serviceUUID: UUID, characteristicUUID: UUID) throws {
        do {
            self.serviceUUID = serviceUUID
            self.characteristicUUID = characteristicUUID
            central.delegate = self
            central.addAvailabilityObserver(self)

            let configuration = BKConfiguration(
                dataServiceUUID: serviceUUID,
                dataServiceCharacteristicUUID: characteristicUUID)
            try central.startWithConfiguration(configuration)
            statusPublisher.send(.ready)
        } catch {
            logger.log("Error while starting central: \(error)")
            throw error
        }
    }

    public func beginScanningForPeripherals() {
        scanForPeripherals()
    }

    public func connect(to peripheral: BKRemotePeripheral) {
        central.connect(remotePeripheral: peripheral) { [weak self] remotePeripheral, error in
            self?.logger.log("Connected to peripheral: \(remotePeripheral.identifier.uuidString)")
            remotePeripheral.delegate = self
            self?.statusPublisher.send(.connected)
        }
    }

    public func disconnect() {
        try? central.stop()
    }

}

private extension CentralImpl {
    func scanForPeripherals() {
        central.scanContinuouslyWithChangeHandler({ [weak self] changes, discoveries in
            guard let self = self else { return }

            // Handle changes to "available" discoveries, [BKDiscoveriesChange].
            // Handle current "available" discoveries, [BKDiscovery].
            // This is where you'd ie. update a table view.
            self.logger.log("Central new discoveries: \(discoveries)")

            if !discoveries.isEmpty {
                let peripheralsAndServiceIDs = discoveries
                    .compactMap {
                        (peripheral: $0.remotePeripheral,
                         serviceIDs: $0.advertisementData[Constants.Keys.serviceUUIDArrayKey] as? [CBUUID])
                    }
                guard let peripheralPair = peripheralsAndServiceIDs.first(where: { pair in
                    if let serviceIds = pair.serviceIDs,
                       let serviceUUID = self.serviceUUID {
                        return serviceIds.contains(.init(nsuuid: serviceUUID))
                    } else {
                        return false
                    }
                }) else { return }
                let peripheral = peripheralPair.peripheral

                guard !central.connectedRemotePeripherals.contains(peripheral) else { return }

                statusPublisher.send(.peripheralsFound([peripheral]))
                central.interruptScan()
            }
        }, stateHandler: { [weak self] newState in
            // Handle newState, BKCentral.ContinuousScanState.
            // This is where you'd ie. start/stop an activity indicator.
            switch newState {
            case .scanning:
                self?.scanStatusPublisher.send(.scanning)
                self?.logger.log("Central new state: Scanning")
            case .waiting:
                self?.scanStatusPublisher.send(.waiting)
                self?.logger.log("Central new state: Waiting")
            case .stopped:
                self?.scanStatusPublisher.send(.stopped)
                self?.logger.log("Central new state: Stopped")
            }
        }, duration: 3, inBetweenDelay: 3, errorHandler: { [weak self] error in
            self?.logger.error("Central scanning error: \(error)")
        })
    }
}

extension CentralImpl: BKRemotePeerDelegate {
    public func remotePeer(_ remotePeer: BluetoothKit.BKRemotePeer, didSendArbitraryData data: Data) {
        statusPublisher.send(.dataReceived(data))
    }
}

extension CentralImpl: BKCentralDelegate {
    public func central(_ central: BluetoothKit.BKCentral, remotePeripheralDidDisconnect remotePeripheral: BluetoothKit.BKRemotePeripheral) {
        self.statusPublisher.send(.disconnected)
    }
}

extension CentralImpl: BKAvailabilityObserver {
    public func availabilityObserver(_ availabilityObservable: BluetoothKit.BKAvailabilityObservable, availabilityDidChange availability: BluetoothKit.BKAvailability) {
        // Unimplemented
    }
    
    public func availabilityObserver(_ availabilityObservable: BluetoothKit.BKAvailabilityObservable, unavailabilityCauseDidChange unavailabilityCause: BluetoothKit.BKUnavailabilityCause) {
        // Unimplemented
    }
}
