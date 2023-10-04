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

        func startServerTapped() {
            mode = .server
            loadingText = "Starting server..."

            do {
                try bluetoothController.startCentralMode()
            } catch {
                logger.log("Unable to start server: \(error)")
            }
        }

        func startClientTapped() {
            mode = .client
            loadingText = "Starting client..."

            do {
                try bluetoothController.startPeripheralMode()
            } catch {
                logger.log("Unable to start client: \(error)")
            }
        }

        func stopTapped() {
            mode = .none
            loadingText = nil
        }
    }
}

enum Mode: String {
    case server, client, none

    var infoText: String {
        switch self {
        case .server:
            return "Server mode"
        case .client:
            return "Client mode"
        case .none:
            return "Select a mode to start"
        }
    }
}
