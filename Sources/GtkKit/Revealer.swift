import Gtk

public extension Revealer {

	func set(revealChild: Bool, onComplete completionHandler: @escaping () -> Void) {
		guard self.revealChild != revealChild else {
			return
		}
		set(revealChild: revealChild)
		var signalID: Int? = nil
		signalID = onNotify() { (revealer, parameter) in
			if parameter.name == "child-revealed" {
				completionHandler()
				revealer.signalHandlerDisconnect(handlerID: signalID!)
			}
		}
	}

}
