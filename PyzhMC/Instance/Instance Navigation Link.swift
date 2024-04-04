import SwiftUI

struct InstanceNavigationLink: View {
    @EnvironmentObject var launcherData: LauncherData
    @StateObject var instance: Instance
    
    @Binding var selectedInstance: Instance?
    
    @State var starHovered = false
    @State var sheetDelete = false
    
    var body: some View {
        NavigationLink {
            InstanceView(instance: instance)
                .padding(.top, 10)
        } label: {
            HStack {
                ZStack(alignment: .topTrailing) {
                    if launcherData.globalPreferences.ui.compactList {
                        InstanceLogoView(instance: instance)
                            .frame(width: 32, height: 32)
                    } else {
                        InstanceLogoView(instance: instance)
                            .frame(width: 48, height: 48)
                    }
                    
                    ZStack {
                        if launcherData.launchedInstances.contains(where: { $0.0 == self.instance }) {
                            Image(systemName: "arrowtriangle.right.circle.fill")
                                .foregroundColor(.green)
                                .frame(width: 8, height: 8)
                        } else if instance.isStarred {
                            Image(systemName: "star.fill")
                                .foregroundColor(.yellow)
                                .frame(width: 8, height: 8)
                        }
                    }
                    .frame(width: 8, height: 8)
                }
                
                VStack {
                    HStack {
                        Text(instance.name)
                        
                        Spacer()
                    }
                    
                    HStack {
                        Text(instance.synopsisOrVersion)
                            .foregroundColor(.gray)
                        
                        Spacer()
                    }
                }
                
                Spacer()
            }
            .frame(maxWidth: .infinity)
        }
        .sheet($sheetDelete) {
            InstanceDeleteSheet(sheetDelete: $sheetDelete, selectedInstance: $selectedInstance, instanceToDelete: self.instance)
        }
        .contextMenu {
            if instance.isStarred {
                Button("Unstar") {
                    withAnimation {
                        instance.isStarred = false
                    }
                }
            } else {
                Button("Star") {
                    withAnimation {
                        instance.isStarred = true
                    }
                }
            }
            
            Button("Delete") {
                sheetDelete = true
            }
        }
    }
}
