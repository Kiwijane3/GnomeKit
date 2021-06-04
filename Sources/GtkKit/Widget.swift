import Foundation
import GLib
import Gtk
import Gdk
import CGdk

public extension WidgetProtocol {

	func child<T: Widget>(named name: String) -> T! {
		return child(named: name, of: T.self)
	}

	func child<T: Widget>(named name: String, of type: T.Type) -> T! {
		print("child(named:of:)")
		debugPrint("Called child on \(self.name)")
		if self.name == name {
			return T(retainingRaw: ptr)
		}
		if isAContainer() {
			let containerRef = ContainerRef(raw: ptr)
			// Children returns a nil pointer if there are no children.
			print("Searching Container")
			if let children = containerRef.children {
				print("Searching child")
				for ptr in children {
					if let result = WidgetRef(raw: ptr).child(named: name, of: type) {
						return result
					}
				}
			}
		}
		return nil
	}

	func addTickCallback(_ handler: @escaping (WidgetRef, FrameClockRef) -> Bool) -> Int{
		let holder = ClosureHolder2<WidgetRef, FrameClockRef, Bool>(handler)
		let opaque = Unmanaged<ClosureHolder2<WidgetRef, FrameClockRef, Bool>>.passRetained(holder).toOpaque()
		return addTick(callback: { (widgetPtr, clockPtr, holderPtr) -> gboolean in
			let holder = Unmanaged<ClosureHolder2<WidgetRef, FrameClockRef, Bool>>.fromOpaque(holderPtr!).takeUnretainedValue()
			return holder.call(WidgetRef(raw: widgetPtr!), FrameClockRef(raw: clockPtr!)) ? 1 : 0
		}, userData: opaque, notify: { (holderPtr) in
			Unmanaged<ClosureHolder2<WidgetRef, FrameClockRef, Bool>>.fromOpaque(holderPtr!).release()
		})
	}

	func addTickCallback(_ handler: @escaping (WidgetRef) -> Bool) -> Int {
		let holder = ClosureHolder<WidgetRef, Bool>(handler)
		let opaque = Unmanaged<ClosureHolder<WidgetRef, Bool>>.passRetained(holder).toOpaque()
		return addTick(callback: { (widgetPtr, _, holderPtr) -> gboolean in
			let holder = Unmanaged<ClosureHolder<WidgetRef, Bool>>.fromOpaque(holderPtr!).takeUnretainedValue()
			return holder.call(WidgetRef(raw: widgetPtr!)) ? 1 : 0
		}, userData: opaque, notify: { (holderPtr) in
			Unmanaged<ClosureHolder<WidgetRef, Bool>>.fromOpaque(holderPtr!).release()
		})
	}

}
