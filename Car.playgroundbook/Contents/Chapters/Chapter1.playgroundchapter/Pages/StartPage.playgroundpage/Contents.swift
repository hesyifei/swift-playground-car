/*:
# Welcome to Play Car! 😊

In this Playground, you are going to be guided to connect and control your real model car, which based on [Arduino](glossary://Arduino), with [Bluetooth low energy](glossary://BLE) through Swift code, and also become a real developer and design and develop a controller user interface that your friends and family can play with easily! Furthermore, try to make it an autonomous car!

Now what are you waiting for? Let's get started by connecting your car!

After you can connect your car successfully, move on to the [next page](@next) to try it out!
*/
//#-hidden-code
import UIKit
import Foundation
import PlaygroundSupport

class ViewController: UIViewController {
	// must init here
//#-end-hidden-code
/*:
*Don't have a real car? Change `hasRealCar` to `false`, and there will be a virtual one on your screen waiting for you.* ☺️
*/
//#-code-completion(everything, hide)
//#-code-completion(currentmodule, hide)
//#-code-completion(literal, show, boolean)
let hasRealCar = /*#-editable-code Tap to enter code*/true/*#-end-editable-code*/

let ble = BLEObject()

//#-hidden-code

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


		UserDefaults.standard.set(hasRealCar, forKey: "hasRealCar")

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

// CCHANGE
// for debug only
UserDefaults.standard.set("BT05", forKey: "bleName")
UserDefaults.standard.set("FFE0", forKey: "bleServiceUUID")
UserDefaults.standard.set("FFE1", forKey: "bleCharacteristicUUID")

//#-hidden-code
		print(BLEData.name)

		// http://stackoverflow.com/a/7751272/2603230
		NotificationCenter.default.removeObserver(self, name: NotificationName.didLinkUpToCharacteristic, object: nil)
		NotificationCenter.default.removeObserver(self, name: NotificationName.didDisconnectPeripheral, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(self.didLinkUpToCharacteristic), name: NotificationName.didLinkUpToCharacteristic, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(self.didDisconnectPeripheral), name: NotificationName.didDisconnectPeripheral, object: nil)

		if !(isValidCBUUID(BLEData.serviceUUID) && isValidCBUUID(BLEData.characteristicUUID)) {
			PlaygroundPage.current.assessmentStatus = .fail(hints: ["😞 Your BLE Service UUID or BLE Characteristic UUID is invalid! Make sure you didn't type anything wrong!"], solution: nil)
			PlaygroundPage.current.finishExecution()
		} else {
			DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(1)) {
//#-end-hidden-code
self.ble.startConnect()

//#-hidden-code
			}
			DispatchQueue.main.async {
				self.statusLabel.text = "Connecting..."
			}
		}
	}

	func isValidCBUUID(_ inputString: String) -> Bool {
		let length = inputString.characters.count
		return (length == 4) || (length == 8) || (length == 32)
	}

	func didDisconnectPeripheral() {
		print("recieved didDisconnectPeripheral")
	}

//#-end-hidden-code
// This function will be called when your device is connected successfully.
func didLinkUpToCharacteristic() {
	//#-hidden-code
	statusLabel.text = "Connected! :)"
	//#-end-hidden-code
	//#-editable-code
	print("Connected to your car! :)")
	//#-end-editable-code
	//#-hidden-code
	ble.disconnectPeripheral()

	PlaygroundPage.current.assessmentStatus = .pass(message: "You've connected your car through BLE successfully! Now go to the [next page](@next) and continue! 🎉")
	DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(3)) {
		// to make sure that statusLabel.text is changed
		PlaygroundPage.current.finishExecution()
	}
	//#-end-hidden-code
}
//#-hidden-code
}

let controller = ViewController()

PlaygroundPage.current.liveView = controller
PlaygroundPage.current.needsIndefiniteExecution = true

