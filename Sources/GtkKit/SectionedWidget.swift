import Foundation
import Gtk

// A sectioned widget is the base for widgets that display several vertically arranged containers, possibly with headers.
public class SectionedWidget<S: Hashable, I: Hashable>: ScrolledWindow, SectionedModelDelegate {

	var box: Box

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
		
	public init() {
		box = Box(orientation: .vertical, spacing: 8)
		super.init(hadjustment: nil as Adjustment?, vadjustment: nil as Adjustment?)
		self.add(widget: box)
		box.showAll()
		box.valign = .start
		box.marginTop = 8
		box.marginBottom = 8
		box.marginStart = 8
		marginEnd = 8
		box.halign = .center
		setup()
	}
	
	public required init(raw: UnsafeMutableRawPointer) {
		box = Box(orientation: .vertical, spacing: 8)
		super.init(raw: raw)
		add(widget: box)
		box.valign = .start
		box.showAll()
		box.marginTop = 8
		box.marginBottom = 8
		box.marginStart = 8
		box.marginEnd = 8
		box.halign = .center
		setup()
	}
	
	public required init(retainingRaw raw: UnsafeMutableRawPointer) {
		box = Box(orientation: .vertical, spacing: 8)
		super.init(retainingRaw: raw)
		add(widget: box)
		box.valign = .start
		box.showAll()
		box.marginTop = 8
		box.marginBottom = 8
		box.marginStart = 8
		box.marginEnd = 8
		box.halign = .center
		setup()
	}

	public func setup() {

	}
	
	public func onCreateWidget(_ handler: @escaping (I) -> Widget) {
		widgetCreator = handler
	}
	
	public func onRowActivated(_ handler: @escaping (Int, Int) -> Void) {
		activationHandler = handler
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
	    if let listBox = container as? ListBox {
	    	listBox.onRowActivated(handler: { [weak self, weak model] (listBox, row) in
	    		// Get the item
	    		if let sectionIndex = model?.indexOf(section: section), let itemIndex = model?.targetIndex(forItemAtRealIndex: row.index, in: section) {
	    			self?.activationHandler?(sectionIndex, itemIndex)
	    		}
	    	})
		}
		if let flowBox = container as? FlowBox {
			flowBox.onChildActivated { [weak self, weak model] (flowBox, child) in
				if let sectionIndex = model?.indexOf(section: section), let itemIndex = model?.targetIndex(forItemAtRealIndex: child.index, in: section) {
					self?.activationHandler?(sectionIndex, itemIndex)
				}
			}
		}
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
	    if let box = sectionBoxMap[section] {
	    	remove(widget: box)
	    	sectionBoxMap[section] = nil
	    }
	    sectionHeaderMap[section] = nil
	    sectionContainerMap[section] = nil
	} 
	
	public func sectionedModel(addedItem item: Any, at index: Int, in section: AnyHashable) {
		guard let section = section as? S, let item = item as? I else {
			return
		}
		guard let itemIndex = model?.indexOf(item: item, in: section), let sectionIndex = model?.indexOf(section: section) else {
			return
		}
		let widget = widgetCreator?(item) ?? Box(orientation: .horizontal, spacing: 8)
		let container = sectionContainerMap[section]
		// Sectioned models currently accepts section containers that are listboxes or flowboxes. These are handled separately, since their insert methods aren't inherited from a common ancestor, despite similar signature and function.
		if let listBox = container as? ListBox {
			let row = ListBoxRow()
			row.add(widget: widget)
			row.selectable = false
			listBox.insert(child: row, position: index)
		}
		if let flowBox = container as? FlowBox {
			flowBox.insert(widget: widget, position: index)
		}
		widget.showAll()
	}
	
	public func sectionedModel(removedItem item: Any, at index: Int, in section: AnyHashable) {
		guard let section = section as? S else {
			return
		}
		let container = sectionContainerMap[section]
		if let listBox = container as? ListBox, let child = listBox.getRowAt(y: index) {
			listBox.remove(widget: child)
		}
		if let flowBox = container as? FlowBox, let child = flowBox.getChildAtIndex(idx: index) {
			flowBox.remove(widget: child)
		}
	}
	
	public func generateContainer(for section: S) -> Container {
		return ListBox()
	}
	
	public func generateHeader(for section: S) -> Widget? {
		return nil
	}
 
}
