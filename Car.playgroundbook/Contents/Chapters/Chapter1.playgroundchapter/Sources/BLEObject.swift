import UIKit
import CoreBluetooth

class BLEData {
	public static let name = "BT05"
}

// extension didn't work fine
public class NotificationName {
	public static let didLinkUpToCharacteristic = Notification.Name("didLinkUpToCharacteristic")
	public static let didConnectPeripheral = Notification.Name("didConnectPeripheral")
	public static let didDisconnectPeripheral = Notification.Name("didDisconnectPeripheral")
}

public class BLEObject: NSObject, CBCentralManagerDelegate, CBPeripheralDelegate {

	lazy var manager: CBCentralManager = CBCentralManager(delegate: self, queue: DispatchQueue.main)
	var peripheral: CBPeripheral!
	var characteristic: CBCharacteristic!

	public func startConnect() {
		_ = manager
	}

	public func restartConnect() {
		self.manager.scanForPeripherals(withServices: nil, options: nil)
	}

	public func writeData(_ data: Data) {
		self.peripheral.writeValue(data, for: characteristic, type: .withoutResponse)
	}

	public func disconnectPeripheral() {
		print("disconnectPeripheral func called")
		self.manager.cancelPeripheralConnection(peripheral)
	}

	public func centralManagerDidUpdateState(_ central: CBCentralManager) {
		print("centralManagerDidUpdateState: \(central.state.rawValue)")
		switch central.state {
		case .poweredOn:
			central.scanForPeripherals(withServices: nil, options: nil)
			break
		default:
			break
		}
	}

	public func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
		print("didDiscover: \(peripheral.description)")
		if let name = peripheral.name {
			if name == BLEData.name {
				print("Found device \(BLEData.name) (\(peripheral.identifier.uuidString))")

				central.stopScan()

				self.peripheral = peripheral
				self.peripheral.delegate = self

				central.connect(peripheral, options: nil)
			}
		}
	}

	public func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
		print("Connected to device \(peripheral.name)")
		peripheral.discoverServices(nil)
		NotificationCenter.default.post(name: NotificationName.didConnectPeripheral, object: nil)
	}

	public func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
		print("Disconnected device \(peripheral.identifier.uuidString)")
		NotificationCenter.default.post(name: NotificationName.didDisconnectPeripheral, object: nil)
	}


	public func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
		print("didDiscoverServices")
		if let services = peripheral.services {
			print("Services count: \(peripheral.services?.count)")
			for service in services {
				// CBUUID see data in LightBlue
				if service.uuid == CBUUID(string: "FFE0") {
					peripheral.discoverCharacteristics(nil, for: service)
				}
			}
		}
	}

	public func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
		print("didDiscoverCharacteristicsFor \(service.uuid)")
		for characteristic in service.characteristics! {
			print("each characteristic: \(characteristic.uuid)")
			// CBUUID see data in LightBlue
			if characteristic.uuid == CBUUID(string: "FFE1") {
				print("YEPPPPpp")
				self.characteristic = characteristic
				self.peripheral = peripheral

				NotificationCenter.default.post(name: NotificationName.didLinkUpToCharacteristic, object: nil)

				/*controlDevice()

				self.manager.cancelPeripheralConnection(peripheral)*/

				//startButton.isEnabled = true
				//PlaygroundPage.current.finish​Execution()
			}
		}
	}
}
