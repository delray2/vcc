import UIKit
import CoreBluetooth
import ChromaColorPicker
protocol ColorViewControllerDelegate: AnyObject {
    func didChangeColor(_ color: UIColor)
}
class CharacteristicWrap {
    var charac: CBCharacteristic

    init(charac: CBCharacteristic) {
        self.charac = charac
    }

    func writeValue(value: [Int]) {
        let data = Data(value.map { UInt8($0) })
        charac.service?.peripheral?.writeValue(data, for: charac, type: .withResponse)
    }
}

class ColorViewController: UIViewController, ChromaColorPickerDelegate, CBCentralManagerDelegate, CBPeripheralDelegate {
    func colorPickerHandleDidChange(_ colorPicker: ChromaColorPicker, handle: ChromaColorHandle, to color: UIColor) {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        color.getRed(&red, green: &green, blue: &blue, alpha: nil)
        
        // Convert RGB to [Int]
        let rgb = [red, green, blue].map { Int($0 * 255) }
        
        // Convert RGB to the data format used by the lightbulb
        let data = convert(rgb: rgb)
        print(data)
        view.backgroundColor = color
        
        // Write the data to the lightbulb
        characteristicWrap?.writeValue(value: data)
    }

    func convert(rgb: [Int]) -> [Int] {
        guard rgb.allSatisfy({ 0 <= $0 && $0 <= 255 }) else {
            fatalError("We cannot understand this color code")
        }

        let scale = 0xff
        var adjusted = rgb.map { max(1, $0) }
        let total = adjusted.reduce(0, +)
      
        adjusted = adjusted.map { Int(round(Double($0) / Double(total) * Double(scale))) }
        if adjusted.reduce(0, +) > scale {
           
        }

        return [adjusted[0], adjusted[2], adjusted[1], 0x1]
    
    }
    
    var colorPicker: ChromaColorPicker!
    var characteristicWrap: CharacteristicWrap?
    var centralManager: CBCentralManager?
    var peripheral: CBPeripheral?
    weak var delegate: ColorViewControllerDelegate?


    override func viewDidLoad() {
        super.viewDidLoad()

        colorPicker = ChromaColorPicker(frame: CGRect(x: 10,  y: 20, width: 300, height: 300))
        colorPicker.delegate = self // set the delegate to selfw
        let handle = colorPicker.addHandle(at: .white)
        view.backgroundColor = handle.color
        view.addSubview(colorPicker!)

        centralManager = CBCentralManager(delegate: self, queue: nil)
    }

    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state == .poweredOn {
            centralManager?.scanForPeripherals(withServices: nil, options: nil)
        }
    }

    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        self.peripheral = peripheral
        centralManager?.stopScan()
        centralManager?.connect(peripheral, options: nil)
    }

    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        peripheral.delegate = self
        peripheral.discoverServices([CBUUID(string: "932c32bd-0000-47a2-835a-a8d455b859dd")])
    }

    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if let service = peripheral.services?.first(where: { $0.uuid == CBUUID(string: "932c32bd-0000-47a2-835a-a8d455b859dd") }) {
            peripheral.discoverCharacteristics([CBUUID(string: "932c32bd-0005-47a2-835a-a8d455b859dd")], for: service)
        }
    }

    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        if let characteristic = service.characteristics?.first(where: { $0.uuid == CBUUID(string: "932c32bd-0005-47a2-835a-a8d455b859dd") }) {
            characteristicWrap = CharacteristicWrap(charac: characteristic)
        }
    }

    func colorPickerDidChooseColor(_ colorPicker: ChromaColorPicker, color: UIColor) {
       
        // Convert UIColor to RGB
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        color.getRed(&red, green: &green, blue: &blue, alpha: nil)
        
        // Convert RGB to [Int]
        let rgb = [red, green, blue].map { Int($0 * 255) }
        view.backgroundColor = UIColor(red: red, green: green, blue: blue, alpha: 1)
        
        // Convert RGB to the data format used by the lightbulb
        let data = convert(rgb: rgb)
        
        // Write the data to the lightbulb
        characteristicWrap?.writeValue(value: data)
        print(data)
    }

}

