//
//  TabItem.swift
//  GtkMvc
//
//  Created by Jane Fraser on 21/10/20.
//

import Foundation
import Gtk
import CGLib
import GLibObject

/**
	A `TabController` presents several child controllers alongside each other, and allows the user to switch between them using a switched.
*/
open class TabController: WidgetController {

	/**
		The `Stack` used by this controller to display its children.
	*/
	public var stack: Stack {
		get {
			return widget as! Stack;
		}
	}

	public override var mainChild: WidgetController? {
		get {
			for child in children {
				if child.widget.ptr == stack.visibleChild.ptr {
					return child
				}
			}
			return nil
		}
	}

	/**
		Initialises a `TabController` with no children.
	*/
	public override init() {
		super.init();
	}

	/**
		Initialises a `TabController` containing `children`
	*/
	public init(children: [WidgetController]) {
		super.init();
		self.children = children;
		for child in children {
			child.parent = self;
		}
	}

	public override func loadWidget() {
		widget = Stack()
		for i in 0..<children.count {
			addToStack(children[i], at: i)
		}
		stack.transitionType = .overLeftRight
		headerSwitcherItem = CustomWidgetBarItem() { [unowned self] () -> StackSwitcher in
			let switcher = StackSwitcher()
			switcher.set(stack: stack)
			return switcher
		}

	}

	/**
		Adds `controller` as the last child of this controller
	*/
	public override func addChild(_ controller: WidgetController) {
		addChild(controller, at: children.count);
	}

	/**
		Adds `controller` as a child of this controller at `index`

		- Parameter controller: The controller to be added as a child
		- Parameter index: The index that the child should be added at
	*/
	public func addChild(_ controller: WidgetController, at index: Int) {
		children.insert(controller, at: index);
		controller.parent = self;
		addToStack(controller, at: index);
	}

	/**
		Updates the positions of the child controllers' widgets in the stack to represent the controller's positions in the `children` array.
	*/
	internal func loadPositions() {
		for i in 0..<children.count {
			let child = children[i]
			stack.set(child: child.widget, property: PropertyName.init("position"), value: Value(i))
		}
	}

	/**
		Adds the widget of `controller` to the stack at `index`
	*/
	internal func addToStack(_ controller: WidgetController, at index: Int) {
		let widgetRef = controller.widget
		stack.addTitled(child: widgetRef, name: "", title: controller.tabItem.title)
		loadItem(at: index);
		controller.tabItem.onUpdate = { [weak self] in
			self?.loadItem(at: index);
		}
		widget.showAll();
		// This is supposed to detect when the stack switcher changes the view.
		widgetRef.onShow(handler: { [weak self] (_) in
			self?.presenterShouldRefresh()
		})
		loadPositions()
		controller.installedIn(self);
	}


	/**
		Moves `controller` to `index`
	*/
	public func move(_ controller: WidgetController, to index: Int) {
		if let currentIndex = children.firstIndex(where: { (element) -> Bool in
			return element === controller;
		}) {
			children.remove(at: currentIndex);
			children.insert(controller, at: index);
			controller.tabItem.onUpdate = { [weak self] in
				self?.loadItem(at: index);
			}
			loadPositions()
		}
	}

	public func remove(_ controller: WidgetController) {
		if let currentIndex = children.firstIndex(where: { (element) -> Bool in
			return element === controller;
		}) {
			let removedMain = controller === mainChild;
			children.remove(at: currentIndex);
			stack.remove(widget: WidgetRef(controller.widget.widget_ptr));
			controller.tabItem.onUpdate = nil;
			controller.removedFromParent();
			controller.parent = nil
			if removedMain {
				mainUpdated();
			}
			loadPositions()
		}
	}

	/**
		Updates the `title` and `icon-name` child properties of the widget of the controller at `index` to reflect the controllers' `tabItem`
	*/
	internal func loadItem(at index: Int) {
		let widget = children[index].widget
		let item = children[index].tabItem
		if let title = item.title {
			stack.set(child: widget, property: PropertyName.init("title"), value: Value(title))
		}
		if let iconName = item.iconName {
			stack.set(child: widget, property: PropertyName.init("icon-name"), value: Value(iconName))
		}
	}

}

public class TabItem {

	/**
		The title to be displayed in the switcher
	*/
	public var title: String? {
		didSet {
			onUpdate?();
		}
	}

	/**
		The name of the item to be displayed in the switcher
	*/
	public var iconName: String? {
		didSet {
			onUpdate?();
		}
	}

	public var onUpdate: (() -> Void)?;

}
