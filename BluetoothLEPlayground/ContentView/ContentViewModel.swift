//
//  ContentViewModel.swift
//  BluetoothLEPlayground
//
//  Created by Joshua Moore on 10/4/23.
//

import Foundation
import OSLog
import Combine

extension ContentView {
    class ViewModel: ObservableObject {
        @Published var mode: Mode = .none
        @Published var statusMessage: String?
        @Published var isLoading: Bool = false
        @Published var enableSendButton: Bool = false

        private var subscriptions = Set<AnyCancellable>()
        private let bluetoothController = BluetoothController()
        private var logger = Logger(subsystem: "BluetoothLEPlayground", category: "ContentViewModel")

        init() {
            setupSubscriptions()
        }

        func startCentralTapped() {
            mode = .central

            do {
                try bluetoothController.startCentralMode()
            } catch {
                logger.log("Unable to start central: \(error)")
            }
        }

        func startPeripheralTapped() {
            mode = .peripheral
        }

        func sendDataTapped() {
            do {
                try bluetoothController.sendPeripheralData()
            } catch {
                logger.log("Unable to send data: \(error)")
            }
        }

        func stopTapped() {
            mode = .none
            do {
                try bluetoothController.stopConnections()
            } catch {
                logger.log("Unable to stop connections: \(error)")
            }
        }

        private func setupSubscriptions() {
            bluetoothController.isLoading
                .receive(on: RunLoop.main)
                .sink { isLoading in
                    self.isLoading = isLoading
                }
                .store(in: &subscriptions)

            bluetoothController.peripheralCanSendData
                .receive(on: RunLoop.main)
                .sink { canSendData in
                    self.enableSendButton = canSendData
                }
                .store(in: &subscriptions)

            bluetoothController.statusMessage
                .receive(on: RunLoop.main)
                .sink { message in
                    self.statusMessage = message
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
