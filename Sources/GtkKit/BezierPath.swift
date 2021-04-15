//
//  BezierPath.swift
//  GtkMvc
//
//  Created by Jane Fraser on 22/10/20.
//

import Foundation
import CCairo
import Cairo



public enum LineCap {
	case butt
	case round
	case square
}

extension LineCap {
	
	internal var cairo: cairo_line_cap_t {
		switch self {
		case .butt:
			return .butt
		case .round:
			return .round;
		case .square:
			return .square;
		}
	}
	
}

public enum LineJoin {
	case miter
	case round
	case bevel
}

let evenOddFillRule = FillRule.init(1);
let windingFillRule = FillRule.init(0);

public class BezierPath {
	
	// This empty shared graphical context is used by CGPoint to calculate path extents and contains.
	private static var calcContext: ContextProtocol = Context(surface: imageSurfaceCreate(format: .init(0), width: 0, height: 0));
	
	internal enum Operation {
		case move(target: CGPoint)
		case line(target: CGPoint)
		case arc(center: CGPoint, radius: Double, startAngle: Double, endAngle: Double, clockwise: Bool)
		case curve(target: CGPoint, controlA: CGPoint, controlB: CGPoint)
		case quadCurve(target: CGPoint, control: CGPoint)
		case close
	}
	
	internal var operations: [Operation] = [];
	
	public var lineWidth: Double = 1.0;
	
	public var lineCapStyle: LineCap = .butt;
	
	public var miterLimit: Double = 10;
	
	public var usesEvenOddFillRule: Bool = false;
	
	public var dashPattern: [Double]?;
	
	public var dashPhase: Double = 0;
	
	public func move(to target: CGPoint) {
		operations.append(.move(target: target))
	}
	
	public func addLine(to target: CGPoint) {
		operations.append(.line(target: target));
	}
	
	public func addArc(withCenter center: CGPoint, radius: Double, startAngle: Double, endAngle: Double, clockwise: Bool) {
		operations.append(.arc(center: center, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: clockwise));
	}
	
	public func addCurve(to target: CGPoint, controlA: CGPoint, controlB: CGPoint) {
		operations.append(.curve(target: target, controlA: controlA, controlB: controlB))
	}
	
	public func addQuadCurve(to target: CGPoint, control: CGPoint) {
		operations.append(.quadCurve(target: target, control: control))
	}
	
	public func setLineDash(_ pattern: [Double]?, phase: Double) {
		self.dashPattern = pattern;
		self.dashPhase = phase;
	}
	
	public func fill(on context: ContextProtocol) {
		// Save and restore the context so we don't modify any existing paths.
		context.save();
		writePath(to: context);
		context.fill();
		context.restore();
	}
	
	public func stroke(on context: ContextProtocol) {
		context.save();
		writePath(to: context);
		context.fill();
		context.restore();
	}
	
	public func contains(_ point: CGPoint) -> Bool {
		return fillContains(point);
	}

	public func fillContains(_ point: CGPoint) -> Bool {
		// Since all contains and bounding box calculations are self-contained, we can just clear the path.
		BezierPath.calcContext.newPath();
		writePath(to: BezierPath.calcContext);
		return BezierPath.calcContext.isInFill(point.x, point.y);
	}
	
	public func strokeContains(_ point: CGPoint) -> Bool {
		// Since all contains and bounding box calculations are self-contained, we can just clear the path.
		BezierPath.calcContext.newPath();
		writePath(to: BezierPath.calcContext);
		return BezierPath.calcContext.isInStroke(point.x, point.y)
	}
	
	/** public var bounds: CGRect {
		get {
			BezierPath.calcContext.newPath();
			writePath(to: BezierPath.calcContext);
			let extents = BezierPath.calcContext.pathExtents
			return CGRect(origin: CGPoint(x: extents.x1, y: extents.y1), size: CGSize(width: extents.x2 - extents.x1, height: extents.y2 - y1));
		}
	} */
	
	// Writes this Path's operations onto the context.
	internal func writePath(to context: ContextProtocol) {
		var context = context;
		context.lineWidth = lineWidth;
		context.lineCap = lineCapStyle.cairo;
		context.miterLimit = miterLimit;
		context.fillRule = usesEvenOddFillRule ? evenOddFillRule : windingFillRule;
		if let dashPattern = dashPattern {
			context.setDash(dashPattern, offset: dashPhase);
		} else {
			cairo_set_dash(context.context_ptr, [], 0, 0);
		}
		context.newPath();
		for operation in operations {
			switch operation {
			case .move(let target):
				context.moveTo(target.x, target.y);
			case .line(let target):
				context.lineTo(target.x, target.y);
			case .arc(let center, let radius, let startAngle, let endAngle, let clockwise):
				if clockwise {
					context.arc(xc: center.x, yc: center.y, radius: radius, angle1: startAngle, angle2: endAngle);
				} else {
					context.arcNegative(xc: center.x, yc: center.y, radius: radius, angle1: startAngle, angle2: endAngle);
				}
			case .quadCurve(let target, let control):
				context.curveTo(x1: control.x, y1: control.y, x2: control.x, y2: control.y, x3: target.x, y3: target.y);
			case .curve(let target, let controlA, let controlB):
				context.curveTo(x1: controlA.x, y1: controlA.y, x2: controlB.x, y2: controlB.y, x3: target.x, y3: target.y);
			case .close:
				context.closePath();
			}
		}
	}
	
}
