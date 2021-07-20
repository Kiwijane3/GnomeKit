//
//  NavigationController.swift
//  GtkMvc
//
//  Created by Jane Fraser on 20/10/20.
//

import Foundation
import Gtk

public class NavigationController: WidgetController {

	public var stack: Stack {
		get {
			return widget as! Stack
		}
	}

	public override var mainChild: WidgetController? {
		get {
			return children.last
		}
	}

	public var mainIndex: Int {
		get {
			return children.count - 1;
		}
	}

	open override var supplementaryItem: BarItem? {
		if mainIndex == 0 {
			return nil
		} else {
			return BarButtonItem(iconName: "go-previous-symbolic") { [weak self] (_) in
				self?.pop()
			}
		}
	}

	public override init() {
		super.init()
	}

	public init(withRoot rootController: WidgetController) {
		super.init()

		addChild(rootController)
	}

	public override func loadWidget() {
		widget = Stack();
		for i in 0..<children.count {
			stack.addNamed(child: WidgetRef(children[i].widget.widget_ptr), name: "\(i)");
		}
		if mainIndex >= 0 {
			stack.setVisibleChildFull(name: "\(mainIndex)", transition: .none);
		}
	}

	public override func show(_ controller: WidgetController) {
		push(controller);
	}

	public func push(_ controller: WidgetController) {
		addChild(controller);
		controller.widget.showAll()
		stack.addNamed(child: controller.widget, name: "\(mainIndex)")
		stack.transitionType = .slideLeft
		stack.setVisible(child: controller.widget)
		mainChild?.installedIn(self)
		stack.showAll()
		headerNeedsRefresh()
	}

	public func pop() {
		if children.count > 1 {
			// Animate the transition.
			stack.transitionType = .slideRight
			let removedController = children.popLast()!
			removeChild(removedController)
			let removedChild = removedController.widget
			stack.setVisible(child: children[children.count - 1].widget, onComplete: { [weak stack] in
				stack?.remove(widget: removedChild)
				print("Cleaned up from pop")
			})
			mainChild?.installedIn(self)
			stack.showAll()
			headerNeedsRefresh()
		}
	}

	public func setRoot(_ controller: WidgetController) {
		if !children.isEmpty {
			let oldRoot = children.remove(at: 0);
			stack.remove(widget: WidgetRef(oldRoot.widget.widget_ptr));
			oldRoot.removedFromParent();
		}
		addChild(controller);
		stack.addNamed(child: WidgetRef(mainChild?.widget.widget_ptr), name: "\(mainIndex)");
		stack.setVisibleChildFull(name: "\(mainIndex)", transition: .none);
		stack.showAll();
		headerNeedsRefresh()
	}


}
