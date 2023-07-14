/*
See LICENSE folder for this sample’s licensing information.

Abstract:
Transfer service and characteristics UUIDs
*/

import Foundation
import CoreBluetooth

struct TransferService {
    static let serviceUUID = CBUUID(string: "932c32bd-0000-47a2-835a-a8d455b859dd")
    static let characteristicUUID = CBUUID(string: "932c32bd-0002-47a2-835a-a8d455b859dd")
    static let colorUUID = CBUUID(string: "932c32bd-0005-47a2-835a-a8d455b859dd")
    static let brightnessUUID = CBUUID(string: "932c32bd-0003-47a2-835a-a8d455b859dd")
}
