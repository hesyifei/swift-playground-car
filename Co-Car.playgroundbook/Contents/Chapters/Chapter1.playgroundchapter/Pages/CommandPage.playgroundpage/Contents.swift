/*:
# Control your car through Swift code! ⌨️

Looks like you've successfully connected to your car! Now it's time for you to play around!
*/
//#-hidden-code
import UIKit
import Foundation
import PlaygroundSupport
//#-end-hidden-code
/*:
## Create a language

In order to communicate with the car, we have to define **a set of rules** that both we (the iOS device) and the car can understand.

Just imagine you meet a foreigner who doesn't understand English. So you two decide to invent a new language so that you two can understand each other.

Now your car said _"Oh I think the format `<cmd time>` is very comprehensible!"_ and you are like _"Yeah! That's a good idea! Why don't we use `f`, `b`, `l` and `r` as `cmd` and use milliseconds for `time`?"_

But how can we do that technically? It's very easy in Swift. We will use [enumeration](glossary://enumeration) `enum` to define the specfic set of commands and use the following commands to control the car

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
	case stop = /*#-editable-code */"s"/*#-end-editable-code*/
}
//#-hidden-code

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
	var tableView: UITableView!

	var controlledCarTimes = 0

	var timeNeedToWait: Double = 0.0		// important!

	// must init here
	let ble = BLEObject()

	var tableData = [String]()

	override func viewDidLoad(){
		super.viewDidLoad()
		title = "Command History"


		// http://stackoverflow.com/a/7751272/2603230
		NotificationCenter.default.removeObserver(self, name: NotificationName.didLinkUpToCharacteristic, object: nil)
		NotificationCenter.default.removeObserver(self, name: NotificationName.didDisconnectPeripheral, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(self.didLinkUpToCharacteristic), name: NotificationName.didLinkUpToCharacteristic, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(self.didDisconnectPeripheral), name: NotificationName.didDisconnectPeripheral, object: nil)


		ble.startConnect()


		tableView = UITableView(frame: CGRect(), style: .plain)
		tableView.delegate = self
		tableView.dataSource = self
		tableView.translatesAutoresizingMaskIntoConstraints = false

		self.view.addSubview(tableView)

		self.view.addConstraint(NSLayoutConstraint(item: tableView, attribute: .leading, relatedBy: .equal, toItem: self.view, attribute: .leading, multiplier: 1, constant: 0))
		self.view.addConstraint(NSLayoutConstraint(item: tableView, attribute: .trailing, relatedBy: .equal, toItem: self.view, attribute: .trailing, multiplier: 1, constant: 0))
		self.view.addConstraint(NSLayoutConstraint(item: tableView, attribute: .top, relatedBy: .equal, toItem: self.view, attribute: .top, multiplier: 1, constant: 0))
		self.view.addConstraint(NSLayoutConstraint(item: tableView, attribute: .bottom, relatedBy: .equal, toItem: self.view, attribute: .bottom, multiplier: 1, constant: 0))


		DispatchQueue.main.async {
			self.appendToTable("Connecting...")
		}

		UserDefaults.standard.set(Operation.forward.rawValue, forKey: "oForward")
		UserDefaults.standard.set(Operation.backward.rawValue, forKey: "oBackward")
		UserDefaults.standard.set(Operation.turnLeft.rawValue, forKey: "oTurnLeft")
		UserDefaults.standard.set(Operation.turnRight.rawValue, forKey: "oTurnRight")
		UserDefaults.standard.set(Operation.stop.rawValue, forKey: "oStop")
	}


	func didDisconnectPeripheral() {
		print("recieved didDisconnectPeripheral")
	}

	func didLinkUpToCharacteristic() {
		print("recieved connectedToCharacteristic")

		controlDevice()

		HelperFunc.delay(bySeconds: timeNeedToWait) {		// wait until all movements are finished
			self.ble.disconnectPeripheral()

			if self.controlledCarTimes >= 4 {
				PlaygroundPage.current.assessmentStatus = .pass(message: "You've controlled your car through Swift code successfully! Now go to the [next page](@next) and continue! 🎉")
				DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(3)) {
					PlaygroundPage.current.finishExecution()
				}
			} else {
				PlaygroundPage.current.assessmentStatus = .fail(hints: ["Control the car to do **at least 4 movements**! You've just done \(self.controlledCarTimes). 😜"], solution: nil)
				DispatchQueue.main.async {
					PlaygroundPage.current.finishExecution()
				}
			}
		}
	}

	// MARK: - tableView related
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return tableData.count
	}

	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		var cell: UITableViewCell!
		if let reuseCell = tableView.dequeueReusableCell(withIdentifier: "cell") {
			cell = reuseCell
		} else {
			cell = UITableViewCell(style: .subtitle, reuseIdentifier: "cell")
		}
		let data = tableData[indexPath.row].components(separatedBy: "|")
		cell.textLabel?.text = data[0]
		if data.count == 2 {
			cell.detailTextLabel?.text = data[1]
		}
		return cell
	}

	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		self.tableView.deselectRow(at: indexPath, animated: true)
	}

	func appendToTable(_ newText: String) {
		tableData.append("\(newText)|\(Date().getHumanReadableString())")

		self.tableView.beginUpdates()
		self.tableView.insertRows(at: [IndexPath(row: self.tableData.count-1, section: 0)], with: .automatic)
		self.tableView.endUpdates()
		self.tableView.scrollToRow(at: IndexPath(row: self.tableData.count-1, section: 0), at: .bottom, animated: true)
	}

