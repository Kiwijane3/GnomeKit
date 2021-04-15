//
//  ToolbarItem.swift
//  GtkMvc
//
//  Created by Jane Fraser on 19/10/20.
//

import Foundation
import Gtk

public enum HeaderField {
	case title
	case subtitle
	case titleView
	case startItems
	case endItems
	case showsBackButton
}

public protocol HeaderbarSupplier: class {
	
	var title: String? {
		get
	}
	
	var subtitle: String? {
		get
	}
	
	var titleView: Widget? {
		get
	}
	
	var startItemCount: Int {
		get
	}
	
	var endItemCount: Int {
		get
	}
	
	var showsBackButton: Bool {
		get
	}
	
	var onUpdate: ((HeaderField) -> Void)? {
		get
		set
	}
	
	func startItem(at index: Int) -> BarItem;
	
	func endItem(at index: Int) -> BarItem;
	
}

public class HeaderbarItem: HeaderbarSupplier {
	
	
	public var title: String? = nil {
		didSet {
			print("Set title to \(title)")
			onUpdate?(.title);
		}
	}
	
	public var subtitle: String? = nil {
		didSet {
			onUpdate?(.subtitle);
		}
	}
	
	public var titleView: Widget? = nil {
		didSet {
			onUpdate?(.titleView);
		}
	}
	
	public var startItems: [BarItem] = [] {
		didSet {
			onUpdate?(.startItems)
		}
	}
	
	public var leftItems: [BarItem] {
		get {
			return startItems;
		}
		set {
			startItems = newValue;
		}
	}
	
	public var endItems: [BarItem] = [] {
		didSet {
			onUpdate?(.endItems);
		}
	}
	
	public var rightItems: [BarItem] {
		get {
			return endItems;
		}
		set {
			endItems = newValue;
		}
	}
	
	public var showsBackButton: Bool = true {
		didSet {
			onUpdate?(.showsBackButton);
		}
	}
	
	public var onUpdate: ((HeaderField) -> Void)?;
	
	public var startItemCount: Int {
		get {
			return startItems.count;
		}
	}
	
	public var endItemCount: Int {
		get {
			return endItems.count;
		}
	}
	
	public func startItem(at index: Int) -> BarItem {
		return startItems[index];
	}
	
	public func endItem(at index: Int) -> BarItem {
		return endItems[index];
	}
	
}

public protocol BarItem {
	
	func generate() -> Widget;
	
}

public class BarButtonItem: BarItem{
	
	public var title: String? {
		didSet {
			loadTitle();
		}
	}
	
	public var iconName: String? {
		didSet {
			loadIcon();
		}
	}
	
	public var onClick: ((ButtonProtocol) -> Void)? {
		didSet {
			loadHandler();
		}
	}
	
	internal var button: Button?;
	
	internal var signalId: Int?;
	
	public init(title: String? = nil, iconName: String? = nil, onClick: ((ButtonProtocol) -> Void)? = nil) {
		self.title = title;
		self.iconName = iconName;
		self.onClick = onClick;
	}
	
	public func generate() -> Widget {
		if let button = button {
			return button;
		} else {
			button = Button();
			loadTitle();
			loadIcon();
			loadHandler();
			return button!;
		}
	}
	
	public func loadTitle() {
		button?.label = title;
	}
	
	public func loadIcon() {
		if let iconName = iconName {
			button?.set(image: Image(iconName: iconName, size: .button));
		} else {
			button?.image = nil;
		}
	}
	
	public func loadHandler() {
		if let onClick = onClick {
			signalId = button?.onClicked(handler: { (button) in
				onClick(button)
			})
		} else {
			if let signalId = signalId {
				button?.signalHandlerDisconnect(handlerID: signalId);
				self.signalId = nil;
			}
		}
	}
	
}
