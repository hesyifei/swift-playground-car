import UIKit
import SpriteKit
import Foundation

public class SimulationViewController: UIViewController {
	var skView: SKView!

	var carNode: SKSpriteNode!

	var timeNeedToWait: Double = 0.0		// important!

	var carAdded = false
	var smallestSize: CGSize!

	public override func viewDidLoad() {
		super.viewDidLoad()

		NotificationCenter.default.removeObserver(self, name: NotificationName.simulationReceivedCommand, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(self.simulationReceivedCommand(_:)), name: NotificationName.simulationReceivedCommand, object: nil)
	}

	public override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()

		// to avoid bug as viewDidLayoutSubviews may be called more than once
		// without this code the view will be added twice and problem arise
		if let smallestSize = smallestSize {
			if smallestSize.width > self.view.frame.width {
				skView.removeFromSuperview()
				carAdded = false
			}
		}

		if carAdded == false {
			let largerFrame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height)
			self.skView = SKView(frame: largerFrame)
			if self.skView.isDescendant(of: self.view) {
				self.skView.removeFromSuperview()
			}
			self.view.addSubview(self.skView)

			smallestSize = largerFrame.size


			let scene = SKScene(size: largerFrame.size)
			scene.scaleMode = .aspectFit

			scene.physicsBody = SKPhysicsBody(edgeLoopFrom: largerFrame)
			scene.physicsWorld.gravity = CGVector(dx: 0, dy: 0)
			scene.physicsBody?.friction = 0.0

			skView.presentScene(scene)


			// 600.0 * 1255.0 is the car's image's size
			let carSize = CGSize(width: 50.0, height: 50.0/(600.0/1255.0))
			self.carNode = SKSpriteNode(color: SKColor.red, size: carSize)
			self.carNode.texture = SKTexture(imageNamed: "Car")
			self.carNode.position = CGPoint(x: skView.frame.width/2, y: skView.frame.height/2)
			self.carNode.physicsBody = SKPhysicsBody(rectangleOf: carSize)
			self.carNode.physicsBody?.restitution = 1
			self.carNode.physicsBody?.friction = 0.0
			self.carNode.physicsBody?.angularDamping = 0
			self.carNode.physicsBody?.linearDamping = 0

			scene.addChild(self.carNode)
			
			carAdded = true
		}
	}

	final let RUN_KEY = "runKey"
	func move(_ operation: String, for oriSec: Double) {
		var isForever = false
		if oriSec == 0 {
			isForever = true
		}

		var sec = oriSec
		if isForever {
			timeNeedToWait = 0
			sec = 1
		}
		HelperFunc.delay(bySeconds: timeNeedToWait) {
			let msec: Int = Int(sec*1000)

			switch operation {
			case CarOperation.forward, CarOperation.backward:
				let length = 0.1*Double(msec)

				let zRotation = Double.pi-Double(self.carNode.zRotation)

				var moveVector = CGVector(dx: -length*sin(zRotation), dy: -length*cos(zRotation))
				if operation == CarOperation.backward {
					moveVector = CGVector(dx: length*sin(zRotation), dy: length*cos(zRotation))
				}
				if isForever {
					self.carNode.run(SKAction.repeatForever(SKAction.move(by: moveVector, duration: sec)), withKey: self.RUN_KEY)
				} else {
					self.carNode.run(SKAction.move(by: moveVector, duration: sec))
				}
				break
			case CarOperation.turnLeft, CarOperation.turnRight:
				var angle = CGFloat(0.001*Double(msec))

				if operation == CarOperation.turnLeft {

				} else if operation == CarOperation.turnRight {
					angle = -angle
				}

				if isForever {
					self.carNode.run(SKAction.repeatForever(SKAction.rotate(byAngle: angle, duration: sec)), withKey: self.RUN_KEY)
				} else {
					self.carNode.run(SKAction.rotate(byAngle: angle, duration: sec))
				}
				break
			case CarOperation.stop:
				self.carNode.removeAction(forKey: self.RUN_KEY)
				break
			default:
				break
			}
		}
		wait(for: sec)                                // wait until this movement is finished to do the next one
	}

	func wait(for sec: Double) {
		timeNeedToWait = timeNeedToWait + sec
	}

	func simulationReceivedCommand(_ notification: NSNotification){
		if let object = notification.object as? [String: Any] {
			if let oriCmd = object["cmd"] as? String {
				if oriCmd.characters.count >= 3 {
					var cmd = oriCmd
					cmd.remove(at: cmd.startIndex)
					cmd.remove(at: cmd.index(before: cmd.endIndex))
					let movement = String(cmd[cmd.startIndex])
					cmd.remove(at: cmd.startIndex)
					if cmd.characters.count == 0 {
						move(movement, for: 0)
					} else if let msec = Int(cmd) {
						move(movement, for: Double(msec)/1000.0)
					}
				}
			}
		}
	}
}
