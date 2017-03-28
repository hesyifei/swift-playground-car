import UIKit
import Foundation

public class OuterViewController: UIViewController {
	var upperViewController: UIViewController
	var lowerViewController: UIViewController

	convenience init() {
		self.init(upperViewController: UIViewController(), lowerViewController: UIViewController())
	}

	public init(upperViewController: UIViewController, lowerViewController: UIViewController) {
		self.upperViewController = upperViewController
		self.lowerViewController = lowerViewController
		super.init(nibName: nil, bundle: nil)
	}

	required public init?(coder aDecoder: NSCoder) {
		self.upperViewController = UIViewController()
		self.lowerViewController = UIViewController()
		super.init(coder: aDecoder)
	}

	public override func viewDidLoad() {
		super.viewDidLoad()

		DispatchQueue.main.async {
			let upperContainerView = UIView()
			upperContainerView.translatesAutoresizingMaskIntoConstraints = false
			self.view.addSubview(upperContainerView)
			NSLayoutConstraint.activate([
				upperContainerView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 10),
				upperContainerView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -10),
				upperContainerView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 10),
				upperContainerView.heightAnchor.constraint(equalTo: self.view.heightAnchor, multiplier: 0.45)
				])
			self.add(viewController: self.upperViewController, to: upperContainerView)


			let lowerContainerView = UIView()
			lowerContainerView.translatesAutoresizingMaskIntoConstraints = false
			self.view.addSubview(lowerContainerView)
			NSLayoutConstraint.activate([
				lowerContainerView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 10),
				lowerContainerView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -10),
				lowerContainerView.topAnchor.constraint(equalTo: upperContainerView.bottomAnchor, constant: 10),
				lowerContainerView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -10),
				])
			self.add(viewController: self.lowerViewController, to: lowerContainerView)
		}
	}

	public func add(viewController: UIViewController, to containerView: UIView) {
		addChildViewController(viewController)
		viewController.view.translatesAutoresizingMaskIntoConstraints = false
		containerView.addSubview(viewController.view)
		NSLayoutConstraint.activate([
			viewController.view.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
			viewController.view.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
			viewController.view.topAnchor.constraint(equalTo: containerView.topAnchor),
			viewController.view.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
			])
		viewController.didMove(toParentViewController: self)
	}
}
