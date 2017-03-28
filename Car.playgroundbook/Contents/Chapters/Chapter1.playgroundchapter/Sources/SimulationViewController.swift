import UIKit
import SpriteKit
import Foundation

public class SimulationViewController: UIViewController {
	var carNode: SKSpriteNode!

	var timeNeedToWait: Double = 0.0

	public override func viewDidLoad() {
		super.viewDidLoad()

		NotificationCenter.default.removeObserver(self, name: NotificationName.simulationReceivedCommand, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(self.simulationReceivedCommand(_:)), name: NotificationName.simulationReceivedCommand, object: nil)
	}

	public override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)


		let skView = SKView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height))
		self.view.addSubview(skView)


		let scene = SKScene(size: CGSize(width: skView.frame.width, height: skView.frame.height))
		scene.scaleMode = .aspectFit

		scene.physicsBody = SKPhysicsBody(edgeLoopFrom: scene.frame)
		scene.physicsWorld.gravity = CGVector(dx: 0, dy: 0)
		scene.physicsBody?.friction = 0.0

		skView.presentScene(scene)


		self.carNode = SKSpriteNode(color: SKColor.red, size: CGSize(width: 50, height: 100))
		self.carNode.position = CGPoint(x: skView.frame.width/2, y: skView.frame.height/2)
		self.carNode.physicsBody = SKPhysicsBody(rectangleOf: self.carNode.frame.size)
		self.carNode.physicsBody?.restitution = 1
		self.carNode.physicsBody?.friction = 0.0
		self.carNode.physicsBody?.angularDamping = 0
		self.carNode.physicsBody?.linearDamping = 0

		scene.addChild(self.carNode)
	}

	func move(_ operation: String, for sec: Double) {
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
				self.carNode.run(SKAction.move(by: moveVector, duration: sec))
				break
			case CarOperation.turnLeft, CarOperation.turnRight:
				let angle = CGFloat(0.001*Double(msec))

				if operation == CarOperation.turnLeft {
					self.carNode.run(SKAction.rotate(byAngle: angle, duration: sec))
				} else if operation == CarOperation.turnRight {
					self.carNode.run(SKAction.rotate(byAngle: -angle, duration: sec))
				}
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
				if oriCmd.characters.count >= 4 {
					var cmd = oriCmd
					cmd.remove(at: cmd.startIndex)
					cmd.remove(at: cmd.index(before: cmd.endIndex))
					let movement = String(cmd[cmd.startIndex])
					cmd.remove(at: cmd.startIndex)
					if let msec = Int(cmd) {
						move(movement, for: Double(msec)/1000.0)
					}
				}
			}
		}
	}
}
