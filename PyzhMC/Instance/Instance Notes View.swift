import SwiftUI

struct InstanceNotesView: View {
    @StateObject var editingViewModel: InstanceEditingViewModel
    @StateObject var instance: Instance
    
    var body: some View {
        if editingViewModel.inEditMode {
            TextField("", text: $editingViewModel.notes, prompt: Text(i18n("notes")))
                .lineLimit(nil)
                .multilineTextAlignment(.leading)
                .frame(minWidth: 50)
                .padding(.leading, 3)
        } else {
            if instance.notes != nil {
                Text(instance.notes!)
                    .frame(minWidth: 50)
                    .padding(.leading, 3)
            }
        }
    }
}
