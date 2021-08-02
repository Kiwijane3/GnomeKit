import GLibObject
import Gtk

public extension Stack {

	/**
		Transitions this stack to display `child`

		- Parameter onComplete: A closure to be invoked once `child` has been displayed
	*/
	public func setVisible(child: Widget, onComplete completionHandler: @escaping () -> Void) {
		setVisible(child: child)
		var signalId: Int?
		signalId = onNotify() { [weak self] (_, parameter) in
			print("Running on notify from onComplete")
			if parameter.name == "transition-running" {
				completionHandler()
				if let signalId = signalId {
					self?.signalHandlerDisconnect(handlerID: signalId)
					print("Disconnected")
				}
			}
		}
	}

}
