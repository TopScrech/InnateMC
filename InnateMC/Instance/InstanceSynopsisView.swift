import SwiftUI

struct InstanceSynopsisView: View {
    @StateObject var editingViewModel: InstanceEditingViewModel
    @StateObject var instance: Instance
    
    var body: some View {
        if editingViewModel.inEditMode {
            TextField("", text: $editingViewModel.synopsis, prompt: Text(self.instance.debugString))
                .fixedSize(horizontal: true, vertical: false)
                .caption()
                .padding(.vertical, 6)
                .foregroundColor(.gray)
                .frame(height: 10)
        } else {
            Text(self.instance.synopsisOrVersion)
                .caption()
                .padding(.vertical, 6)
                .foregroundColor(.gray)
                .frame(height: 10)
        }
    }
}
