import SwiftUI

struct ConsoleTextView: NSViewRepresentable {
    typealias NSViewType = NSTextView
    
    var text: String
    var layoutManager: NSLayoutManager
    var textContainer: NSTextContainer
    var font = NSFont.monospacedSystemFont(ofSize: NSFont.systemFontSize, weight: .regular)
    
    func makeNSView(context: Context) -> NSTextView {
        let textView = NSTextView()
        textView.minSize = NSSize(width: 200, height: 50)
        textView.isEditable = false
        textView.isSelectable = true
        textView.drawsBackground = false
        textView.font = font
        textView.alignment = NSTextAlignment.natural
        textView.string = text
        textView.allowsUndo = false
        textView.textContainer = self.textContainer
        
        return textView
    }
    
    func updateNSView(_ nsView: NSTextView, context: Context) {
        self.textContainer.layoutManager = self.layoutManager
        nsView.string = text
        nsView.font = font
        nsView.textContainer = self.textContainer
    }
}

struct ConsoleTextView_Previews: PreviewProvider {
    static var ints = Array(1...10)
    static let layoutManager = NSLayoutManager()
    
    static let textContainer: NSTextContainer = {
        var cont = NSTextContainer()
        layoutManager.addTextContainer(cont)
        layoutManager.allowsNonContiguousLayout = true
        return cont
    }()
    
    static var previews: some View {
        VStack(spacing: 0) {
            ForEach(ints, id: \.self) { i in
                ConsoleTextView(text: "This is console text \(i)", layoutManager: layoutManager, textContainer: textContainer)
            }
        }
    }
}