//#-end-hidden-code
// Control the car
func move(_ operation: Operation, for sec: Double) {
	let msec: Int = Int(sec*1000)                 // 1 second = 1000 milliseconds
	//#-hidden-code
	HelperFunc.delay(bySeconds: timeNeedToWait) { // wait until last movement is finished to do the next one
	//#-end-hidden-code
	// You can also define your own set of rule that can be interpreted by your car
	let yourCommand = /*#-editable-code */"<\(operation.rawValue)\(msec)>"/*#-end-editable-code*/
	//#-hidden-code
		NotificationCenter.default.post(name: NotificationName.simulationReceivedCommand, object: ["cmd": yourCommand])
		self.appendToTable("\(yourCommand)")
	//#-end-hidden-code
	self.runCommand(yourCommand)                  // run the command
	//#-hidden-code
		self.controlledCarTimes = self.controlledCarTimes+1
	}
	//#-end-hidden-code
	wait(for: sec)                                // wait until this movement is finished to do the next one
}
/*:
Now you two have a common ground.

But remember that the car don't understand English? Letters like `f` and `b` are still English and the car find it very difficult to recognize the alphabets!

Fortunately, you two both understand a "language"¹ named [hexadecimal](glossary://hexadecimal) (hex). So you will have to "encode" your command in HEX format and the car will "decode" the command to whatever "language" it used.

_¹ Note: Hexadecimal isn't really a language._
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

    move(Operation.forward, for: 3.5)   // move the car forward for 3.5 seconds
	move(Operation.backward, for: 2)    // move the car backward for 2 seconds
	move(Operation.turnLeft, for: 1)    // turn left the car for 1 second
	move(Operation.turnRight, for: 2)   // turn right the car for 2 seconds
	wait(for: 1.5)                      // wait for 1.5 seconds until next operation

## Quest

 1. Play around the code to move your car (it's really easy 😜)!
 2. Control the car to do **at least 4 movements**.
*/
// You will control your device in this function
func controlDevice() {
	//#-hidden-code
	wait(for: 2)			// wait for better performance
	//#-end-hidden-code
	//#-code-completion(everything, hide)
	//#-code-completion(currentmodule, hide)
	//#-code-completion(identifier, show, move(_:for:), wait(for:), Operation, ., forward, backward, turnLeft, turnRight, if, for, while, =, <, >, ==, !=, +, -, true, false, &&, ||, !)
	//#-editable-code Tap to enter code
	//#-end-editable-code
}
//#-hidden-code

	func wait(for sec: Double) {
		/*// before
		delay(bySeconds: timeNeedToWait) {
			self.appendToTable("wait \(sec) START \(Date())")
		}*/
		timeNeedToWait = timeNeedToWait + sec
		/*// after
		delay(bySeconds: timeNeedToWait) {
			self.appendToTable("wait \(sec) END \(Date())")
		}*/
	}
}


let viewControllerOri = ViewController()
let viewController = UINavigationController(rootViewController: viewControllerOri)

let controller = OuterViewController(upperViewController: viewController, lowerViewController: SimulationViewController())

PlaygroundPage.current.liveView = controller
PlaygroundPage.current.needsIndefiniteExecution = true

