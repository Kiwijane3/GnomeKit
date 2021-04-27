import Foundation
import GLibObject
import CGLib

let swiftObjKey = "swiftobj";

let gtrue: gboolean = 1

let gfalse: gboolean = 0

public extension GLibObject.ObjectProtocol {

	/// The swift wrapper for this object.
	public var swiftObj: AnyObject? {
		get {
			let pointer = getData(key: swiftObjKey);
			if pointer != nil {
				return Unmanaged<AnyObject>.fromOpaque(pointer!).takeUnretainedValue();
			} else {
				return nil;
			}
		}
		nonmutating set {
			// Setting swift object to the already existing swiftObj is a no-op, in order to avoid duplicate toggleRefs, which never fire and thus cause reference cycles.
			guard let newValue = newValue, newValue !== swiftObj else {
				return
			}
			// Get a strong pointer to swiftObj
			let pointer = Unmanaged<AnyObject>.passRetained(newValue).toOpaque();
			setData(key: swiftObjKey, data: pointer);
			// In the majority of cases, swiftObj will be the swift wrapper for this gobject's c implementation. To prevent orphaning, these should be equivalent for memory management purposes; If one is referenced, the other is referenced. A naive way to implement this is to have both strongly reference each other, but this creates a strong reference cycle. Therefore, the wrapper has a strong toggle reference to the gobject, which tells us when there are other references. In this instance, the wrapper should be referenced, so the gobject strongly references it. Otherwise, the gobject weakly references it, allowing it, and thus the gobject, to be released once it is not referenced in swift-space.
			addToggleRef { (_, selfPointer, lastRef) in
				let swiftObjPointer = Unmanaged<AnyObject>.fromOpaque(g_object_get_data(selfPointer, swiftObjKey));
				switch lastRef {
				case gfalse:
					// Make the gobject strongly reference the wrapper.
					swiftObjPointer.retain();
					debugPrint("Swift object strongly referenced")
				case gtrue:
					// Make the gobject weakly reference the wrapper.
					swiftObjPointer.release();
					debugPrint("Swift object weakly referenced")
				default:
					break;
				}
			}
		}
	}

}

public extension GLibObject.Object {

	/// Will set this swift instance to be the swiftObj.
	public func becomeSwiftObj() {
		swiftObj = self;
	}

}
