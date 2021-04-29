//
//  WindowController.swift
//  GtkMvc
//
//  Created by Jane Fraser on 19/10/20.
//

import Foundation
import Gtk

open class WindowController: HeaderController {
	
	public var application: Application;
	
	public var hasHeaderbar: Bool = true;
	
	public override var mainChild: WidgetController? {
		get {
			return children.last
		}
	}
	
	public var window: WindowProtocol {
		get {
			return widget as! WindowProtocol;
		}
	}
	
	public init(application: Application) {
		self.application = application;
		super.init();
		headerBar.showCloseButton = true
	}
	
	public override func loadWidget() {
		widget = ApplicationWindow(application: application);
		// Install the headerbar if needed.
		if hasHeaderbar {
			window.set(titlebar: headerBar);
		}
		window.setDefaultSize(width: 1024, height: 680)
		window.showAll()
	}
	
	public override func show(_ controller: WidgetController) {
		addChild(controller);
		window.add(widget: controller.widget);
		window.showAll();
		controller.installedIn(self);
		mainUpdated();
	}
	
	/// WindowController allows controllers to be shown over each other and dismissed, but will not dismiss its only child.
	public override func dismissMainChild() -> Bool {
		if children.count > 1 {
			let removedController = children.popLast()!;
			removedController.removedFromParent();
			let mainController = children.last!;
			window.add(widget: mainController.widget);
			mainController.installedIn(self);
			window.showAll();
			return true;
		} else {
			return false;
		}
	}
	
}
