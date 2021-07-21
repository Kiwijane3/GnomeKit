import Foundation
import Gtk

open class CollectionWidgetController<S: Hashable, I: Hashable>: SectionedWidgetController<S, I> {

	public var collectionWidget: CollectionWidget<S, I>!

	public override func loadWidget() {
		if loadWidgetFromBuilder() {
			collectionWidget = child(named: "collectionWidget")
		} else {
			collectionWidget = CollectionWidget<S, I>()
			widget = collectionWidget
		}
		collectionWidget.model = model
		collectionWidget.onCreateWidget(generateWidget(for:))
		collectionWidget.onLayout(generateLayout(for:))
		collectionWidget.onCreateHeader(generateHeader(for:))
		collectionWidget.onRowActivated(activate(in:at:))
		collectionWidget.onRowActivated(activate(in:for:))
		collectionWidget.showAll()
	}

	open func generateLayout(for section: S) -> CollectionLayoutSection {
		return CollectionLayoutListSection()
	}

	open func generateHeader(for section: S) -> Widget? {
		return nil
	}

}
