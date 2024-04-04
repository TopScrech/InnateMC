import SwiftUI

struct ImageLogoPickerView: View {
    @State var shouldShowFileImporter = false
    @State var showImagePreview = false
    
    var instance: Instance
    
    var body: some View {
        VStack {
            if showImagePreview {
                AsyncImage(url: instance.getLogoPath()) {
                    $0.resizable().scaledToFit()
                } placeholder: {
                    Image(systemName: "tray.circle").resizable()
                }
            }
            Button(i18n("open")) {
                shouldShowFileImporter = true
            }
            .padding(.all, 50)
            .fileImporter(isPresented: $shouldShowFileImporter, allowedContentTypes: [.png]) { result in
                let url: URL
                
                do {
                    url = try result.get()
                } catch {
                    return
                }
                
                // TODO: error handling
                let fm = FileManager.default
                let logoPath = instance.getLogoPath()
                
                if fm.fileExists(atPath: logoPath.path) {
                    try! fm.removeItem(at: logoPath)
                }
                
                try! fm.copyItem(at: url, to: logoPath)
                
                DispatchQueue.main.async {
                    instance.logo = InstanceLogo(logoType: .file, string: "")
                    
                    DispatchQueue.global().async {
                        try! instance.save()
                    }
                    
                    showImagePreview = true
                }
            }
        }
    }
}
