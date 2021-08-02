import Foundation
import Gtk

public protocol PresentationDelegate {

	/**
		Called just before `presentationController` presents its contents
	*/
	func presentationWillBegin(_ presentationController: PresentationController)

	/**
		Called after `presentationController` presents its contents
	*/
	func presentationDidBegin(_ presentationController: PresentationController)

	/**
		Called after `presentationController` stops presenting its contents
	*/
	func presentationDidEnd(_ presentationController: PresentationController)

}

public extension PresentationDelegate {

	public func presentationWillBegin(_ presentation: PresentationController) {}

	public func presentationDidBegin(_ presentation: PresentationController) {}

	public func presentationDidEnd(_ presentation: PresentationController) {}

}

public protocol WindowDelegate: PresentationDelegate  {

	/**
		Called just before `presentationController` presents its contents

		- Parameter window: The `Window` used by `presentationController`
	*/
	func presentationDidBegin(_ presentationController: PresentationController, withWindow window: Window)

	/**
		Called after `presentationController` stops presenting its contents

		- Parameter window: The `Window` that was used by `presentationController`
	*/
	func presentationDidEnd(_ presentationController: PresentationController, withWindow window: Window)

}

public extension WindowDelegate {

	public func presentationDidBegin(_ presentation: PresentationController, withWindow window: Window) {}

	public func presentationDidEnd(_ presentation: PresentationController, withWindow window: Window) {}

}
