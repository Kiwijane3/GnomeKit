import Foundation
import CGLib
import GLib

public func idle(_ handler: @escaping() -> Bool) {
	let holder = TimerClosureHolder(handler);
	let opaque = Unmanaged<TimerClosureHolder>.passRetained(holder).toOpaque();
	idleAddFull(priority: Int(G_PRIORITY_DEFAULT_IDLE), function: { (holderPointer) -> gboolean in
		let holder = Unmanaged<TimerClosureHolder>.fromOpaque(holderPointer!).takeUnretainedValue();
		return holder.call() ? 1 : 0;
	}, data: opaque) { (holderPointer) in
		Unmanaged<TimerClosureHolder>.fromOpaque(holderPointer!).release();
	}
}

public func main(_ handler: @escaping() -> Void) {
	let action = { () -> Bool in
		handler()
		return false
	}
	let holder = TimerClosureHolder(action)
	let opaque = Unmanaged<TimerClosureHolder>.passRetained(holder).toOpaque()
	idleAddFull(priority: Int(G_PRIORITY_HIGH), function: { (holderPointer) -> gboolean in
		let holder = Unmanaged<TimerClosureHolder>.fromOpaque(holderPointer!).takeUnretainedValue()
		return holder.call() ? 1 : 0
	}, data: opaque, notify: { (holderPointer) in
		Unmanaged<TimerClosureHolder>.fromOpaque(holderPointer!).release()
	})
}
