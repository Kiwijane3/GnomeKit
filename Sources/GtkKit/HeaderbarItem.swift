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

public class HeaderbarItem: Equatable, Hashable {
	
	/**
		A unique identifier for this `HeaderbarItem`
	*/
	public var uuid: UUID = UUID()

	/**
		The title to be displayed in the titlebar.
	*/
	public var title: String? = nil {
		didSet {
			updated(field: .title)
		}
	}
	
	/**
		The subtitle to be displayed in the titlebar.
	*/
	public var subtitle: String? = nil {
		didSet {
			updated(field: .subtitle)
		}
	}
	
	/**
		A widget to be presented in the center of the titlebar, in place of the title and subtitle.
	*/
	public var titleView: Widget? = nil {
		didSet {
			updated(field: .titleView)
		}
	}

	/**
		The `BarItem`s to be shown at the start of titlebar.
	*/
	public var startItems: [BarItem] = [] {
		didSet {
			updated(field: .startItems)
		}
	}
	
	/**
		A convenience alias of `startItems`
	*/
	public var leftItems: [BarItem] {
		get {
			return startItems
		}
		set {
			startItems = newValue
		}
	}
	
	/**
		The `BarItem`s to be shown at the end of the titlebar.
	*/
	public var endItems: [BarItem] = [] {
		didSet {
			updated(field: .endItems)
		}
	}
	
	/**
		A convenience alias of `endItems`
	*/
	public var rightItems: [BarItem] {
		get {
			return endItems
		}
		set {
			endItems = newValue
		}
	}
	
	/**
		Whether the supplementary item should be displayed alongside this item's contents. This is useful when the controller wants to prevent the user from exiting without using the controls it specifies.
	*/
	public var showsBackButton: Bool = true {
		didSet {
			updated(field: .showsBackButton)
		}
	}

	/**
		Handlers used to communicate updates to this item
	*/
	internal var updateHandlers = [(id: UUID, handler: (HeaderField) -> Void)]()
	
	/**
		The number of items to be displayed at the start of the titlebar
	*/
	public var startItemCount: Int {
		get {
			return startItems.count
		}
	}
	
	/**
		The number of items to be displayed at the start of the titlebar
	*/
	public var endItemCount: Int {
		get {
			return endItems.count
		}
	}

	public static func ==(a: HeaderbarItem, b: HeaderbarItem) -> Bool{
		return a.uuid == b.uuid
	}
	
	/**
		Subscribes to updates about this item.

		- Parameter contextIdentifier: The context identifier of the subscriber.
		- Parameter handler: The closure to be invoked when this item is updated.
	*/
	public func onUpdate(for contextIdentifier: UUID, _ handler: @escaping(HeaderField) -> Void) {
		updateHandlers.append((id: contextIdentifier, handler: handler))
	}

	/**
		Unsubscribes to updates about this item.

		- Parameter contextIdentifier: The context identifier of the subscriber that is requesting to be disconnected.
	*/
	public func disconnectUpdates(for contextIdentifier: UUID) {
		updateHandlers = updateHandlers.filter() { (entry) -> Bool in
			entry.id != contextIdentifier
		}
	}

	/**
		Notifies subscribers that the specified field of this item has been updated.

		- Parameter field: The field on this item that has been updated.
	*/
	internal func updated(field: HeaderField) {
		updateHandlers.forEach() { (entry) in
			entry.handler(field)
		}
	}

	public func hash(into hasher: inout Hasher) {
		hasher.combine(uuid)
	}
	
}

public protocol BarItem {
	
	/// Since the widget generated by a bar item may be displayed in multiple hierarchies, requiring multiple widgets, so a unique identifier for each context is supplied so that separate widgets can be provided.
	func getWidget(for contextIdentifier: UUID) -> Widget

}

/// A BarItemRegistry is designed to be used by barItems to store, update and retrieve widgets for each context in which the item is shown. This is most useful for showing overflow items in a bar at the bottom of the screen and in the titlebar at once.
public class BarItemRegistry<T: Widget> {

	public struct Entry {

		public var contextIdentifier: UUID

		public weak var widget: T?

		public init(for contextIdentifier: UUID, widget: T) {
			self.contextIdentifier = contextIdentifier
			self.widget = widget
		}

	}

	public var entries: [Entry] = []

	public func register(widget: T, for contextIdentifer: UUID) {
		entries.append(Entry(for: contextIdentifer, widget: widget))
	}

	public func retrieve(for contextIdentifier: UUID) -> T? {
		return entries.first(where: { (entry) -> Bool in
			return entry.contextIdentifier == contextIdentifier
	
		})?.widget
	}

