//
//  ContentViewModel.swift
//  BluetoothLEPlayground
//
//  Created by Joshua Moore on 10/4/23.
//

import Foundation

extension ContentView {
    class ViewModel: ObservableObject {
        @Published var mode: Mode = .none
        @Published var loadingText: String?

        func startServerTapped() {
            mode = .server
            loadingText = "Starting server..."
        }

        func startClientTapped() {
            mode = .client
            loadingText = "Starting client..."
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

import RxBluetoothKit

struct BluetoothController {
    let manager = CentralManager(queue: .main)

    func startObserving() {
        
    }
}
