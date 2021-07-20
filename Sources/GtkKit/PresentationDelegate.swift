import Foundation
import Gtk

public protocol PresentationDelegate {

	/// Called when before the presentation container appears.
	func presentationWillBegin(_ presentation: PresentationController)

	/// Called after the presentation's container has appeared
	func presentationDidBegin(_ presentation: PresentationController)

	/// Called when the presen
	func presentationDidEnd(_ presentation: PresentationController)

}

public extension PresentationDelegate {

	public func presentationWillBegin(_ presentation: PresentationController) {}

	public func presentationDidBegin(_ presentation: PresentationController) {}

	public func presentationDidEnd(_ presentation: PresentationController) {}

}

public protocol WindowDelegate: PresentationDelegate  {

	func presentationDidBegin(_ presentation: PresentationController, withWindow window: Window)

	func presentationDidEnd(_ presentation: PresentationController, withWindow window: Window)

}

public extension WindowDelegate {

	public func presentationDidBegin(_ presentation: PresentationController, withWindow window: Window) {}

	public func presentationDidEnd(_ presentation: PresentationController, withWindow window: Window) {}

}
