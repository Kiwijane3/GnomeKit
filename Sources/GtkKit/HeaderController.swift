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
		print("loadeHeader")
		headerBar.removeAllChildren()
		supplier?.onUpdate = nil;
		supplier = mainChild?.headerbarSupplier;
		print("Loading header with item \(supplier), had title \(supplier?.title)")
		loadTitle();
		loadSubtitle();
		loadTitleView();
		loadItems();
		supplier?.onUpdate = { [weak self](field) in
			print("On update")
			switch field {
			case .title:
				self?.loadTitle();
			case .subtitle:
				self?.loadSubtitle();
			case .titleView:
				self?.loadTitleView();
			case .startItems, .endItems:
				self?.loadItems();
			default:
				break;
			}
		}
		headerBar.showAll();
	}
	
	public func loadTitle() {
		print("Loading title \(supplier?.title) from \(supplier)")
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
				headerBar.packStart(child: WidgetRef(widget.widget_ptr));
			}
			for i in 0..<supplier.endItemCount {
				let widget = supplier.startItem(at: i).generate();
				headerBar.packEnd(child: WidgetRef(widget.widget_ptr));
			}
		}
	}
	
}
