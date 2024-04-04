import SwiftUI

struct ErrorTrackerView: View {
    @StateObject var errorTracker: ErrorTracker
    @State var selection: ErrorTrackerEntry? = nil
    
    @ViewBuilder
    var body: some View {
        List(selection: $selection) {
            ForEach(errorTracker.errors, id: \.counter) { entry in
                HStack {
                    entry.type.icon
                    
                    VStack {
                        HStack {
                            Text(entry.description)
                                .padding(.bottom, 2)
                            Spacer()
                        }
                        
                        if let error = entry.error {
                            HStack {
                                Text(error.localizedDescription)
                                
                                Spacer()
                            }
                        }
                    }
                    
                    Spacer()
                }
                .padding(2)
            }
        }
    }
}

struct ErrorTrackerView_Previews: PreviewProvider {
    static let errorTracker: ErrorTracker = {
        let tracker = ErrorTracker()
        tracker.nonEssentialError(description: "Something happened!")
        tracker.error(error: LaunchError.errorDownloading(error: nil), description: "Something bad happened!")
        tracker.nonEssentialError(description: "Something happened but it wasn't that bad")
        
        return tracker
    }()
    
    static var previews: some View {
        ErrorTrackerView(errorTracker: errorTracker)
    }
}
