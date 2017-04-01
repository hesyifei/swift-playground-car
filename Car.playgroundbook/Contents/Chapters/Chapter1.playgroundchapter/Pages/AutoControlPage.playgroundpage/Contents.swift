/*:
# An autonomous car?! 🚘

Tired of controlling your car manually? Let's try to do this automatically!

An essential feature of an autonomous car is automatically staying away from obstacles ahead. To achieve this, we've added an ultrasonic sensor at the front of the car and the distance obtained by it (in cm) will be sent back to your iPad through BLE.

In this page, you are going to learn how to achieve this particular useful function!
*/
//#-hidden-code
import UIKit
import PlaygroundSupport

var simulationViewController = SimulationViewController()

public class Operation {
	public static let forward = CarOperation.forward
	public static let backward = CarOperation.backward
	public static let turnLeft = CarOperation.turnLeft
	public static let turnRight = CarOperation.turnRight
	public static let stop = CarOperation.stop
}

class ViewController: UIViewController {

	var timeNeedToWait: Double = 0.0

	// must init here
	let ble = BLEObject()
//#-end-hidden-code
/*:
## Timer

To begin with, we can add a [`Timer`](glossary://Timer).
*/
weak var timer: Timer?
//#-hidden-code

	var mainLabel: UILabel!

	override func viewDidLoad(){
		super.viewDidLoad()
		self.title = "Auto car!"
		self.view.backgroundColor = UIColor.white

		mainLabel = UILabel()
		mainLabel.translatesAutoresizingMaskIntoConstraints = false
		mainLabel.text = "Connecting..."
		mainLabel.font = UIFont.systemFont(ofSize: 30)
		self.view.addSubview(mainLabel)

		let horizontalConstraint = NSLayoutConstraint(item: mainLabel, attribute: .centerX, relatedBy: .equal, toItem: view, attribute: .centerX, multiplier: 1, constant: 0)
		let verticalConstraint = NSLayoutConstraint(item: mainLabel, attribute: .centerY, relatedBy: .equal, toItem: view, attribute: .centerY, multiplier: 1, constant: 0)
		self.view.addConstraints([horizontalConstraint, verticalConstraint])


		// http://stackoverflow.com/a/7751272/2603230
		NotificationCenter.default.removeObserver(self, name: NotificationName.didLinkUpToCharacteristic, object: nil)
		NotificationCenter.default.removeObserver(self, name: NotificationName.didDisconnectPeripheral, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(self.didLinkUpToCharacteristic), name: NotificationName.didLinkUpToCharacteristic, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(self.didDisconnectPeripheral), name: NotificationName.didDisconnectPeripheral, object: nil)

		ble.startConnect()
	}

	deinit {
		stopTimer()
	}

	// Control the car
	func move(_ operation: String) {
		HelperFunc.delay(bySeconds: timeNeedToWait) { // wait until last movement is finished to do the next one
			let yourCommand = "<\(operation)>"
			NotificationCenter.default.post(name: NotificationName.simulationReceivedCommand, object: ["cmd": yourCommand])
			self.runCommand(yourCommand)                  // run the command
		}
		timeNeedToWait = 0.0
	}
	func move(_ operation: String, for sec: Double) {
		let msec: Int = Int(sec*1000)                 // 1 second = 1000 milliseconds
		HelperFunc.delay(bySeconds: timeNeedToWait) { // wait until last movement is finished to do the next one
			let yourCommand = "<\(operation)\(msec)>"
			NotificationCenter.default.post(name: NotificationName.simulationReceivedCommand, object: ["cmd": yourCommand])
			self.runCommand(yourCommand)                  // run the command
		}
		wait(for: sec)                                // wait until this movement is finished to do the next one
	}
	func wait(for sec: Double) {
		timeNeedToWait = timeNeedToWait + sec
	}

	func convertCommand(_ cmd: String) -> Data {
		return cmd.data(using: String.Encoding.utf8)!
	}

	func runCommand(_ cmd: String) {
		ble.writeData(convertCommand(cmd))
	}

	func didDisconnectPeripheral() {
		print("recieved didDisconnectPeripheral")
	}

	func didLinkUpToCharacteristic() {
		print("recieved connectedToCharacteristic")

//#-end-hidden-code
startTimer()		// this function is called after your iPad is successfully connected to your car.
//#-hidden-code
		mainLabel.text = "Connected :)"
	}

	func getCurrentDistanceInFront() -> Int {
		if UserDefaults.standard.bool(forKey: "hasRealCar") {
			return ble.currentDistance
		} else {
			return Int(simulationViewController.getDistanceToWall())
		}
	}

//#-end-hidden-code
/*:
Then we can use function `Timer.scheduledTimer()` function to set up a repeating timer which allow you to do some actions every `x` seconds.

## Quest
Simply do whatever you want to let car run away from obstacles. (It may sound easy, just try! 🤗)

The following are some function that you may found useful.

    self.getCurrentDistanceInFront()       // this function will return current distance between your car and the obstacle in front of it in cm
	self.move(Operation.forward)           // this will make your car move forward forever
	self.move(Operation.turnLeft, for: 5)  // this will make your car turn left for 5 seconds
*/
func startTimer() {
	timer = Timer.scheduledTimer(withTimeInterval: /*#-editable-code */0.1/*#-end-editable-code */, repeats: true) { (_) in
		// code following will be run every `TimeInterval` seconds.
		//#-hidden-code
		var unit = "px"
		if UserDefaults.standard.bool(forKey: "hasRealCar") {
			unit = "cm"
		}
		self.mainLabel.text = "\(self.getCurrentDistanceInFront()) \(unit)"
		self.timeNeedToWait = 0.0
		//#-end-hidden-code
		//#-code-completion(everything, hide)
		//#-code-completion(currentmodule, hide)
		//#-code-completion(identifier, show, self, print(_:), getCurrentDistanceInFront(), move(_:), wait(for:), Operation, ., forward, backward, turnLeft, turnRight, if, for, while, =, <, >, ==, !=, +, -, true, false, &&, ||, !)
		//#-editable-code Tap to enter code
		//#-end-editable-code
		//#-hidden-code
		/*
		// BEST SOLUTION DISCOVERED:
		print(self.getCurrentDistanceInFront())
		if self.getCurrentDistanceInFront() < 50 {
			self.move(Operation.backward, for: 0.2)
			self.move(Operation.turnLeft, for: 0.2)
		} else {
			self.move(Operation.forward)
		}*/
		//#-end-hidden-code
	}
}

// before the app stop, we have to stop the timer first. Can't left a counting watch, can we? :)
func stopTimer() {
	timer?.invalidate()
}
//#-hidden-code
}

let viewControllerOri = ViewController()
let viewController = UINavigationController(rootViewController: viewControllerOri)

// simulationViewController is defined at front

var controller: UIViewController = OuterViewController(upperViewController: viewController, lowerViewController: simulationViewController)
if UserDefaults.standard.bool(forKey: "hasRealCar") {
	controller = viewController
}

PlaygroundPage.current.liveView = controller
PlaygroundPage.current.needsIndefiniteExecution = true

