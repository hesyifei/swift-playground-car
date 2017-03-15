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

class ViewController: UIViewController {

	override func viewDidLoad(){
		super.viewDidLoad()

		self.view.backgroundColor = UIColor.yellow


		let directions: [UISwipeGestureRecognizerDirection] = [.right, .left, .up, .down]
		for direction in directions {
			let gesture = UISwipeGestureRecognizer(target: self, action: #selector(self.respondToSwipeGesture))
			gesture.direction = direction
			self.view.addGestureRecognizer(gesture)
		}




		let viewRect = CGRect(x: 0, y: 0, width: 100 , height: 400)
		let theView = UIView(frame: viewRect)
		theView.backgroundColor = UIColor.blue

		self.view.addSubview(theView)
	}

//#-end-hidden-code
func respondToSwipeGesture(gesture: UIGestureRecognizer) {
	if let swipeGesture = gesture as? UISwipeGestureRecognizer {
		switch swipeGesture.direction {
		case UISwipeGestureRecognizerDirection.right:
			//#-editable-code
			print("Swiped right")
			//#-end-editable-code
			break
		case UISwipeGestureRecognizerDirection.down:
			//#-editable-code
			print("Swiped down")
			//#-end-editable-code
			break
		case UISwipeGestureRecognizerDirection.left:
			//#-editable-code
			print("Swiped LEFT")
			//#-end-editable-code
			break
		case UISwipeGestureRecognizerDirection.up:
			//#-editable-code
			print("Swiped up")
			//#-end-editable-code
			break
		default:
			break
		}
	}
}
//#-hidden-code
}

let controller = ViewController()

PlaygroundPage.current.liveView = controller


