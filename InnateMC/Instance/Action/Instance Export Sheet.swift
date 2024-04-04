
import SwiftUI

struct InstanceExportSheet: View {
    @Binding var showExportSheet: Bool
    
    @StateObject var instance: Instance
    
    var body: some View {
        VStack(alignment: .center) {
            Button(i18n("cancel")) {
                showExportSheet = false
            }
            .padding()
        }
    }
}
