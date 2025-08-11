import Foundation

#if canImport(CoreGraphics)
import CoreGraphics
#else
// Fallback CGPoint for environments without CoreGraphics
public struct CGPoint {
    public var x: Double
    public var y: Double
    
    public init(x: Double, y: Double) {
        self.x = x
        self.y = y
    }
    
    public static let zero = CGPoint(x: 0, y: 0)
}
#endif