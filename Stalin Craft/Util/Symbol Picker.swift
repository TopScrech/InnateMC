import SwiftUI

/// A simple and cross-platform SFSymbol picker for SwiftUI.
struct SymbolPicker: View {
    private let symbols = SFSymbolsList.getAll()
    
    private static var gridDimension: CGFloat {
        48
    }
    
    private static var symbolSize: CGFloat {
        24
    }
    
    private static var symbolCornerRadius: CGFloat {
        8
    }
    
    private static var unselectedItemBackgroundColor: Color {
        .clear
    }
    
    private static var selectedItemBackgroundColor: Color {
        .accentColor
    }
    
    private static var backgroundColor: Color {
        .clear
    }
    
    // MARK: - Properties
    @Binding var symbol: String
    @State private var searchText = ""
    
    @Environment(\.presentationMode) private var presentationMode
    
    // MARK: - Public Init
    /// Initializes `SymbolPicker` with a string binding that captures the raw value of
    /// user-selected SFSymbol.
    /// - Parameter symbol: String binding to store user selection.
    init(symbol: Binding<String>) {
        _symbol = symbol
    }
    
    // MARK: - View Components
    @ViewBuilder
    private var searchableSymbolGrid: some View {
        VStack(spacing: 0) {
            HStack {
                TextField("Search", text: $searchText)
                    .textFieldStyle(.plain)
                    .fontSize(18)
                    .disableAutocorrection(true)
                
                Button {
                    presentationMode.wrappedValue.dismiss()
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .resizable()
                        .frame(width: 16, height: 16)
                }
                .buttonStyle(.borderless)
            }
            .padding()
            
            Divider()
            
            symbolGrid
        }
    }
    
    private var symbolGrid: some View {
        ScrollView {
            LazyVGrid(columns: [GridItem(.adaptive(minimum: Self.gridDimension, maximum: Self.gridDimension))]) {
                ForEach(symbols.filter { searchText.isEmpty ? true : $0.localizedCaseInsensitiveContains(searchText) }, id: \.self) { thisSymbol in
                    Button {
                        symbol = thisSymbol
                        presentationMode.wrappedValue.dismiss()
                    } label: {
                        if thisSymbol == symbol {
                            Image(systemName: thisSymbol)
                                .fontSize(Self.symbolSize)
                                .frame(maxWidth: .infinity, minHeight: Self.gridDimension)
                                .background(Self.selectedItemBackgroundColor)
                                .cornerRadius(Self.symbolCornerRadius)
                                .foregroundColor(.white)
                        } else {
                            Image(systemName: thisSymbol)
                                .fontSize(Self.symbolSize)
                                .frame(maxWidth: .infinity, minHeight: Self.gridDimension)
                                .background(Self.unselectedItemBackgroundColor)
                                .cornerRadius(Self.symbolCornerRadius)
                                .foregroundColor(.primary)
                        }
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
    
    var body: some View {
        searchableSymbolGrid
            .frame(width: 540, height: 320, alignment: .center)
    }
}

#Preview {
    SymbolPicker(symbol: .constant("square.and.arrow.up"))
}
