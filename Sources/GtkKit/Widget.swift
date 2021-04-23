import Foundation
import Gtk

public extension WidgetProtocol {

	func child<T: Widget>(named name: String) -> T! {
		return child(named: name, of: T.self)
	}

	func child<T: Widget>(named name: String, of type: T.Type) -> T! {
		debugPrint("Called child on \(self.name)")
		if self.name == name {
			return T(retainingRaw: ptr)
		}
		if isABin() {
			let binRef = BinRef(raw: ptr)
			if let contained = binRef.child {
				return contained.child(named: name, of: type)
			}
		}
		if isAContainer() {
			let containerRef = ContainerRef(raw: ptr)
			// Children returns a nil pointer if there are no children.
			if let children = containerRef.children {
				for ptr in children {
					if let result = WidgetRef(raw: ptr).child(named: name, of: type) {
						return result
					}
				}
			}
		}
		return nil
	}

}
