//
//  WindowController.swift
//  GtkMvc
//
//  Created by Jane Fraser on 19/10/20.
//

import Foundation
import Gtk

/// The ItemHeaderBar is a headerbar that is extended
open class ItemHeaderbar: HeaderBar {

	// The headerbar item is used by widget controllers to specify the items shown alongside them in the headerbar.
	public var item: HeaderbarItem? {
		didSet {
			oldValue?.onUpdate = nil
			loadItems()
		}
	}

	// The supplementary item is provided by container controls to display a control alongside the items specified in the headerbar item to provide container controls, like a back button.
	public var supplementaryItem: BarItem? {
		didSet {
			loadItems()
		}
	}

	public init(item: HeaderbarItem) {
		self.item = item
		super.init()
		load()
		becomeSwiftObj()
	}

	public required init(raw: UnsafeMutableRawPointer) {
		super.init(raw: raw)
	}

	public required init(retainingRaw raw: UnsafeMutableRawPointer) {
		super.init(retainingRaw: raw)
	}

	public func load() {
		guard let item = item else {
			return
		}
		removeAllChildren()
		loadTitle();
		loadSubtitle();
		loadTitleView();
		loadItems();
		item.onUpdate = { [weak self] (field) in
			debugPrint("Headerbar supplier field \(field) was updated, updated headerbar to reflect state")
			switch field {
			case .title:
				self?.loadTitle();
			case .subtitle:
				self?.loadSubtitle();
			case .titleView:
				self?.loadTitleView();
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
		print("Loading title")
		if title != item?.title {
			set(title: item?.title)
			print("Loaded title \(title) on \(ObjectIdentifier(self))")
		}
		showAll()
	}

	public func loadSubtitle() {
		if subtitle != item?.subtitle {
			subtitle = item?.subtitle;
		}
	}

	public func loadTitleView() {
		if let titleView = item?.titleView {
			customTitle = WidgetRef(titleView.widget_ptr);
		} else {
			customTitle = nil;
		}
	}

	public func loadItems() {
		removeAllChildren()
		if let supplementaryWidget = supplementaryItem?.getWidget() {
			print("Supplementary widget: \(supplementaryWidget)")
			packStart(child: supplementaryWidget)
		}
		if let item = item {
			for barItem in item.startItems {
				let widget = barItem.getWidget();
				packStart(child: widget);
			}
			for barItem in item.endItems {
				let widget = barItem.getWidget();
				packEnd(child: widget);
			}
		}
		showAll()
	}

}
