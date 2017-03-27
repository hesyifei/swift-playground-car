/*:
# Rock, Paper, Scissors (Roshambo!)
Rock, Paper, Scissors is a game for two players—you and a robot opponent. Each player chooses an action that represents an object (rock ✊, paper 🖐, or scissors✌️), and each action beats one of the other actions:
* ✊ beats ✌️ (rock crushes scissors)
* ✌️ beats 🖐 (scissors cut paper)
* 🖐 beats ✊ (paper covers rock)

The robot opponent chooses actions randomly.

If both players choose the same action, that round ends in a tie. The first player to win three rounds wins the game.

When you’re ready, move on to the next page to personalize your game.
*/

//#-hidden-code
import UIKit
import PlaygroundSupport

public class Operation {
	public static let forward = CarOperation.forward
	public static let backward = CarOperation.backward
	public static let turnLeft = CarOperation.turnLeft
	public static let turnRight = CarOperation.turnRight
	public static let stop = "s"
}

class ViewController: UIViewController {

	// must init here
	let ble = BLEObject()

	override func viewDidLoad(){
		super.viewDidLoad()

		self.view.backgroundColor = UIColor.yellow


		// http://stackoverflow.com/a/7751272/2603230
		NotificationCenter.default.removeObserver(self, name: NotificationName.didLinkUpToCharacteristic, object: nil)
		NotificationCenter.default.removeObserver(self, name: NotificationName.didDisconnectPeripheral, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(self.didLinkUpToCharacteristic), name: NotificationName.didLinkUpToCharacteristic, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(self.didDisconnectPeripheral), name: NotificationName.didDisconnectPeripheral, object: nil)

		ble.startConnect()


//#-end-hidden-code
let directions: [UISwipeGestureRecognizerDirection] = [.right, .left, .up, .down]
for direction in directions {
	let gesture = UISwipeGestureRecognizer(target: self, action: #selector(self.respondToSwipeGesture))
	gesture.direction = direction
	self.view.addGestureRecognizer(gesture)
}

let tap = UITapGestureRecognizer(target: self, action: #selector(self.respondToDoubleTapped))
tap.numberOfTapsRequired = 2
self.view.addGestureRecognizer(tap)
//#-hidden-code



		let viewRect = CGRect(x: 0, y: 0, width: 100 , height: 400)
		let theView = UIView(frame: viewRect)
		theView.backgroundColor = UIColor.blue

		self.view.addSubview(theView)
	}


//#-end-hidden-code
// Control the car
func move(_ operation: String) {
	self.runCommand("<\(operation)>")
}

//#-hidden-code
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
	}
//#-end-hidden-code
//#-code-completion(everything, hide)
//#-code-completion(currentmodule, hide)
//#-code-completion(identifier, show, move(_:), Operation, ., forward, backward, turnLeft, turnRight, !)
func respondToSwipeGesture(gesture: UIGestureRecognizer) {
	if let swipeGesture = gesture as? UISwipeGestureRecognizer {
		switch swipeGesture.direction {
		case [.right]:
			//#-editable-code
			print("Swiped right")
			move(Operation.turnRight)
			//#-end-editable-code
			break
		case [.down]:
			//#-editable-code
			print("Swiped down")
			move(Operation.backward)
			//#-end-editable-code
			break
		case [.left]:
			//#-editable-code
			print("Swiped left")
			move(Operation.turnLeft)
			//#-end-editable-code
			break
		case [.up]:
			//#-editable-code
			print("Swiped up")
			move(Operation.forward)
			//#-end-editable-code
			break
		}
	}
}

func respondToDoubleTapped() {
	//#-editable-code
	print("Double tapped")
	move(Operation.stop)
	//#-end-editable-code
}
//#-hidden-code
}

let controller = ViewController()

PlaygroundPage.current.liveView = controller


