import Foundation
import Cairo

public extension String {

	var size: CGSize {
		let extents = BezierPath.calcContext.textExtents(self)
		return CGSize(width: extents.width, height: extents.height)
	}

	func draw(at origin: CGPoint, in context: ContextProtocol) {
		context.save()
		context.newPath()
		context.moveTo(Double(origin.x), Double(origin.y))
		context.showText(self)
		context.restore()
	}

}
