//
//  ContentViewModel.swift
//  BluetoothLEPlayground
//
//  Created by Joshua Moore on 10/4/23.
//

import Foundation
import OSLog
import Combine
import doordash_ios_ble
import BluetoothKit

extension ContentView {
    class ViewModel: ObservableObject {
        @Published var mode: Mode = .none
        @Published var statusMessage: String?
        @Published var isLoading: Bool = false
        @Published var enableSendButton: Bool = false
        @Published var showConnectButton: Bool = false

        private var subscriptions = Set<AnyCancellable>()
        private let central = CentralImpl()
        private let peripheral = PeripheralImpl()
        private var remotePeripherals = [BKRemotePeripheral]()
        private var logger = Logger(subsystem: "BluetoothLEPlayground", category: "ContentViewModel")

        init() {
            setupCentralSubscriptions()
            setupPeripheralSubscriptions()

            do {
                try central.configure(
                    serviceUUID: UUID(uuidString: "6E6B5C64-FAF7-40AE-9C21-D4933AF45B23")!,
                    characteristicUUID: UUID(uuidString: "477A2967-1FAB-4DC5-920A-DEE5DE685A3D")!)
            } catch {
                logger.log("Unable to start central: \(error)")
            }
        }

        func startCentralTapped() {
            mode = .central

            central.beginScanningForPeripherals()
        }

        func startPeripheralTapped() {
            mode = .peripheral

            do {
                try peripheral.startAdvertising(
                    serviceUUID: UUID(uuidString: "6E6B5C64-FAF7-40AE-9C21-D4933AF45B23")!,
                    characteristicUUID: UUID(uuidString: "477A2967-1FAB-4DC5-920A-DEE5DE685A3D")!)
            } catch {
                logger.log("Unable to start peripheral: \(error)")
            }
        }

        func connectTapped() {
            guard let peripheral = remotePeripherals.first else { return }
            central.connect(to: peripheral)
        }

        func sendDataTapped() {
            let data = String("Hello beloved central!").data(using: .utf8)!
            peripheral.sendData(data)
        }

        func stopTapped() {
            switch mode {
            case .central: central.disconnect()
            case .peripheral: peripheral.disconnect()
            case .none: break
            }

            mode = .none
        }

        private func setupCentralSubscriptions() {
            central.statusPublisher
                .receive(on: RunLoop.main)
                .sink { [weak self] status in
                    self?.logger.log("Central status received: \(status.debugDescription)")

                    switch status {
                    case .none:
                        break
                    case .ready:
                        self?.statusMessage = "Ready"
                    case .connected:
                        self?.statusMessage = "Connected"
                        self?.showConnectButton = false
                    case .disconnected:
                        self?.statusMessage = "Disconnected"
                    case let .peripheralsFound(peripherals):
                        self?.remotePeripherals = peripherals
                        self?.statusMessage = "Peripherals found: \(peripherals.map({ $0.identifier }))"
                        self?.showConnectButton = true
                    case let .dataReceived(data):
                        guard let message = String.init(data: data, encoding: .utf8) else {
                            self?.statusMessage = "Unable to deserialize received data."
                            return
                        }

                        self?.statusMessage = "Data received: \(message)"
                    case let .error(error):
                        self?.statusMessage = "Error: \(error)"
                    }
                }
                .store(in: &subscriptions)

            central.scanStatusPublisher
                .receive(on: RunLoop.main)
                .sink { [weak self] scanStatus in
                    self?.logger.log("Central scan status received: \(scanStatus.rawValue)")

                    switch scanStatus {
                    case .scanning:
                        self?.isLoading = true
                        self?.statusMessage = "Scanning..."
                    case .waiting:
                        self?.isLoading = false
                        self?.statusMessage = "Scanning..."
                    case .stopped:
                        self?.isLoading = false
                    }
                }
                .store(in: &subscriptions)
        }

        private func setupPeripheralSubscriptions() {
            peripheral.statusPublisher
                .receive(on: RunLoop.main)
                .sink { [weak self] status in
                    switch status {
                    case .ready:
                        self?.statusMessage = "Ready"
                    case .advertising:
                        self?.isLoading = true
                        self?.statusMessage = "Advertising..."
                    case .connected:
                        self?.isLoading = false
                        self?.statusMessage = "Connected"
                        self?.enableSendButton = true
                    case .disconnected:
                        self?.statusMessage = "Disconnected"
                        self?.enableSendButton = false
                    case .dataSent:
                        self?.statusMessage = "Data sent!"
                    case let .error(error):
                        self?.statusMessage = "Error: \(error)"
                    }
                }
                .store(in: &subscriptions)
        }
    }
}

enum Mode: String {
    case central, peripheral, none

    var infoText: String {
        switch self {
        case .central:
            return "Central mode"
        case .peripheral:
            return "Peripheral mode"
        case .none:
            return "Select a mode to start"
        }
    }
}
