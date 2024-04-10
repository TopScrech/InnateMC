import SwiftUI

struct InstanceTitleView: View {
    @StateObject var editingVM: InstanceEditingVM
    @StateObject var instance: Instance
    
    @Binding var showNoNamePopover: Bool
    @Binding var showDuplicatePopover: Bool
    @Binding var starHovered: Bool
    
    var body: some View {
        if editingVM.inEditMode {
            TextField("Name", text: $editingVM.name)
                .largeTitle()
                .labelsHidden()
                .fixedSize(horizontal: true, vertical: false)
                .frame(height: 20)
                .popover(isPresented: $showNoNamePopover, arrowEdge: .trailing) {
                    Text("Enter a name")
                        .padding()
                }
                .popover(isPresented: $showDuplicatePopover, arrowEdge: .trailing) {
                    // TODO: implement
                    Text("Enter a unique name")
                        .padding()
                }
            
            InteractiveStarView(instance: instance, starHovered: $starHovered)
        } else {
            Text(instance.name)
                .largeTitle()
                .frame(height: 20)
                .padding(.trailing, 8)
            
            InteractiveStarView(instance: instance, starHovered: $starHovered)
        }
    }
}
