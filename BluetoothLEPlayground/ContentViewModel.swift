//
//  ContentViewModel.swift
//  BluetoothLEPlayground
//
//  Created by Joshua Moore on 10/4/23.
//

import Foundation
import OSLog

extension ContentView {
    class ViewModel: ObservableObject {
        @Published var mode: Mode = .none
        @Published var loadingText: String?

        private let bluetoothController = BluetoothController()
        private var logger = Logger(subsystem: "BluetoothLEPlayground", category: "ContentViewModel")

        func startCentralTapped() {
            mode = .central
            loadingText = "Starting..."

            do {
                try bluetoothController.startCentralMode()
            } catch {
                logger.log("Unable to start central: \(error)")
            }
        }

        func startPeripheralTapped() {
            mode = .peripheral
            loadingText = "Starting..."

            do {
                try bluetoothController.startPeripheralMode()
            } catch {
                logger.log("Unable to start peripheral: \(error)")
            }
        }

        func stopTapped() {
            mode = .none
            loadingText = nil
            do {
                try bluetoothController.stopConnections()
            } catch {
                logger.log("Unable to stop connections: \(error)")
            }
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
