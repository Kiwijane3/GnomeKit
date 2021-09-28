import Foundation
import CGLib
import GLib
import GLibObject
import Gdk
import Gtk

public class KeyAction {

	public var input: String

	public var keyCode: Int?

	public var modifierFlags: KeyModifierFlags

	public let action: () -> Void

	public init(input: String, modifierFlags: KeyModifierFlags, action: @escaping () -> Void) {
		self.input = input
		keyCode = getKeyCode(for: input)
		self.modifierFlags = modifierFlags
		self.action = action
	}

}

public struct KeyModifierFlags: OptionSet {

	public let rawValue: Int

	public init(rawValue: Int) {
		self.rawValue = rawValue
	}

	// We use the same raw values as Gdk.ModifierType so that the raw values are compatible.
	public static let control = Self.init(rawValue: Gdk.ModifierType.controlMask.intValue)
	public static let shift = Self.init(rawValue: Gdk.ModifierType.shiftMask.intValue)
	public static let alternate = Self.init(rawValue: Gdk.ModifierType.mod1Mask.intValue)
	public static let `super` = Self.init(rawValue: Gdk.ModifierType.superMask.intValue)

	var modifierType: Gdk.ModifierType {
		return ModifierType(rawValue: UInt32(rawValue))
	}

}

public func getKeyCode(for string: String) -> Int? {
	if let value = string.unicodeScalars.first?.value {
		return Int(value)
	} else {
		return nil
	}

}

public extension AccelGroup {
	func connect(keyAction: KeyAction) {
		guard let keyCode = keyAction.keyCode else {
			return
		}
		let holder = ClosureHolder<Void, Void>(keyAction.action)
		let opaque = Unmanaged.passRetained(holder).toOpaque()
		let callback: @convention(c) (gpointer, gpointer, guint, gpointer, gpointer) -> Void = { (_, _, _, _, holderPtr) -> Void in
			let holder = Unmanaged<ClosureHolder<Void, Void>>.fromOpaque(holderPtr).takeUnretainedValue()
			holder.call(Void())
		}
		let closure = cclosureNew(callbackFunc: unsafeBitCast(callback, to: GCallback.self), userData: opaque, destroyData: { (holderPtr, _) in
			guard let holderPtr = holderPtr else {
				return
			}
			Unmanaged<ClosureHolder<Void, Void>>.fromOpaque(holderPtr).release()
		})
		connect(accelKey: keyCode, accelMods: keyAction.modifierFlags.modifierType, accelFlags: .mask, closure: closure!)
	}

}
