/*:
# Welcome to Play Car!

In this Playground, you are going to be guided to control a real model car through Swift code, and also be like a developer and develop a controller user interface that you can play with your friends and family!

Now what are you waiting for? Let's get started by connecting your car!

When you connect your car successfully, move on to the next page to try it out!
*/

//#-hidden-code
import UIKit
import Foundation
import PlaygroundSupport

class ViewController: UIViewController {
	// must init here
	let ble = BLEObject()

	var statusLabel: UILabel!

	override func viewDidLoad(){
		super.viewDidLoad()

		title = "Welcome"

		self.view.backgroundColor = UIColor.white

		statusLabel = UILabel()
		statusLabel.translatesAutoresizingMaskIntoConstraints = false
		statusLabel.font = UIFont.systemFont(ofSize: 40)
		statusLabel.text = "Welcome!"
		self.view.addSubview(statusLabel)

		let horizontalConstraint = NSLayoutConstraint(item: statusLabel, attribute: .centerX, relatedBy: .equal, toItem: view, attribute: .centerX, multiplier: 1, constant: 0)
		let verticalConstraint = NSLayoutConstraint(item: statusLabel, attribute: .centerY, relatedBy: .equal, toItem: view, attribute: .centerY, multiplier: 1, constant: 0)

		self.view.addConstraints([horizontalConstraint, verticalConstraint])

		UserDefaults.standard.set("", forKey: "bleName")
		UserDefaults.standard.set("", forKey: "bleServiceUUID")
		UserDefaults.standard.set("", forKey: "bleCharacteristicUUID")
		// BT05 FFE0 FFE1
		// <#T##BLE Service UUID##String#
//#-end-hidden-code
// Before we start, we have to store the car's Bluetooth Low Energy chip's data in order to connect it
// If you don't know what it is, try using any BLE Detection App from App Store (e.g. LightBlue) to check it
UserDefaults.standard.set(/*#-editable-code */"<#T##BLE Peripheral Name##String#>"/*#-end-editable-code*/, forKey: "bleName")
UserDefaults.standard.set(/*#-editable-code */"<#T##BLE Service UUID##String#>"/*#-end-editable-code*/, forKey: "bleServiceUUID")
UserDefaults.standard.set(/*#-editable-code */"<#T##BLE Characteristic UUID##String#>"/*#-end-editable-code*/, forKey: "bleCharacteristicUUID")

// for debug only
UserDefaults.standard.set("BT05", forKey: "bleName")
UserDefaults.standard.set("FFE0", forKey: "bleServiceUUID")
UserDefaults.standard.set("FFE1", forKey: "bleCharacteristicUUID")
//#-hidden-code
		print(BLEData.name)

		if !(isValidCBUUID(BLEData.serviceUUID) && isValidCBUUID(BLEData.characteristicUUID)) {
			fatalError("CBUUID is invalid!")
		}
	}

	func isValidCBUUID(_ inputString: String) -> Bool {
		let length = inputString.characters.count
		return (length == 4) || (length == 8) || (length == 32)
	}

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)

		NotificationCenter.default.addObserver(self, selector: #selector(self.didLinkUpToCharacteristic), name: NotificationName.didLinkUpToCharacteristic, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(self.didDisconnectPeripheral), name: NotificationName.didDisconnectPeripheral, object: nil)
	}

	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
//#-end-hidden-code
self.ble.startConnect()
//#-hidden-code

		statusLabel.text = "Connecting..."
	}

	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)

		NotificationCenter.default.removeObserver(self, name: NotificationName.didLinkUpToCharacteristic, object: nil)
		NotificationCenter.default.removeObserver(self, name: NotificationName.didDisconnectPeripheral, object: nil)
	}

	func didDisconnectPeripheral() {
		print("recieved didDisconnectPeripheral")
	}

//#-end-hidden-code
// This function will be called when your device is connected successfully.
func didLinkUpToCharacteristic() {
	//#-editable-code
	print("Connected to your car! :)")
	//#-end-editable-code
	//#-hidden-code
	statusLabel.text = "Connected! :)"
	self.ble.disconnectPeripheral()
	//#-end-hidden-code
}
//#-hidden-code
}

let controller = ViewController()

PlaygroundPage.current.liveView = controller
PlaygroundPage.current.needsIndefiniteExecution = true

