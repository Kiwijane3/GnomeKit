import Foundation
import Gtk

// A sectioned widget is the base for widgets that display several vertically arranged containers, possibly with headers.
public class SectionedWidget<S: Hashable, I: Hashable>: ScrolledWindow, SectionedModelDelegate {

	var stack: Stack

	var box: Box

	var placeholder: Widget?

	/**
		The `SectionedModel` used to populate this widget
	*/
	public var model: SectionedModel<S, I>? {
		didSet {
			oldValue?.delegate = nil
			model?.delegate = self
		}
	}

	// The containing boxes for each section. Holds the content container and header.
	var sectionBoxMap = [S: Box]()
	
	// The container for each section
	var sectionContainerMap = [S: Container]()
	
	// The header for each section
	var sectionHeaderMap = [S: Widget]()
	
	private var widgetCreator: ((I) -> Widget)?
	
	private var activationHandler: ((Int, Int) -> Void)?

	private var itemActivationHandler: ((S, I) -> Void)?

	/**
		Creates a new `SectionedWidget`
	*/
	public init() {
		stack = Stack()
		box = Box(orientation: .vertical, spacing: 8)
		super.init(hadjustment: nil as Adjustment?, vadjustment: nil as Adjustment?)
		add(widget: stack)
		stack.transitionType = .crossfade
		stack.add(widget: box)
		box.showAll()
		box.valign = .start
		box.marginTop = 8
		box.marginBottom = 8
		box.marginStart = 8
		marginEnd = 8
		box.halign = .fill
		propagateNaturalWidth = true
		setup()
	}
	
	public required init(raw: UnsafeMutableRawPointer) {
		stack = Stack()
		box = Box(orientation: .vertical, spacing: 8)
		super.init(raw: raw)
		add(widget: stack)
		stack.transitionType = .crossfade
		stack.add(widget: box)
		box.valign = .start
		box.showAll()
		box.marginTop = 8
		box.marginBottom = 8
		box.marginStart = 8
		box.marginEnd = 8
		box.halign = .fill
		propagateNaturalWidth = true
		setup()
	}
	
	public required init(retainingRaw raw: UnsafeMutableRawPointer) {
		stack = Stack()
		box = Box(orientation: .vertical, spacing: 8)
		super.init(retainingRaw: raw)
		add(widget: stack)
		stack.transitionType = .crossfade
		stack.add(widget: box)
		box.valign = .start
		box.showAll()
		box.marginTop = 8
		box.marginBottom = 8
		box.marginStart = 8
		box.marginEnd = 8
		box.halign = .fill
		propagateNaturalWidth = true
		setup()
	}

	public func setup() {

	}
	
	/**
		Sets the handler for creating widgets

		- Parameter item: The item to create a widget for
	*/
	public func onCreateWidget(_ handler: @escaping (_ item: I) -> Widget) {
		widgetCreator = handler
	}
	
	/**
		Sets the handler for responding to element activation

		- Parameter sectionIndex: The index of the section the activation occurs in

		- Parameter itemIndex: The index of the item that was activated
	*/
	public func onRowActivated(_ handler: @escaping (_ sectionIndex: Int, _ itemIndex: Int) -> Void) {
		activationHandler = handler
	}

	/**
		Sets the handler for responding to element activation

		- Parameter section: The identifier for the section in which the activation occurred

		- Parameter item: The identifier for the item that was activated
	*/
	public func onRowActivated(_ handler: @escaping (_ section: S, _ item: I) -> Void) {
		itemActivationHandler = handler
	}

	/**
		Sets a placeholder `Widget` to be displayed when no items are being displayed
	*/
	public func setPlaceholder(to placeholder: Widget) {
		if let currentPlaceholder = self.placeholder {
			stack.remove(widget: currentPlaceholder)
		}
		self.placeholder = placeholder
		stack.add(widget: placeholder)
		stack.showAll()
		if model?.isEmpty ?? true {
			stack.setVisible(child: placeholder)
			print("Making placeholder visible")
		}
	}

	/**
		Removes the placeholder widget
	*/
	public func removePlaceholder() {
		guard let placeholder = placeholder else {
			return
		}
		stack.remove(widget: placeholder)
	}

