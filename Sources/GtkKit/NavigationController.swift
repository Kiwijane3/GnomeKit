//
//  NavigationController.swift
//  GtkMvc
//
//  Created by Jane Fraser on 20/10/20.
//

import Foundation
import Gtk

public class NavigationController: WidgetController {

	public var stack: StackProtocol {
		get {
			return widget as! StackProtocol;
		}
	}

	public var mainController: WidgetController? {
		get {
			return children.last
		}
	}

	public var mainIndex: Int {
		get {
			return children.count - 1;
		}
	}

	public var navigationHeaderSupplier: NavigationHeaderSupplier!;

	public override var headerbarSupplier: HeaderbarSupplier {
		get {
			return navigationHeaderSupplier;
		}
	}

	public init(withRoot rootController: WidgetController) {
		super.init()
		addChild(rootController)
		navigationHeaderSupplier = NavigationHeaderSupplier(for: self)
	}

	public override func loadWidget() {
		widget = Stack();
		for i in 0..<children.count {
			stack.addNamed(child: WidgetRef(children[i].widget.widget_ptr), name: "\(i)");
		}
		if mainIndex >= 0 {
			stack.setVisibleChildFull(name: "\(mainIndex)", transition: .none);
		}
		navigationHeaderSupplier.setChildren(children.map { (controller) -> HeaderbarSupplier in
			return controller.headerbarSupplier
		})
	}

	public override func show(_ controller: WidgetController) {
		push(controller);
	}

	public override func dismissMainChild() -> Bool {
		if children.count > 1 {
			pop();
			return true;
		} else {
			return false;
		}
	}

	public func push(_ controller: WidgetController) {
		addChild(controller);
		controller.widget.showAll()
		stack.addNamed(child: WidgetRef(mainChild!.widget.widget_ptr), name: "\(mainIndex)")
		stack.setVisibleChildFull(name: "\(mainIndex)", transition: .slideLeft)
		mainChild?.installedIn(self)
		stack.showAll()
		navigationHeaderSupplier.push(supplier: controller.headerbarSupplier)
		mainUpdated()
	}

	public func pop() {
		if children.count > 1 {
			// Animate the transition.
			stack.setVisibleChildFull(name: "\(mainIndex - 1)", transition: .slideRight);
			let removedController = children.popLast()!;
			stack.remove(widget: WidgetRef(removedController.widget.widget_ptr));
			removeChild(removedController)
			mainChild?.installedIn(self);
			stack.showAll();
			navigationHeaderSupplier.pop()
			mainUpdated();
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
		mainUpdated();
	}

	public override func mainUpdated() {
		parent?.mainUpdated();
	}

}

/// The NavigationHeaderSupplier wraps the HeaderBarItem of the NavigationController's main child in order to provide a back button.
public class NavigationHeaderSupplier: HeaderbarSupplier {

	public unowned var navigationController: NavigationController;

	public var children: [HeaderbarSupplier]

	public var supplier: HeaderbarSupplier? {
		get {
			return children.last
		}
	}

	public var showsBackButton: Bool {
		get {
			if let supplier = supplier {
				return navigationController.children.count > 1 && supplier.showsBackButton
			} else {
				return false
			}
		}
	}

	public var title: String? {
		get {
			return children.last?.title;
		}
	}

	public var subtitle: String? {
		get {
			return children.last?.subtitle;
		}
	}

	public var titleView: Widget? {
		get {
			return children.last?.titleView;
		}
	}

	public var startItemCount: Int {
		if let supplier = supplier {
			if showsBackButton {
				return supplier.startItemCount + 1;
			} else {
				return supplier.startItemCount
			}
		} else {
			return 0;
		}
	}

	public var endItemCount: Int {
		children.last?.endItemCount ?? 0;
	}

	public var onUpdate: ((HeaderField) -> Void)?

	public init(for navigationController: NavigationController) {
		self.navigationController = navigationController;
		children = []
	}

	public func push(supplier pushed: HeaderbarSupplier) {
		supplier?.onUpdate = nil
		children.append(pushed)
		supplier?.onUpdate = { [weak self] (field) in
			switch field {
				case .showsBackButton:
					self?.onUpdate?(.startItems)
				default:
					self?.onUpdate?(field)
			}
		}
	}

	public func pop() {
		supplier?.onUpdate = nil
		children.popLast()
		supplier?.onUpdate = { [weak self] (field) in
			switch field {
				case .showsBackButton:
					self?.onUpdate?(.startItems)
				default:
					self?.onUpdate?(field)
			}
		}
	}

	public func setChildren(_ suppliers: [HeaderbarSupplier]) {
		supplier?.onUpdate = nil
		children = suppliers
		supplier?.onUpdate
		supplier?.onUpdate = { [weak self] (field) in
			switch field {
				case .showsBackButton:
					self?.onUpdate?(.startItems)
				default:
					self?.onUpdate?(field)
			}
		}
	}

	public func startItem(at index: Int) -> BarItem {
		if showsBackButton {
			if index == 0 {
				return BarButtonItem(iconName: "go-previous", onClick: { [weak self] (button) in
					self?.navigationController.pop()
				})
			} else {
				return supplier!.startItem(at: index - 1);
			}
		} else {
			return supplier!.startItem(at: index);
		}
	}

	public func endItem(at index: Int) -> BarItem {
		return supplier!.endItem(at: index);
	}

}
