import SwiftUI

struct InstanceConsoleView: View {
    var instance: Instance
    
    @Binding var launchedInstanceProcess: InstanceProcess?
    @EnvironmentObject var launcherData: LauncherData
    
    @State var launchedInstances: [Instance: InstanceProcess]? = nil
    @State var logMessages: [String] = []
    
    var body: some View {
        VStack {
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 8) {
                        ForEach(logMessages, id: \.self) { message in
                            Text(message)
                                .font(.system(.body, design: .monospaced))
                                .id(message)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                    .id(logMessages)
                }
                .background(Color(NSColor.textBackgroundColor))
                .cornerRadius(8)
                .overlay {
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(.secondary, lineWidth: 1)
                }
                .padding(7)
                
                HStack {
                    Button("Open logs folder") {
                        NSWorkspace.shared.selectFile(nil, inFileViewerRootedAtPath: instance.getLogsFolder().path)
                    }
                }
                .padding([.top, .leading, .trailing], 5)
                
                if launchedInstanceProcess != nil {
                    ZStack {
                        
                    }
                    .onAppear {
                        withAnimation {
                            proxy.scrollTo(logMessages.last, anchor: .bottom)
                        }
                        
                        logMessages = launchedInstanceProcess!.logMessages
                    }
                    .onReceive(launchedInstanceProcess!.$logMessages) {
                        logMessages = $0
                    }
                }
            }
            
            Spacer()
        }
    }
}
