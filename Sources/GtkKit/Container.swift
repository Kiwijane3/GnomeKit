import Foundation
import Gtk

public extension ContainerProtocol {

	func removeAllChildren() {
		self.children?.forEach({ (ptr) in
			remove(widget: WidgetRef(raw: ptr))
		})
	}
		
		
}
