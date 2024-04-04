import Cocoa

public class ErrorTracker: ObservableObject {
    static var instance = ErrorTracker()
    
    @Published var errors: [ErrorTrackerEntry] = []
    
    private var windowController: ErrorTrackerWindowController {
        if let windowControllerTemp = windowControllerTemp {
            return windowControllerTemp
        }
        
        self.windowControllerTemp = .init()
        
        return self.windowControllerTemp!
    }
    
    private var windowControllerTemp: ErrorTrackerWindowController? = nil
    
    func error(error: Error? = nil, description: String) {
        if let error = error {
            logger.error(description, error: error)
        } else {
            logger.error("\(description)")
        }
        
        self.errors.append(ErrorTrackerEntry(type: .error, description: description, error: error, timestamp: CFAbsoluteTime()))
    }
    
    func nonEssentialError(description: String) {
        self.errors.append(ErrorTrackerEntry(type: .nonEssentialError, description: description, timestamp: CFAbsoluteTime()))
    }
    
    func showWindow() {
        windowController.showWindow(PyzhMCApp.self)
    }
}
