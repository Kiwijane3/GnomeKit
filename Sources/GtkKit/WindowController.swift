//
//  WindowController.swift
//  GtkMvc
//
//  Created by Jane Fraser on 19/10/20.
//

import Foundation
import Gtk

open class WindowController: PresentationController {
	
	/**
		The `Window` managed by this controller.
	*/
	public var window: Window {
		get {
			return container as! Window;
		}
	}
	
	/**
		The `delegate` of this controller as a `WindowDelegate`, if it conforms to that protocol.
	*/
	public var windowDelegate: WindowDelegate? {
		get {
			return delegate as? WindowDelegate
		}
	}

	public override var canShowHeaderBar: Bool {
		return true
	}
	
	public override init() {
		super.init()
		showsHeaderbar = true
	}
	
	open override func showHeaderbar() {
		window.set(titlebar: headerbarStack)
	}
	
	open override func hideHeaderbar() {
		window.set(titlebar: nil)
	}
	
	open override func beginPresentation() {
		delegate?.presentationWillBegin(self)
		if canShowHeaderBar, showsHeaderbar {
			showHeaderbar()
		}
		refreshHeader()
		container.showAll()
		presentedController?.presentingController = self
		windowDelegate?.presentationDidBegin(self, withWindow: window)
		delegate?.presentationDidBegin(self)
	}

	open override func endPresentation() {
		window.close()
	}
	
}


