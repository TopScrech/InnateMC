
import SwiftUI

struct InstanceExportSheet: View {
    @Binding var sheetExport: Bool
    
    @StateObject var instance: Instance
    
    var body: some View {
        VStack(alignment: .center) {
            Button("Cancel") {
                sheetExport = false
            }
            .padding()
        }
    }
}
