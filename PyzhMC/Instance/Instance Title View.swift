import SwiftUI

struct InstanceTitleView: View {
    @StateObject var editingVM: InstanceEditingVM
    @StateObject var instance: Instance
    
    @Binding var showNoNamePopover: Bool
    @Binding var showDuplicatePopover: Bool
    @Binding var starHovered: Bool
    
    var body: some View {
        if editingVM.inEditMode {
            TextField(i18n("name"), text: $editingVM.name)
                .largeTitle()
                .labelsHidden()
                .fixedSize(horizontal: true, vertical: false)
                .frame(height: 20)
                .popover(isPresented: $showNoNamePopover, arrowEdge: .trailing) {
                    Text(i18n("enter_a_name"))
                        .padding()
                }
                .popover(isPresented: $showDuplicatePopover, arrowEdge: .trailing) {
                    // TODO: implement
                    Text(i18n("enter_unique_name"))
                        .padding()
                }
            
            InteractiveStarView(instance: self.instance, starHovered: $starHovered)
        } else {
            Text(instance.name)
                .largeTitle()
                .frame(height: 20)
                .padding(.trailing, 8)
            
            InteractiveStarView(instance: self.instance, starHovered: $starHovered)
        }
    }
}
