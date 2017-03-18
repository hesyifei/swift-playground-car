/*:
# Control your car through Swift code!

Looks like you've successfully connected to your car! Now it's time for you to play around!
*/
//#-hidden-code
import UIKit
import Foundation
import PlaygroundSupport

class ViewController: UIViewController {
	var startButton: UIButton!

	// must init here
	let ble = BLEObject()

	override func viewDidLoad(){
		super.viewDidLoad()
		title = "Control your car through Swift code"

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

		ble.startConnect()
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

		ble.disconnectPeripheral()

		startButton.isEnabled = true
		//PlaygroundPage.current.finish​Execution()
	}

	func buttonAction() {
		print("BBUTON")
		ble.restartConnect()
		startButton.isEnabled = false
	}

//#-end-hidden-code
/*:
## Create a language

In order to communicate with the car, we have to define **a set of rules** that both we (the iOS device) and the car can understand.

Just imagine you meet a foreigner who doesn't understand English. So you two decide to invent a new language so that you two can understand each other.

Now your car said _"Oh I think the format `<cmd time>` is very comprehensible!"_ and you are like _"Yeah! That's a good idea! Why don't we use `f`, `b`, `l` and `r` as `cmd` and use milliseconds for `time`?"_

But how can we do that technically? It's very easy in Swift. We will use [enum](glossary://enum) to define the specfic set of commands and use the following commands to control the car

	<f2000>        move forward for 2000 milliseconds
	<b1500>        move backward for 1500 milliseconds
	<l500>         turn left for 500 milliseconds
	<r2017>        turn right for 2017 milliseconds

Of course it's just an example. You can set the commands to whatever you like on the car and just don't forget to change it here!
*/
// Create the language
enum Operation: String {
	// You can change the commands (e.g. "f") to your own commands defined in the car
	case forward = /*#-editable-code */"f"/*#-end-editable-code*/
	case backward = /*#-editable-code */"b"/*#-end-editable-code*/
	case turnLeft = /*#-editable-code */"l"/*#-end-editable-code*/
	case turnRight = /*#-editable-code */"r"/*#-end-editable-code*/
}

// Control the car
func move(_ operation: Operation, for sec: Double) {
	let msec: Int = Int(sec*1000)                    // 1 second = 1000 milliseconds

	// You can also define your own set of rule that can be interpreted by your car
	runCommand(/*#-editable-code */"<\(operation.rawValue)\(msec)>"/*#-end-editable-code*/)     // run the command

	waitFor(msec)                                    // wait until this movement is finished to do the next one
}
/*:
Now you two have a common ground.

But remember that the car don't understand English? Letters like `f` and `b` are still English and the car find it very difficult to recognize the alphabets!

Fortunately, you two both understand a "language"¹ named [HEX](glossary://HEX). So you will have to "encode" your command in HEX format and the car will "decode" the command to whatever "language" it used.

_¹ Note: HEX isn't really a language._
*/
// Convert English into HEX
func convertCommand(_ cmd: String) -> Data {
	return cmd.data(using: String.Encoding.utf8)!
}

// how can we send our command to our car?
func runCommand(_ cmd: String) {
	ble.writeData(convertCommand(cmd))
}
/*:
## Control the car using your invented language

After we finish the basic function above, it's time to run!

    moveForward(for: 5)     // move the car forward for 5 seconds
	moveBackward(for: 2)    // move the car backward for 2 seconds
	turnLeft(for: 1)        // turn left the car for 1 second
	turnRight(for: 2)       // turn right the car for 2 seconds
*/
// You will control your device in this function
func controlDevice() {
	//#-code-completion(everything, hide)
	//#-code-completion(currentmodule, hide)
	//#-code-completion(identifier, show, moveForward(for:), moveBackward(for:), turnLeft(for:), turnRight(for:), if, for, while, =, <, >, ==, !=, +, -, true, false, &&, ||, !)
	//#-editable-code Tap to enter code

	//#-end-editable-code
}

// We wrap each command into function so that we can use it easier and avoid duplicated code
func turnLeft(for sec: Double) {
	move(.turnLeft, for: sec)
}

func turnRight(for sec: Double) {
	move(.turnRight, for: sec)
}

func moveForward(for sec: Double) {
	move(.forward, for: sec)
}

func moveBackward(for sec: Double) {
	move(.backward, for: sec)
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

