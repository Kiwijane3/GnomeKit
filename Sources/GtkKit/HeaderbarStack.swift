import Foundation
import Gtk

// A header bar stack manages a stack of headerbars and animates transitions. It is usually attached to a presentation controller, which displays it as a titlebar in its container.
public class HeaderbarStack: Stack {

	public var items: Set<HeaderbarItem> = []

	public var itemBarMap: [HeaderbarItem: ItemHeaderbar] = [:]

	public var showsWindowControls = false {
		didSet {
			displayedBar?.showCloseButton = showsWindowControls
			complexHeaderStacks?.last?.showsWindowControls = showsWindowControls
		}
	}


	/// The widget currently used for complex header bars. This is provided by root controller.
	public var complexHeaderWidget: Widget?

	/// The headerbarstacks embedded in the complex header widget.
	public var complexHeaderStacks: [HeaderbarStack]?

	// This is a list of widgets that need to be removed after the next animated transition. Widgets cannot be removed immediately because that may prevent animated transitions if the removed widget was previously displayed.
	private var cleanupWidgets: [Widget] = []

	var nilBar = ItemHeaderbar(item: nil)

	var displayedBar: ItemHeaderbar?

	public override init() {
		super.init()
		transitionType = .crossfade
		transitionDuration = 200
		becomeSwiftObj()
		add(widget: nilBar)
		displayedBar = nilBar
	}

	public required init(raw: UnsafeMutableRawPointer) {
		super.init(raw: raw)
		transitionType = .crossfade
		transitionDuration = 200
		becomeSwiftObj()
		add(widget: nilBar)
		displayedBar = nilBar
		showNilBar()
	}

	public required init(retainingRaw raw: UnsafeMutableRawPointer) {
		super.init(retainingRaw: raw)
		transitionType = .crossfade
		transitionDuration = 200
		becomeSwiftObj()
		showNilBar()
	}

	public func showNilBar() {
		add(widget: nilBar)
		setVisible(child: nilBar)
		displayedBar = nilBar
	}

	public func setupComplexHeaderbar(using config: (Widget, [HeaderbarStack])?) {
		cleanup(complexHeaderWidget)
		complexHeaderWidget = config?.0
		if let complexHeaderWidget = complexHeaderWidget {
			add(widget: complexHeaderWidget)
		}
		complexHeaderStacks = config?.1
	}

	public func update(with state: HeaderbarState?) {
		switch state {
			case .simple(let items, let main, let supplementaryItem, let switcherItem):
				update(with: items, main: main, supplementaryItem: supplementaryItem, switcherItem: switcherItem)
			case .complex(let states):
				complexUpdate(with: states)
			default:
				animateTransition(to: nilBar)
		}
	}

	public func update(with newItems: Set<HeaderbarItem>, main: HeaderbarItem?, supplementaryItem: BarItem?, switcherItem: BarItem?) {
		buildBars(for: newItems.subtracting(items))
		removeBars(for: items.subtracting(newItems))
		let bar: ItemHeaderbar
		if let main = main, let itemBar = itemBarMap[main] {
			bar = itemBar
		} else {
			bar = ItemHeaderbar(item: nil)
		}
		bar.supplementaryItem = supplementaryItem
		bar.switcherItem = switcherItem
		bar.showCloseButton = showsWindowControls
		displayedBar = bar
		animateTransition(to: bar)
		bar.setDefault()
		items = newItems
	}

	public func complexUpdate(with state: [HeaderbarState?]) {
		guard let complexHeaderWidget = complexHeaderWidget, let complexHeaderStacks = complexHeaderStacks else {
			debugPrint("Warning: Attempted to update split bar configuration, but split bar was not setup")
			return
		}
		guard complexHeaderStacks.count >= state.count else {
			debugPrint("Warning: Attempted to update a complex header bar configuration with wrong number of items. Make sure the size of items, main items, and supplementary items matches the number of bars")
			return
		}
		for index in 0..<complexHeaderStacks.count {
			complexHeaderStacks[index].update(with: state[index])
		}
		animateTransition(to: complexHeaderWidget)
		displayedBar = nil
	}

	public func buildBars(for items: Set<HeaderbarItem> ) {
		for item in items {
			let bar = ItemHeaderbar(item: item)
			bar.showCloseButton = showsWindowControls
			bar.halign = .fill
			bar.valign = .fill
			itemBarMap[item] = bar
			add(widget: bar)
		}
	}

	public func removeBars(for items: Set<HeaderbarItem>) {
		for item in items {
			if let bar = itemBarMap[item] {
				itemBarMap[item] = nil
				cleanup(bar)
			}
		}
	}

	private func animateTransition(to widget: Widget) {
		// We don't need the forced unwrap, but this makes it clearer what's happening
		if visibleChild?.ptr != widget.ptr {
			setVisible(child: widget, onComplete: { [weak self] in
				self?.doCleanup()
			})
			showAll()
		} else {
			doCleanup()
		}
	}

	private func cleanup(_ widget: Widget?) {
		guard let widget = widget else {
			return
		}
		cleanupWidgets.append(widget)
	}

	private func doCleanup() {
		for widget in cleanupWidgets {
			remove(widget: widget)
		}
		cleanupWidgets = []
	}

}

public enum HeaderbarState {
	/// A simple state for displaying in a single headerbar.
	/// A simple state can be supplied for any headerbar stack; If the stack has a complex configuration, it will display an animated transition between the complex bar and the single bar specified by the item.
	case simple(items: Set<HeaderbarItem>, main: HeaderbarItem?, supplementaryItems: BarItem?, switcherItem: BarItem?)
	/// A complex state is used for a complex headerbar stack with multiple embedded headerbar stacks. The nth state is supplied to the nth stack, as provided by the configuration.
	/// A complex state should only be supplied if the headerbar stack has been configured with a complex child, and there should be at least as many states as there are embedded stacks.
	case complex(states: [HeaderbarState?])
}
