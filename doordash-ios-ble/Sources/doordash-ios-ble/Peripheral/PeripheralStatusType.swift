//
//  PeripheralStatusType.swift
//  
//
//  Created by Joshua Moore on 10/5/23.
//

import Foundation

public enum PeripheralStatusType {
    case ready, advertising, connected, disconnected, dataSent
    case error(_ error: Error)
}
