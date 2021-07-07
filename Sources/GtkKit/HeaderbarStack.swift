import Foundation
import Gtk

// A header bar stack manages a stack of headerbars and animates transitions. It is usually attached to a presentation controller, which displays it as a titlebar in its container.
public class HeaderbarStack: Stack {

	public var items: Set<HeaderbarItem> = []

	public var itemBarMap: [HeaderbarItem: ItemHeaderbar] = [:]

	public var showsWindowControls = false

	public override init() {
		super.init()
		transitionType = .crossfade
		transitionDuration = 200
		becomeSwiftObj()
	}

	public required init(raw: UnsafeMutableRawPointer) {
		super.init(raw: raw)
		transitionType = .crossfade
		transitionDuration = 200
		becomeSwiftObj()
	}

	public required init(retainingRaw raw: UnsafeMutableRawPointer) {
		super.init(retainingRaw: raw)
		transitionType = .crossfade
		transitionDuration = 200
		becomeSwiftObj()
	}

	public func update(with newItems: Set<HeaderbarItem>, main: HeaderbarItem?, supplementaryItem: BarItem?) {
		print("Supplementary item: \(supplementaryItem)")
		buildBars(for: newItems.subtracting(items))
		let removalItems = items.subtracting(newItems)
		if let main = main, let bar = itemBarMap[main] {
			bar.supplementaryItem = supplementaryItem
			setVisible(child: bar, onComplete: { [weak self] in
				self?.removeBars(for: removalItems)
			})
			print("Displayed bar \(ObjectIdentifier(bar))")
		} else {
			removeBars(for: removalItems)
		}
		items = newItems
	}

	public func buildBars(for items: Set<HeaderbarItem>) {
		for item in items {
			let bar = ItemHeaderbar(item: item)
			bar.showCloseButton = showsWindowControls
			bar.halign = .fill
			bar.valign = .fill
			itemBarMap[item] = bar
			if bar !== itemBarMap[item]  {
				print("Inconsistent identity on ItemHeaderbar")
			}
			add(widget: bar)
		}
	}

	public func removeBars(for items: Set<HeaderbarItem>) {
		for item in items {
			if let bar = itemBarMap[item] {
				remove(widget: bar)
				itemBarMap[item] = nil
			}
		}
	}

}
