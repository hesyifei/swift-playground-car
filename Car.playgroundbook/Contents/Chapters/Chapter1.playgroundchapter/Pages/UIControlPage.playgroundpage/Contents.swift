/*:
# Be a developer and let anyone control your car! 🕹

Now you know how to control your car using Swift. But how about your friends and family? They know nothing about Swift!

In this page, you are going to learn how to design an app (or simply a page) that is user-friendly and take the first step to become a developer!

Oh, and don't forget to run your code every time you finish a quest! 😜

## The basic

Each page of an app you used is a **[view controller](glossary://viewcontroller)**, in which there are buttons, labels, text fields, etc. To begin with, you have to create the view controller:
*/
//#-hidden-code
import UIKit
import PlaygroundSupport
import AVFoundation

public class Operation {
	public static let forward = CarOperation.forward
	public static let backward = CarOperation.backward
	public static let turnLeft = CarOperation.turnLeft
	public static let turnRight = CarOperation.turnRight
	public static let stop = CarOperation.stop
}

//#-end-hidden-code
class ViewController: UIViewController {
	//#-hidden-code

	var controlledCarTimes = 0

	// must init here
	let ble = BLEObject()

	//#-end-hidden-code
/*:
But you can't just have an empty page. Let's do something to initialize the page!

In Swift, you can `override` the `func viewDidLoad()` to **initialize a view controller**. For example, in this function you can change the variable `title` to set the **[title](glossary://title)** of this view controller. ⚙️

### Quest 1

Set your view's title to anything that contain the word "car".
*/
var mainLabel: UILabel!

override func viewDidLoad(){
	super.viewDidLoad()    // Don't forget this. You still need to call the original function first, even if you are overriding it :)
	//#-code-completion(everything, hide)
	//#-code-completion(currentmodule, hide)
	//#-code-completion(identifier, show, =, ., self, title)
	//#-editable-code Tap to enter code
	// CCHANGE
	self.title = "my car"
	//#-end-editable-code
	//#-hidden-code
		if self.title?.lowercased().range(of: "car") == nil {
			PlaygroundPage.current.assessmentStatus = .fail(hints: ["Are you sure there is \"car\" in your title? 🤔"], solution: nil)
			PlaygroundPage.current.finishExecution()
		}

		self.view.backgroundColor = UIColor.white
//#-end-hidden-code
/*:
Now we have a title! To control a car, it'll be great if a label (with some text) showing user how there car is running is on the screen.

In Swift, we can add a `smallerView` (e.g. `UILabel`) to a `biggerView` (e.g. `view` which is the biggest & utmost view in the whole view controller) by `biggerView.addSubview(smallerView)`. Note that `addSubview(_:)` can be called everywhere, but because of what we want is initializing the `smallerView`, we will use this piece of code in `viewDidLoad()`.

To control the position of the label, you can either enter exact frame position or use [Auto Layout](glossary://AutoLayout) to make the view adaptive to all devices with different sizes. Details about positioning and auto layout can be found in the advanced tutorial. But for now, you just have to understand that what we are doing is **sticking a label (`mainLabel`) to a board (`view`)**. 📃

### Quest 2

Add `mainLabel` which have font size `30` to `view`.
*/
	// we initialized variable in class already, so we don't need `let` here
	mainLabel = UILabel()
	//#-hidden-code
	mainLabel.translatesAutoresizingMaskIntoConstraints = false
	mainLabel.text = "Connecting..."
	//#-end-hidden-code
	// CCHANGE
	mainLabel.font = UIFont.systemFont(ofSize: 30)
	//mainLabel.font = UIFont.systemFont(ofSize: /*#-editable-code*/<#T##font size##Double#>/*#-end-editable-code*/)
	//#-code-completion(everything, hide)
	//#-code-completion(currentmodule, hide)
	//#-code-completion(identifier, show, ., self, view, addSubview(_:), mainLabel)
	//#-editable-code Tap to enter code
	// CCHANGE
	self.view.addSubview(mainLabel)
	//#-end-editable-code
	//#-hidden-code

		if self.mainLabel.font.pointSize != 30 {
			PlaygroundPage.current.assessmentStatus = .fail(hints: ["Are you sure `mainLabel`'s font size is 30? 🤔"], solution: nil)
			PlaygroundPage.current.finishExecution()
		}
		if !self.mainLabel.isDescendant(of: self.view) {
			PlaygroundPage.current.assessmentStatus = .fail(hints: ["Are you sure `mainLabel` is added to `view`? 🤔"], solution: nil)
			PlaygroundPage.current.finishExecution()
		}


		let horizontalConstraint = NSLayoutConstraint(item: mainLabel, attribute: .centerX, relatedBy: .equal, toItem: view, attribute: .centerX, multiplier: 1, constant: 0)
		let verticalConstraint = NSLayoutConstraint(item: mainLabel, attribute: .centerY, relatedBy: .equal, toItem: view, attribute: .centerY, multiplier: 1, constant: 0)
		self.view.addConstraints([horizontalConstraint, verticalConstraint])


		// http://stackoverflow.com/a/7751272/2603230
		NotificationCenter.default.removeObserver(self, name: NotificationName.didLinkUpToCharacteristic, object: nil)
		NotificationCenter.default.removeObserver(self, name: NotificationName.didDisconnectPeripheral, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(self.didLinkUpToCharacteristic), name: NotificationName.didLinkUpToCharacteristic, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(self.didDisconnectPeripheral), name: NotificationName.didDisconnectPeripheral, object: nil)

		ble.startConnect()


//#-end-hidden-code
/*:
Let's recall the basic components of controlling a car: forward, backward, turn left, turn right and of course stop. To utilize the screen, let's use [`UISwipe​Gesture​Recognizer`](glossary://USGR) to **recognize swipe gesture** which will be used to control the car's direction and use [`UITapGestureRecognizer`](glossary://UITapGestureRecognizer) to **recognize double taps** which will be used to stop the car. 📱

### Learn

We can use `#selector(self.functionName)` to indicate the action to be taken is inside `func functionName()`.

### Quest 3

Add suitable directions (`.up`, `.left`, etc.) to `directions` array and set suitable `numberOfTapsRequired`.
*/
//#-code-completion(everything, hide)
//#-code-completion(currentmodule, hide)
//#-code-completion(literal, show, array)
//#-code-completion(identifier, show, UISwipeGestureRecognizerDirection, ., up, down, left, right)
	// CCHANGE
	//let directions: [UISwipeGestureRecognizerDirection] = /*#-editable-code Tap to enter code*/<#T##directions##Array#>/*#-end-editable-code*/
	let directions: [UISwipeGestureRecognizerDirection] = [.left, .right, .up, .down]
	for direction in directions {    // add four directions' swipe gesture
		let gesture = UISwipeGestureRecognizer(target: self, action: #selector(self.respondToSwipeGesture))
		gesture.direction = direction
		self.view.addGestureRecognizer(gesture)
	}

	let tap = UITapGestureRecognizer(target: self, action: #selector(self.respondToDoubleTapped))
	// CCHANGE
	//tap.numberOfTapsRequired = /*#-editable-code*/<#T##number of taps##Int#>/*#-end-editable-code*/
	tap.numberOfTapsRequired = 2
	self.view.addGestureRecognizer(tap)

	//#-hidden-code
		if directions != [.left, .right, .up, .down] {
			PlaygroundPage.current.assessmentStatus = .fail(hints: ["Are you sure all four directions are added? 🤔"], solution: nil)
			PlaygroundPage.current.finishExecution()
		}
		if tap.numberOfTapsRequired != 2 {
			PlaygroundPage.current.assessmentStatus = .fail(hints: ["Are you sure you are detecting a double taps? 🤔"], solution: nil)
			PlaygroundPage.current.finishExecution()
		}
	//#-end-hidden-code
}      // viewDidLoad() end here
//#-hidden-code

	// Control the car
	func move(_ operation: String) {
		controlledCarTimes = controlledCarTimes+1
		let yourCommand = "<\(operation)>"
		self.runCommand(yourCommand)

		NotificationCenter.default.post(name: NotificationName.simulationReceivedCommand, object: ["cmd": yourCommand])

		if controlledCarTimes == 10 {
			PlaygroundPage.current.assessmentStatus = .pass(message: "You've developed your first app successfully! Now share it with your friends and family 🤗 or go to the [next page](@next) and continue! 🎉")
			// don't finishExecution; let user play
		}
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

		mainLabel.text = "Try swipe or double tap me!"
	}


	let synth = AVSpeechSynthesizer()
	var myUtterance = AVSpeechUtterance(string: "")
	func speak(_ inputText: String) {
		myUtterance = AVSpeechUtterance(string: inputText)
		myUtterance.rate = AVSpeechUtteranceDefaultSpeechRate
		synth.speak(myUtterance)
	}
//#-end-hidden-code
/*:
Now it's time to handle the gestures! The `move` function is changed slightly comparing to that of the last page. 🕹

	move(Operation.forward)     // move the car forward forever
	move(Operation.backward)    // move the car backward forever
	move(Operation.turnLeft)    // turn left forever
	move(Operation.turnRight)   // turn right forever
	move(Operation.stop)        // stop the car

### Final Quest

1. Use suitable functions to control the car by swipes and taps. (Hint: `switch` & `case`, `direction`, `[.right]`, `Operation.move()`)
2. Display current action in `mainLabel` and also `print()` out current action for debug.
3. Perform at least 10 operations with swipes and taps.
4. (Optional) Use function `speak(text)` to let your iPad read out the direction change.

*/
//#-code-completion(everything, hide)
//#-code-completion(currentmodule, hide)
//#-code-completion(identifier, show, switch, case, break, UISwipeGestureRecognizerDirection, left, right, down, up, ., print, mainLabel, text, move(_:), speak(_:), Operation, forward, backward, turnLeft, turnRight, !)
func respondToSwipeGesture(gesture: UIGestureRecognizer) {
	if let swipeGesture = gesture as? UISwipeGestureRecognizer {
		let direction = swipeGesture.direction      // swipe direction may be .left, .right, .up and .down
		//#-editable-code Tap to enter code
		// CCHANGE
		switch direction {
		case [.right]:
			print("Swiped right")
			mainLabel.text = "Right..."
			move(Operation.turnRight)
			speak("Turn right")
			break
		case [.down]:
			print("Swiped down")
			mainLabel.text = "Down..."
			move(Operation.backward)
			speak("Go backward")
			break
		case [.left]:
			print("Swiped left")
			mainLabel.text = "Left..."
			move(Operation.turnLeft)
			speak("Turn left")
			break
		case [.up]:
			print("Swiped up")
			mainLabel.text = "Up..."
			move(Operation.forward)
			speak("Go forward")
			break
		default:
			break
		}
		//#-end-editable-code
	}
}

func respondToDoubleTapped() {
	//#-editable-code Tap to enter code
	// CCHANGE
	print("Double tapped")
	mainLabel.text = "Stop..."
	move(Operation.stop)
	speak("Stop")
	//#-end-editable-code
}

/*:
## Try it out! 🎉

Congrats! You've just finished your first app that everyone can use! Now show this to your friends and family! 🎉
 
## Optional Quest 😂

Don't forget to share this playground so that they can also learn and discover how fun it is too! 😉
*/
//#-hidden-code
}

let viewControllerOri = ViewController()
let viewController = UINavigationController(rootViewController: viewControllerOri)

let controller = OuterViewController(upperViewController: viewController, lowerViewController: SimulationViewController())

PlaygroundPage.current.liveView = controller
PlaygroundPage.current.needsIndefiniteExecution = true

