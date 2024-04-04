import SwiftUI

struct InstanceConsoleView: View {
    var instance: Instance
    
    @Binding var launchedInstanceProcess: InstanceProcess?
    @EnvironmentObject var launcherData: LauncherData
    
    @State var launchedInstances: [Instance:InstanceProcess]? = nil
    @State var logMessages: [String] = []
    
    var body: some View {
        VStack {
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 8) {
                        ForEach(self.logMessages, id: \.self) { message in
                            Text(message)
                                .font(.system(.body, design: .monospaced))
                                .id(message)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                    .id(self.logMessages)
                }
                .background(Color(NSColor.textBackgroundColor))
                .cornerRadius(8)
                .overlay {
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.secondary, lineWidth: 1)
                }
                .padding(.all, 7)
                
                HStack {
                    Button(i18n("open_logs_folder")) {
                        NSWorkspace.shared.selectFile(nil, inFileViewerRootedAtPath: instance.getLogsFolder().path)
                    }
                }
                .padding([.top, .leading, .trailing], 5)
                
                if self.launchedInstanceProcess != nil {
                    ZStack {
                        
                    }
                    .onAppear {
                        withAnimation {
                            proxy.scrollTo(self.logMessages.last, anchor: .bottom)
                        }
                        
                        self.logMessages = self.launchedInstanceProcess!.logMessages
                    }
                    .onReceive(self.launchedInstanceProcess!.$logMessages) {
                        self.logMessages = $0
                    }
                }
            }
            
            Spacer()
        }
    }
}
