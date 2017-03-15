//#-hidden-code
/*
 Copyright (C) 2016 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information.
 
 This is a second example page.
*/

import UIKit
import Foundation
import PlaygroundSupport
import CoreBluetooth

class ViewController: UIViewController, CBCentralManagerDelegate, CBPeripheralDelegate {

	var manager: CBCentralManager!
	var peripheral: CBPeripheral!
	var characteristic: CBCharacteristic!

	var startButton: UIButton!

	override func viewDidLoad(){
		super.viewDidLoad()
		title = "Hello UIKit"
		// lay out your view here

		startButton = UIButton(frame: CGRect(x: 100, y: 100, width: 100, height: 50))
		startButton.setTitle("Try again", for: .normal)
		startButton.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)
		startButton.isEnabled = false

		self.view.addSubview(startButton)

		manager = CBCentralManager(delegate: self, queue: DispatchQueue.main)

		DispatchQueue.main.async {
			self.manager.scanForPeripherals(withServices: nil, options: nil)
		}
	}

	func buttonAction() {
		print("BBUTON")
		manager.scanForPeripherals(withServices: nil, options: nil)
		startButton.isEnabled = false
	}


	func centralManagerDidUpdateState(_ central: CBCentralManager) {
		print(central.state.rawValue)
		/*switch central.state {
		case .poweredOn:
			print("on")
			central.scanForPeripherals(withServices: nil, options: nil)
		default:
			print(central.state.rawValue)
			break
		}*/
	}

	func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
		print(peripheral.description)
		if let name = peripheral.name {
			if name == "BT05" {
				print("Found device \(peripheral.identifier.uuidString)")

				central.stopScan()

				self.peripheral = peripheral
				self.peripheral.delegate = self

				central.connect(peripheral, options: nil)

				/*let alert = UIAlertController(title: "Device found", message: "Found BLE device named \(name)", preferredStyle: .alert)
				alert.addAction(UIAlertAction(title: "Connect & record", style: .default, handler: { (action: UIAlertAction) in
					//self.manager = central

					self.peripheral = peripheral
					self.peripheral.delegate = self

					central.connect(peripheral, options: nil)
				}))
				alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action: UIAlertAction) in
					print("CANNEL")
				}))

				DispatchQueue.main.async {
					self.present(alert, animated: true, completion: nil)
				}*/
			}
		}
	}

	func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
		print("Connected to device \(peripheral.name)")
		peripheral.discoverServices(nil)
	}

	func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
		print("Disconnected device \(peripheral.identifier.uuidString)")
	}


	func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
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

	func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
		print("didDiscoverCharacteristicsFor \(service.uuid)")
		for characteristic in service.characteristics! {
			print("each characteristic: \(characteristic.uuid)")
			// CBUUID see data in LightBlue
			if characteristic.uuid == CBUUID(string: "FFE1") {
				print("YEPPPPpp")
				self.characteristic = characteristic

				controlDevice()

				self.manager.cancelPeripheralConnection(peripheral)
				startButton.isEnabled = true
				//PlaygroundPage.current.finish​Execution()
			}
		}
	}
//#-end-hidden-code
enum Operation: String {
	case forward = "f"
	case backward = "b"
}

func controlDevice() {
	//#-editable-code
	moveForward(for: 2)
	moveBackward(for: 1)
	moveForward(for: 2)
	//#-end-editable-code
}

func moveForward(for sec: Double) {
	move(.forward, for: sec)
}

// "b" is defined in the car's hardward as "backword"
func moveBackward(for sec: Double) {
	move(.backward, for: sec)
}

func move(_ operation: Operation, for sec: Double) {
	let msec: Int = Int(sec*1000)
	runCommand("<\(operation.rawValue)\(msec)>")
	waitFor(msec)
}



// how can we send our command to our car?
func runCommand(_ cmd: String) {
	peripheral.writeValue(convertCommand(cmd), for: characteristic, type: .withoutResponse)
}

// how should we convert command which is a string to something every device can understand? (HEX)
func convertCommand(_ cmd: String) -> Data {
	return cmd.data(using: String.Encoding.utf8)!
}
//#-hidden-code

	func waitFor(_ ms: Int) {
		let mmsec: Int = ms * 1000
		usleep(UInt32(mmsec))
	}
}

let controller = ViewController()

let currentVC = UINavigationController(rootViewController: controller)

PlaygroundPage.current.liveView = currentVC
PlaygroundPage.current.needsIndefiniteExecution = true


//let delegate = BTDelegate(currentVC)

//let mgr = CBCentralManager(delegate: delegate, queue: nil)


//delegate.peripheral.writeValue(data, forCharacteristic: delegate.characteristic, type: CBCharacteristicWriteType.WithoutResponse)


