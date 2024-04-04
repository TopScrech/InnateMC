
import SwiftUI

open class TaskProgress: ObservableObject {
    @Published public var current = 0
    @Published public var total = 1
    
    public var callback: (() -> Void)? = nil
    public var cancelled = false
    
    public init() {
        
    }
    
    public func fraction() -> Double {
        Double(current) / Double(total)
    }
    
    public func percentString() -> String {
        String(format: "%.2f", fraction() * 100) + "%"
    }
    
    @MainActor
    open func inc() {
        self.current += 1
        
        if self.current == self.total {
            logger.debug("Sending download progress callback")
            callback?()
        }
        
        logger.trace("Incremented task progress to \(self.current)")
    }
    
    public func intPercent() -> Int {
        Int((fraction() * 100).rounded())
    }
    
    public func isDone() -> Bool {
        Int(current) >= Int(total)
    }
    
    public init(current: Int, total: Int) {
        self.current = current
        self.total = total
    }
    
    public static func completed() -> TaskProgress {
        TaskProgress(current: 1, total: 1)
    }
    
    public func setFrom(_ other: TaskProgress) {
        self.current = other.current
        self.total = other.total
    }
}
