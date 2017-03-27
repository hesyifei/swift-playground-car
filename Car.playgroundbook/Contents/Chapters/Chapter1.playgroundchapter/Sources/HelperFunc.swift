import UIKit
import Foundation

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
