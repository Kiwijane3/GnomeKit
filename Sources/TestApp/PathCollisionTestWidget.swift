import Foundation
import Gtk
import Cairo
import GtkKit

public class PathCollisionTestWidget: DrawingArea {

	var path: BezierPath!

	var tapGesture: GestureMultiPress!

	public override init() {
		super.init()
		configure()
	}

	public required init(raw: UnsafeMutableRawPointer) {
		super.init(raw: raw)
		configure()
	}

	public required init(retainingRaw raw: UnsafeMutableRawPointer) {
		super.init(retainingRaw: raw)
		configure()
	}

	func configure() {
		onDraw(handler: draw)
		tapGesture = GestureMultiPress(widget: self)
		tapGesture.onReleased(handler: release)
	}

	func draw(_ weakSelf: WidgetRef, _ context: ContextProtocol) -> Bool {
		let center = CGPoint(x: CGFloat(allocatedWidth / 2), y: CGFloat(allocatedHeight / 2))
		Color.black.set(on: context)
		path = BezierPath()
		path.addArc(withCenter: center, radius: 8, startAngle: 0, endAngle: Double.pi * 2, clockwise: true)
		path.fill(on: context)
		return true
	}

	func release(_ recogniser: GestureMultiPressProtocol, presses: Int, x: Double, y: Double) {
		let point = CGPoint(x: CGFloat(x), y: CGFloat(y))
		print("Release at (\(x),\(y)), point was: \(point)")
		print("Path contained point: \(path.contains(point)), inFill: \(path.fillContains(point)), inStroke: \(path.strokeContains(point))")
	}

}

public class PathCollisionTestController: WidgetController {

	public override func loadWidget() {
		widget = PathCollisionTestWidget()
	}

}
