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

    private var peripheral: BKPeripheral?
    private var central: BKCentral?
    private var logger = Logger(subsystem: "BluetoothLEPlayground", category: "BluetoothController")

    init() {
    }

    func startPeripheralMode() throws {
        peripheral = BKPeripheral()
        peripheral?.delegate = self

        let serviceUUID = UUID(uuidString: "6E6B5C64-FAF7-40AE-9C21-D4933AF45B23")!
        let characteristicUUID = UUID(uuidString: "477A2967-1FAB-4DC5-920A-DEE5DE685A3D")!
        let localName = "My Cool Peripheral"
        let configuration = BKPeripheralConfiguration(
            dataServiceUUID: serviceUUID,
            dataServiceCharacteristicUUID: characteristicUUID,
            localName: localName)
        try peripheral?.startWithConfiguration(configuration)
    }

    func startCentralMode() throws {
        let central = BKCentral()
        central.delegate = self
        central.addAvailabilityObserver(self)

        let serviceUUID = UUID(uuidString: "6E6B5C64-FAF7-40AE-9C21-D4933AF45B23")!
        let characteristicUUID = UUID(uuidString: "477A2967-1FAB-4DC5-920A-DEE5DE685A3D")!
        let configuration = BKConfiguration(dataServiceUUID: serviceUUID, dataServiceCharacteristicUUID: characteristicUUID)
        try central.startWithConfiguration(configuration)
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
