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

open class TabController: WidgetController {

	public var switcher: StackSwitcher?;

	public var stack: Stack {
		get {
			return widget as! Stack;
		}
	}

	public var tabHeaderbarSupplier: TabHeaderbarSupplier!;

	public override var headerbarSupplier: HeaderbarSupplier {
		get {
			return tabHeaderbarSupplier;
		}
	}

	public var mainIndex: Int {
		get {
			if let mainName = stack.visibleChildName {
				return Int(mainName) ?? -1;
			} else {
				return -1;
			}
		}
	}

	public override var mainChild: WidgetController? {
		get {
			if mainIndex > -1 {
				return children[mainIndex];
			} else {
				return nil;
			}
		}
	}

	public override init() {
		super.init();
		tabHeaderbarSupplier = TabHeaderbarSupplier(tabController: self);
	}

	public init(children: [WidgetController]) {
		super.init();
		self.children = children;
		tabHeaderbarSupplier = TabHeaderbarSupplier(tabController: self);
		for child in children {
			child.parent = self;
		}
	}

	public override func loadWidget() {
		widget = Stack();
		switcher = StackSwitcher();
		switcher?.set(stack: stack);
		for i in 0..<children.count {
			addToStack(children[i], at: i);
		}
		if children.count > 0 {
			stack.setVisibleChild(name: "\(mainIndex)");
		}
	}

	public override func addChild(_ controller: WidgetController) {
		addChild(controller, at: children.count);
	}

	public func addChild(_ controller: WidgetController, at index: Int) {
		children.insert(controller, at: index);
		controller.parent = self;
		addToStack(controller, at: index);
	}

	internal func addToStack(_ controller: WidgetController, at index: Int) {
		let widgetRef = controller.widget
		stack.add(widget: widget);
		loadPositions()
		loadItem(at: index);
		controller.tabItem.onUpdate = { [weak self] in
			self?.loadItem(at: index);
		}
		widget.showAll();
		// This is supposed to detect when the stack switcher changes the view, but I'm not sure if it will work. There isn't an explicit signal for this.
		widgetRef.onShow(handler: { [weak self] (_) in
			self?.mainUpdated()
		})
		controller.installedIn(self);
	}

	public func move(_ controller: WidgetController, to index: Int) {
		if let currentIndex = children.firstIndex(where: { (element) -> Bool in
			return element === controller;
		}) {
			children.remove(at: currentIndex);
			children.insert(controller, at: index);
			loadPositions()
			controller.tabItem.onUpdate = { [weak self] in
				self?.loadItem(at: index);
			}
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
		}
	}

	public func loadPositions() {
		for index in 0..<children.count {
			let widget = children[index].widget
			stack.set(child: widget, property: PropertyName.init("name"), value: "\(index)")
			stack.set(child: widget, property: PropertyName.init("position"), value: index)
		}
	}

	public func loadItem(at index: Int) {
		let widget = children[index].widget
		let item = children[index].tabItem;
		stack.set(child: widget, property: PropertyName.init("title"), value: item.title)
		stack.set(child: widget, property: PropertyName.init("icon-name"), value: item.iconName)
	}

	public override func mainUpdated() {
		tabHeaderbarSupplier.itemUpdated();
		parent?.mainUpdated();
	}

}

public class TabItem {

	public var title: String? {
		didSet {
			onUpdate?();
		}
	}

	public var iconName: String? {
		didSet {
			onUpdate?();
		}
	}

	public var onUpdate: (() -> Void)?;

}

public class TabHeaderbarSupplier: HeaderbarSupplier {

	public unowned var tabController: TabController;

	public var item: HeaderbarItem?;

	public var title: String? {
		get {
			return item?.title;
		}
	}

	public var subtitle: String? {
		get {
			return item?.subtitle;
		}
	}

	public var titleView: Widget? {
		return tabController.switcher;
	}

	public var startItemCount: Int {
		get {
			return item?.startItemCount ?? 0;
		}
	}

	public var endItemCount: Int {
		get {
			return item?.endItemCount ?? 0;
		}
	}

	public var showsBackButton: Bool {
		return item?.showsBackButton ?? false
	}

	public var onUpdate: ((HeaderField) -> Void)?;

	public init(tabController: TabController) {
		self.tabController = tabController;
		itemUpdated();
	}

	public func itemUpdated() {
		item?.onUpdate = nil;
		item = tabController.mainChild?.headerbarItem;
		item?.onUpdate = { [weak self] (field) in
			self?.onUpdate?(field);
		}
	}

	public func startItem(at index: Int) -> BarItem {
		return item!.startItem(at: index);
	}

	public func endItem(at index: Int) -> BarItem {
		return item!.endItem(at: index);
	}

}
