//
//  WindowController.swift
//  GtkMvc
//
//  Created by Jane Fraser on 19/10/20.
//

import Foundation
import Gtk

open class WindowController: PresentationController {
	
	public var window: Window {
		get {
			return container as! Window;
		}
	}
	
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
		if canShowHeaderBar, showsHeaderbar {
			showHeaderbar()
		}
		refreshHeader()
		container.showAll()
		presentedController?.presentingController = self
		delegate?.presentationDidBegin(self)
		windowDelegate?.presentationDidBegin(self, withWindow: window)
		window.onUnrealize() { [weak self] (_) in
			guard let strongSelf = self else {
				return
			}
			strongSelf.delegate?.presentationDidEnd(strongSelf)
			strongSelf.windowDelegate?.presentationDidEnd(strongSelf, withWindow: strongSelf.window)
		}
	}

	open override func endPresentation() {
		window.close()
		delegate?.presentationDidEnd(self)
		windowDelegate?.presentationDidEnd(self, withWindow: window)
	}
	
}


