import UIKit
import SpriteKit
import Foundation

public class SimulationViewController: UIViewController {
	var skView: SKView!
	var scene: CarScene!

	var carNode: SKSpriteNode!

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


			scene = CarScene(size: largerFrame.size)
			scene.scaleMode = .aspectFit

			scene.physicsBody = SKPhysicsBody(edgeLoopFrom: largerFrame)
			scene.physicsWorld.gravity = CGVector(dx: 0, dy: 0)
			scene.physicsBody?.friction = 0.0

			skView.presentScene(scene)


			// 600.0 * 1255.0 is the car's image's size
			let carSize = CGSize(width: 50.0, height: 50.0/(600.0/1255.0))
			self.carNode = SKSpriteNode(color: SKColor.red, size: carSize)
			self.carNode.name = "Car"
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
			sec = 1
		}

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

	public func getDistanceToWall() -> Double {
		if self.scene != nil {
			return self.scene!.getDistanceToWall()
		} else {
			return 1000.0
		}
	}
}

class CarScene: SKScene {
	internal var carNode: SKSpriteNode?

	//internal var linePointingShape: SKShapeNode!

	func getDistanceToWall() -> Double {
		if let carNode = self.carNode {

			// following code is based on testing by myself

			let pRotation = Double.pi-Double(carNode.zRotation)
			let halfCarHeight = Double(carNode.size.height/2.0)
			let carFrontPosition = CGPoint(x: Double(carNode.position.x)-halfCarHeight*sin(pRotation), y: Double(carNode.position.y)-halfCarHeight*cos(pRotation))


			var xDistanceFromOrigin: Double = 0.0
			var yDistanceFromOrigin: Double = 0.0

			var resultDistance: Double = 1000.0
			var quadrant: Int = 0

			switch pRotation {
			case (((3.0/4.0)*2.0*Double.pi)...(2.0*Double.pi)):	// Quadrant 4
				quadrant = 4
				xDistanceFromOrigin = Double(self.frame.maxX - carFrontPosition.x)
				yDistanceFromOrigin = Double(carFrontPosition.y - self.frame.minY)
			case ((Double.pi)...((3.0/4.0)*2.0*Double.pi)):		// Quadrant 1
				quadrant = 1
				xDistanceFromOrigin = Double(self.frame.maxX - carFrontPosition.x)
				yDistanceFromOrigin = Double(self.frame.maxY - carFrontPosition.y)
			case ((0.5*Double.pi)...(1.0*Double.pi)):			// Quadrant 2
				quadrant = 2
				xDistanceFromOrigin = Double(carFrontPosition.x - self.frame.minX)
				yDistanceFromOrigin = Double(self.frame.maxY - carFrontPosition.y)
			case (0...(0.5*Double.pi)):							// Quadrant 3
				quadrant = 3
				xDistanceFromOrigin = Double(carFrontPosition.x - self.frame.minX)
				yDistanceFromOrigin = Double(carFrontPosition.y - self.frame.minY)
			default:
				break
			}

			let quadrantMaxAngleDict: [Int: Double] = [1: (3.0/4.0)*2.0, 2: 1.0, 3: 0.5, 4: 2.0]
			let realAngle = quadrantMaxAngleDict[quadrant]!*Double.pi-pRotation

			if [1, 3].contains(quadrant) {
				let devideAngle = atan(yDistanceFromOrigin/xDistanceFromOrigin)
				if realAngle > devideAngle {
					resultDistance = yDistanceFromOrigin/cos(Double.pi/2.0-realAngle)
				} else {
					resultDistance = xDistanceFromOrigin/cos(realAngle)
				}
			} else if [2, 4].contains(quadrant) {
				let devideAngle = atan(xDistanceFromOrigin/yDistanceFromOrigin)
				if realAngle > devideAngle {
					resultDistance = xDistanceFromOrigin/cos(Double.pi/2.0-realAngle)
				} else {
					resultDistance = yDistanceFromOrigin/cos(realAngle)
				}
			}

			//resultDistance = resultDistance - 50		// debugging only
			//print(resultDistance)


			/*let path = CGMutablePath()
			path.move(to: carFrontPosition)
			path.addLine(to: CGPoint(x: Double(carFrontPosition.x)-resultDistance*sin(pRotation), y: Double(carFrontPosition.y)-resultDistance*cos(pRotation)))

			if linePointingShape != nil {
			linePointingShape.removeFromParent()
			}
			linePointingShape = SKShapeNode()
			linePointingShape.path = path
			linePointingShape.strokeColor = UIColor.white
			linePointingShape.lineWidth = 2
			addChild(linePointingShape)*/


			return resultDistance
		} else if let carNode = self.childNode(withName: "Car") as? SKSpriteNode {
			self.carNode = carNode
		}
		return 1000.0
	}
}
