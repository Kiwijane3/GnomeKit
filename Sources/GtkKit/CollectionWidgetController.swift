import Foundation
import Gtk

open class CollectionWidgetController<S: Hashable, I: Hashable>: SectionedWidgetController<S, I> {

	public var collectionWidget: CollectionWidget<S, I>! {
		get {
		 return widget as! CollectionWidget<S, I>
		}
	}

	public override func loadWidget() {
		widget = CollectionWidget<S, I>()
		collectionWidget.model = model
		collectionWidget.onCreateWidget(generateWidget(for:at:in:))
		collectionWidget.onLayout(generateLayout(for:))
		collectionWidget.onCreateHeader(generateHeader(for:))
		collectionWidget.onRowActivated(activate(in:at:))
		collectionWidget.showAll()
	}

	open func generateLayout(for section: S) -> CollectionLayoutSection {
		return CollectionLayoutListSection()
	}

	 func generateHeader(for section: S) -> Widget? {
		return nil
	}

}
