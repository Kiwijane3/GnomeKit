//
//  WindowController.swift
//  GtkMvc
//
//  Created by Jane Fraser on 19/10/20.
//

import Foundation
import Gtk

/// HeaderController is the base class for WidgetControllers that manage a HeaderBar. This includes window controllers and dialog controllers
public class HeaderController: WidgetController {
	
	public var headerBar: HeaderBar;
	
	public var supplier: HeaderbarSupplier?;
	
	public override init() {
		headerBar = HeaderBar();
		super.init();
	}
	
	public override func mainUpdated() {
		loadHeader();
		parent?.mainUpdated();
	}
	
	public func loadHeader() {
		headerBar.removeAllChildren()
		supplier?.onUpdate = nil;
		supplier = mainChild?.headerbarSupplier;
		loadTitle();
		loadSubtitle();
		loadTitleView();
		loadItems();
		supplier?.onUpdate = { [weak self](field) in
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
		}
		headerBar.showAll();
	}
	
	public func loadTitle() {
		if headerBar.title != supplier?.title {
			headerBar.title = supplier?.title
		}
	}
	
	public func loadSubtitle() {
		if headerBar.subtitle != supplier?.subtitle {
			headerBar.subtitle = supplier?.subtitle;
		}
	}
	
	public func loadTitleView() {
		if let titleView = supplier?.titleView {
			headerBar.customTitle = WidgetRef(titleView.widget_ptr);
		} else {
			headerBar.customTitle = nil;
		}
	}
	
	public func loadItems() {
		headerBar.removeAllChildren()
		if let supplier = supplier {
			for i in 0..<supplier.startItemCount {
				let widget = supplier.startItem(at: i).generate();
				headerBar.packStart(child: widget);
			}
			for i in 0..<supplier.endItemCount {
				let widget = supplier.endItem(at: i).generate();
				headerBar.packEnd(child: widget);
			}
		}
	}
	
}
