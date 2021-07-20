import Foundation
import Gtk

public protocol PresentationDelegate {

	func presentationDidBegin(_ presentation: PresentationController)

	func presentationDidEnd(_ presentation: PresentationController)

}

public extension PresentationDelegate {

	public func presentationDidBegin(_ presentation: PresentationController) {}

	public func presentationDidEnd(_ presentation: PresentationController) {}

}

public protocol WindowDelegate: PresentationDelegate {

	func presentationDidBegin(_ presentation: PresentationController, withWindow window: Window)

	func presentationDidEnd(_ presentation: PresentationController, withWindow window: Window)

}

public extension WindowDelegate {

	public func presentationDidBegin(_ presentation: PresentationController, withWindow window: Window) {}

	public func presentationDidEnd(_ presentation: PresentationController, withWindow window: Window) {}

}
