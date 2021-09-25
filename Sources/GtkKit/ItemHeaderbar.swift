//
//  WindowController.swift
//  GtkMvc
//
//  Created by Jane Fraser on 19/10/20.
//

import Foundation
import GLibObject
import Gtk


/// The ItemHeaderBar is a headerbar that can make use of headerbars
open class ItemHeaderbar: HeaderBar {

	private var contextIdentifier = UUID()

	// The headerbar item is used by widget controllers to specify the items shown alongside them in the headerbar.
	public let item: HeaderbarItem?

	// The supplementary item is provided by container controls to display a control alongside the items specified in the headerbar item to provide container controls, like a back button.
	public var supplementaryItem: BarItem? {
		didSet {
			loadItems()
		}
	}

	public var switcherItem: BarItem? {
		didSet {
			loadTitleWidget()
		}
	}

	var supplementaryWidget: Widget?

	var switcherWidget: Widget?

	var startWidgets: [Widget] = []

	var endWidgets: [Widget] = []

	/// ItemHeaderbar binds the allocatedWidth property on widget to its own width request
	public init(item: HeaderbarItem?) {
		self.item = item
		super.init()
		load()
		becomeSwiftObj()
	}

	public required init(raw: UnsafeMutableRawPointer) {
		item = nil
		super.init(raw: raw)
	}

	public required init(retainingRaw raw: UnsafeMutableRawPointer) {
		item = nil
		super.init(retainingRaw: raw)

	}

	public func load() {
		guard let item = item else {
			return
		}
		removeAllChildren()
		loadTitle();
		loadSubtitle();
		loadTitleWidget();
		loadItems();
		item.onUpdate(for: contextIdentifier) { [weak self] (field) in
			debugPrint("Headerbar supplier field \(field) was updated, updated headerbar to reflect state")
			switch field {
			case .title:
				self?.loadTitle();
			case .subtitle:
				self?.loadSubtitle();
			case .titleView:
				self?.loadTitleWidget();
			case .startItems, .endItems:
				debugPrint("Loading items")
				self?.loadItems();
			default:
				break;
			}
			self?.showAll()
		}
		showAll();
	}

	public func loadTitle() {
		if title != item?.title {
			set(title: item?.title)
		}
		showAll()
	}

	public func loadSubtitle() {
		if subtitle != item?.subtitle {
			subtitle = item?.subtitle;
		}
	}

	public func loadTitleWidget() {
		switcherWidget = switcherItem?.getWidget(for: contextIdentifier)
		if let switcherWidget = switcherWidget {
			customTitle = WidgetRef(switcherWidget.widget_ptr)
		} else if let titleView = item?.titleView {
			customTitle = WidgetRef(titleView.widget_ptr);
		} else {
			customTitle = nil;
		}
	}

	public func loadItems() {
		removeAllChildren()
		supplementaryWidget = supplementaryItem?.getWidget(for: contextIdentifier)
		if let supplementaryWidget = supplementaryWidget {
			print("Supplementary widget: \(supplementaryWidget)")
			packStart(child: supplementaryWidget)
		}
		if let item = item {
			startWidgets = item.startItems.map() { (barItems) -> Widget in
				return barItems.getWidget(for: contextIdentifier)
			}
			for widget in startWidgets {
				packStart(child: widget);
			}
			endWidgets = item.endItems.map() { (barItems) -> Widget in
				return barItems.getWidget(for: contextIdentifier)
			}
			for widget in endWidgets {
				packEnd(child: widget);
			}
		}
		showAll()
	}

}