	public func apply(_ handler: (T) -> Void) {
		entries = entries.filter() { (entry) -> Bool in
			return entry.widget != nil
		}
		// We can force unwrap here because
		entries.forEach() { (entry) in
			handler(entry.widget!)
		}
	}

}

public class BarButtonItem: BarItem {
	
	public var title: String? {
		didSet {
			registry.apply(loadTitle(_:))
		}
	}
	
	public var image: Image? {
		didSet {
			registry.apply(loadImage(_:))
		}
	}
	
	public var iconName: String? {
		didSet {
			if iconName != oldValue {
				iconImage = Image(iconName: iconName, size: .button)
			}
		}
	}
	
	public var style: ButtonStyle {
		didSet {
			registry.apply(loadStyle(_:))
		}
	}

	public var onClick: ((ButtonRef) -> Void)?

	public var active: Bool = true {
		didSet {
			registry.apply(loadActive(_:))
		}
	}

	public var menu: ActionMenu?
	
	public var menuProvider: (() -> ActionMenu)?

	internal var registry = BarItemRegistry<Button>()

	internal var iconImage: Image? {
		didSet {
			registry.apply(loadImage(_:))
		}
	}

	public init(title: String? = nil, image: Image? = nil, iconName: String? = nil, style: ButtonStyle = .default, onClick: ((ButtonProtocol) -> Void)? = nil, menu: ActionMenu? = nil, menuProvider: (() -> ActionMenu)? = nil) {
		self.title = title
		self.image = image
		self.iconName = iconName
		if let iconName = iconName {
			iconImage = Image(iconName: iconName, size: .button)
		}
		self.style = style
		self.onClick = onClick
		self.menu = menu
		self.menuProvider = menuProvider
	}
	
	public convenience init(title: String? = nil, image: Image? = nil, iconName: String? = nil, style: ButtonStyle = .default, onClick: @escaping (() -> Void)) {
		self.init(title: title, image: image, iconName: iconName, style: style, onClick: { (_) in
			onClick()
		})
	}

	public func getWidget(for contextIdentifier: UUID) -> Widget {
		if let button = registry.retrieve(for: contextIdentifier) {
			return button
		} else {
			let button = Button()
			loadTitle(button)
			loadImage(button)
			loadStyle(button)
			loadActive(button)
			loadHandler(button)
			registry.register(widget: button, for: contextIdentifier)
			return button
		}
	}

	public func loadTitle(_ button: Button) {
		button.label = title
	}
	
	public func loadImage(_ button: Button) {
		if let image = image {
			// Buttons seem to have an undefined behaviour where only certain types of items, which excludes those generated from files, cannot be added via set(image)
			// They should instead be added directly.
			//button.styleContext.addClass(className: "image-button")
			button.add(widget: image)
		}
		if let iconImage = iconImage {
			button.set(image: iconImage)
		} else {
			button.image = nil
		}
	}

	public func loadActive(_ button: Button) {
		button.sensitive = active
		if style == .recommended, active == true {
			button.grabDefault()
		}
	}
	
	public func loadStyle(_ button: Button) {
		if style != .destructive {
			button.styleContext.removeClass(className: "destructive-action")
		}
		if style != .recommended {
			button.styleContext.removeClass(className: "suggested-action")
			button.canDefault = false
			button.receivesDefault = false
		}
		if style == .destructive {
			button.styleContext.addClass(className: "destructive-action")
		}
		if style == .recommended {
			button.styleContext.addClass(className: "suggested-action")
			button.canDefault = true
			button.receivesDefault = true
		}
	}

	public func loadHandler(_ button: Button) {
		button.onClicked { [weak self] (button) in
				self?.clicked(button)
			}
	}

	public func clicked(_ button: ButtonRef) {
		if let menu = menu {
			menu.present(from: button)
		} else if let menuProvider = menuProvider {
			let menu = menuProvider()
			menu.present(from: button)
		} else if let onClick = onClick {
			onClick(button)
		}
	}
	
}

public class CustomWidgetBarItem<T: Widget>: BarItem {

	internal var registry = BarItemRegistry<T>()

	internal let generator: () -> T

	public init(generator: @escaping () -> T) {
		self.generator = generator
	}

	public func getWidget(for contextIdentifier: UUID) -> Widget {
		if let widget = registry.retrieve(for: contextIdentifier) {
			return widget
		} else {
			let widget = generator()
			registry.register(widget: widget, for: contextIdentifier)
			return widget
		}
	}

	public func update(_ handler: (T) -> Void) {
		registry.apply(handler)
	}

}

public enum ButtonStyle {
	case `default`
	case cancel
	case destructive
	case recommended
}
