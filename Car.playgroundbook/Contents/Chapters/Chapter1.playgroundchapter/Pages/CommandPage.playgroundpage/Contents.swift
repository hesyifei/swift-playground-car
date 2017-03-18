//#-hidden-code
/*
 Copyright (C) 2016 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information.
 
 This is a second example page.
*/

import UIKit
import Foundation
import PlaygroundSupport

class ViewController: UIViewController {
	var startButton: UIButton!

	// must init here
	let ble = BLEObject()

	override func viewDidLoad(){
		super.viewDidLoad()
		title = "Hello UIKit"

		startButton = UIButton(frame: CGRect(x: 100, y: 100, width: 100, height: 50))
		startButton.setTitle("Try again", for: .normal)
		startButton.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)
		startButton.isEnabled = false

		self.view.addSubview(startButton)
	}

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)

		NotificationCenter.default.addObserver(self, selector: #selector(self.didLinkUpToCharacteristic), name: NotificationName.didLinkUpToCharacteristic, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(self.didDisconnectPeripheral), name: NotificationName.didDisconnectPeripheral, object: nil)
	}

	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)

		self.ble.startConnect()
	}

	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)

		NotificationCenter.default.removeObserver(self, name: NotificationName.didLinkUpToCharacteristic, object: nil)
		NotificationCenter.default.removeObserver(self, name: NotificationName.didDisconnectPeripheral, object: nil)
	}

	func didDisconnectPeripheral() {
		print("recieved didDisconnectPeripheral")
	}

	func didLinkUpToCharacteristic() {
		print("recieved connectedToCharacteristic")

		controlDevice()

		self.ble.disconnectPeripheral()

		startButton.isEnabled = true
		//PlaygroundPage.current.finish​Execution()
	}

	func buttonAction() {
		print("BBUTON")
		self.ble.restartConnect()
		startButton.isEnabled = false
	}

//#-end-hidden-code
enum Operation: String {
	case forward = "f"
	case backward = "b"
	case turnLeft = "l"
	case turnRight = "r"
}

func controlDevice() {
	//#-editable-code
	moveForward(for: 2)
	moveBackward(for: 1)
	moveForward(for: 2)
	turnLeft(for: 0.5)
	turnRight(for: 2)
	//#-end-editable-code
}

func turnLeft(for sec: Double) {
	move(.turnLeft, for: sec)
}

func turnRight(for sec: Double) {
	move(.turnRight, for: sec)
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
	ble.writeData(convertCommand(cmd))
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

