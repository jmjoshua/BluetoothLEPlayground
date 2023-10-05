//
//  ContentView.swift
//  BluetoothLEPlayground
//
//  Created by Joshua Moore on 10/4/23.
//

import SwiftUI

struct ContentView: View {

    @ObservedObject var vm: ViewModel

    var body: some View {
        VStack {
            // MARK: Title
            Text(vm.mode.infoText)
                .font(.title)

            HStack {
                if let statusMessage = vm.statusMessage {
                    Text(statusMessage)
                }
                if vm.isLoading {
                    ProgressView()
                }
            }
            .padding(.vertical)

            // MARK: Mode-specific views
            switch vm.mode {
            case .central:
                if vm.showConnectButton {
                    Button("Connect") {
                        vm.connectTapped()
                    }
                    .buttonStyle(.borderedProminent)
                }
            case .peripheral:
                Button("Send data") {
                    vm.sendDataTapped()
                }
                .buttonStyle(.borderedProminent)
                .disabled(!vm.enableSendButton)
            case .none:
                EmptyView()
            }

            // MARK: Buttons
            if vm.mode == .none {
                Button("Start central mode") {
                    vm.startCentralTapped()
                }
                .buttonStyle(.borderedProminent)

                Button("Start peripheral mode") {
                    vm.startPeripheralTapped()
                }
                .buttonStyle(.borderedProminent)
            } else {
                Button("Stop \(vm.mode.rawValue)") {
                    vm.stopTapped()
                }.buttonStyle(.borderedProminent)
            }
        }
        .padding()
    }
}

#Preview {
    ContentView(vm: .init())
}
