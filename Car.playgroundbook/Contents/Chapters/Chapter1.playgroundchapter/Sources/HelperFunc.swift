import UIKit
import Foundation
import AVFoundation

public class HelperFunc {
	public static func delay(bySeconds seconds: Double, dispatchLevel: DispatchLevel = .main, closure: @escaping () -> Void) {
		let dispatchTime = DispatchTime.now() + seconds
		dispatchLevel.dispatchQueue.asyncAfter(deadline: dispatchTime, execute: closure)
	}

	public enum DispatchLevel {
		case main, userInteractive, userInitiated, utility, background
		var dispatchQueue: DispatchQueue {
			switch self {
			case .main:                 return DispatchQueue.main
			case .userInteractive:      return DispatchQueue.global(qos: .userInteractive)
			case .userInitiated:        return DispatchQueue.global(qos: .userInitiated)
			case .utility:              return DispatchQueue.global(qos: .utility)
			case .background:           return DispatchQueue.global(qos: .background)
			}
		}
	}
}

public class CarOperation {
	public static let forward = UserDefaults.standard.string(forKey: "oForward") ?? "f"
	public static let backward = UserDefaults.standard.string(forKey: "oBackward") ?? "b"
	public static let turnLeft = UserDefaults.standard.string(forKey: "oTurnLeft") ?? "l"
	public static let turnRight = UserDefaults.standard.string(forKey: "oTurnRight") ?? "r"
	public static let stop = UserDefaults.standard.string(forKey: "oStop") ?? "s"
}


extension Date {
	public func getHumanReadableString() -> String {
		let formatter = DateFormatter()
		formatter.locale = Locale.current
		formatter.dateStyle = .none
		formatter.timeStyle = .medium

		return formatter.string(from: self)
	}
}