	public func sectionedModel(addedSection section: AnyHashable, at index: Int) {
	    guard let section = section as? S else {
	    	return	
	    }
	    let sectionBox = Box(orientation: .vertical, spacing: 8)
	    sectionBoxMap[section] = sectionBox
	    if let header = generateHeader(for: section) {
	    	sectionBox.packStart(child: header, expand: false, fill: false, padding: 0)
	    	sectionHeaderMap[section] = header
	    }
	    let container = generateContainer(for: section)
	    sectionBox.packStart(child: container, expand: true, fill: true, padding: 0)
	    // Setup activation
		setupActivation(container: container, section: section)
		sectionContainerMap[section] = container
	    // TODO: Setup activation handling for the box.
	    box.packStart(child: sectionBox, expand: false, fill: false, padding: 0)
	    box.reorder(child: sectionBox, position: index)
	    sectionBox.showAll()
	}
	
	public func sectionedModel(removedSection section: AnyHashable, at index: Int) {
	    guard let section = section as? S else {
	    	return
	    }
	    if let sectionBox = sectionBoxMap[section] {
	    	box.remove(widget: sectionBox)
	    	sectionBoxMap[section] = nil
	    }
	    sectionHeaderMap[section] = nil
	    sectionContainerMap[section] = nil
	} 
	
	public func sectionedModel(addedItem item: Any, at index: Int, in section: AnyHashable) {
		guard let section = section as? S, let item = item as? I else {
			return
		}
		let widget = widgetCreator?(item) ?? Box(orientation: .horizontal, spacing: 8)
		let container = sectionContainerMap[section]
		// Sectioned models currently accepts section containers that are listboxes or flowboxes. These are handled separately, since their insert methods aren't inherited from a common ancestor, despite similar signature and function.
		insert(widget: widget, into: container, at: index)
		widget.showAll()
	}
	
	public func sectionedModel(removedItem item: Any, at index: Int, in section: AnyHashable) {
		guard let section = section as? S else {
			return
		}
		let container = sectionContainerMap[section]
		remove(widgetAt: index, from: container)
	}

	/**
		Connects a handler to `container` for processing activation for processing activation events

		- Parameter section: The section identifier for `container`
	*/
	open func setupActivation(container: Container, section: S) {
		if let listBox = container as? ListBox {
	    		listBox.onRowActivated(handler: { [weak self, weak model] (listBox, row) in
	    			self?.onActivate(at: row.index, in: section)
	    		})
		}
		if let flowBox = container as? FlowBox {
			flowBox.onChildActivated { [weak self] (flowBox, child) in
				self?.onActivate(at: child.index, in: section)
			}
		}
	}

	/**
		Invokes `activationHandler` and `itemActivationHandler` for an activation of the item at `index` in `section`
	*/
	public func onActivate(at index: Int, in section: S) {
		if let sectionIndex = model?.indexOf(section: section), let itemIndex = model?.targetIndex(forItemAtRealIndex: index, in: section) {
			self.activationHandler?(sectionIndex, itemIndex)
		}
		if let item = model?.realItems(in: section)[index] {
			self.itemActivationHandler?(section, item)
		}
	}

	/**
		Inserts `widget` into `container` at `index`
	*/
	open func insert(widget: Widget, into container: Container?, at index: Int) {
		if let listBox = container as? ListBox {
			listBox.insert(child: widget, position: index)
		}
		if let flowBox = container as? FlowBox {
			flowBox.insert(widget: widget, position: index)
		}
	}

	/**
		Removes the widget at `index` from `container`
	*/
	open func remove(widgetAt index: Int, from container: Container?) {
		if let listBox = container as? ListBox, let child = listBox.getRowAt(index: index) {
			listBox.remove(widget: child)
		}
		if let flowBox = container as? FlowBox, let child = flowBox.getChildAtIndex(idx: index) {
			flowBox.remove(widget: child)
		}
	}
	
	public func sectionedModel(isEmptyChangedTo isEmpty: Bool) {
		print("model isEmpty updated to \(isEmpty)")
		if isEmpty, let placeholder = placeholder {
			stack.setVisible(child: placeholder)
		} else {
			stack.setVisible(child: box)
		}
	}

	/**
		Generates a container widget for `section`
	*/
	public func generateContainer(for section: S) -> Container {
		return ListBox()
	}
	
	/**
		Generates a header widget for `section`
	*/
	public func generateHeader(for section: S) -> Widget? {
		return nil
	}
 
}
