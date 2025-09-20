import Foundation
import CoreMotion
import PuzzAlarmCore

/// Manages device motion for puzzle interactions
public class MotionManager: ObservableObject {
    public static let shared = MotionManager()
    
    private let motionManager = CMMotionManager()
    @Published public var currentTilt: (x: Double, y: Double) = (0, 0)
    @Published public var isMotionActive = false
    
    private override init() {
        super.init()
        setupMotionManager()
    }
    
    private func setupMotionManager() {
        guard motionManager.isAccelerometerAvailable else {
            print("Accelerometer not available")
            return
        }
        
        motionManager.accelerometerUpdateInterval = 0.1
    }
    
    /// Starts monitoring device motion for puzzle interactions
    public func startMotionUpdates() {
        guard motionManager.isAccelerometerAvailable && !isMotionActive else { return }
        
        motionManager.startAccelerometerUpdates(to: .main) { [weak self] data, error in
            guard let data = data, error == nil else {
                print("Error reading accelerometer data: \(error?.localizedDescription ?? "Unknown")")
                return
            }
            
            // Convert acceleration to tilt values
            // Clamp values to reasonable range for puzzle controls
            let tiltX = max(-1.0, min(1.0, data.acceleration.x))
            let tiltY = max(-1.0, min(1.0, data.acceleration.y))
            
            self?.currentTilt = (x: tiltX, y: tiltY)
        }
        
        isMotionActive = true
    }
    
    /// Stops monitoring device motion
    public func stopMotionUpdates() {
        motionManager.stopAccelerometerUpdates()
        isMotionActive = false
        currentTilt = (0, 0)
    }
    
    /// Gets the current device tilt as a normalized vector
    public func getCurrentTilt() -> (x: Double, y: Double) {
        return currentTilt
    }
    
    /// Check if motion is available on this device
    public var isMotionAvailable: Bool {
        return motionManager.isAccelerometerAvailable
    }
}