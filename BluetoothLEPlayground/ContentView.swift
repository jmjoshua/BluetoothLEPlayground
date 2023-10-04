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

            // MARK: Loading Indicator
            if let loadingText = vm.loadingText {
                HStack {
                    ProgressView(loadingText)
                        .progressViewStyle(.circular)
                }.padding(.vertical)
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
