import SwiftUI

/// A simple and cross-platform SFSymbol picker for SwiftUI.
public struct SymbolPicker: View {
    private let symbols = SFSymbolsList.getAll()
    
    private static var gridDimension: CGFloat {
#if os(iOS)
        64
#elseif os(tvOS)
        128
#elseif os(macOS)
        48
#else
        48
#endif
    }
    
    private static var symbolSize: CGFloat {
#if os(iOS)
        24
#elseif os(tvOS)
        48
#elseif os(macOS)
        24
#else
        24
#endif
    }
    
    private static var symbolCornerRadius: CGFloat {
#if os(iOS)
        8
#elseif os(tvOS)
        12
#elseif os(macOS)
        8
#else
        8
#endif
    }
    
    private static var unselectedItemBackgroundColor: Color {
#if os(iOS)
        Color(UIColor.systemBackground)
#else
            .clear
#endif
    }
    
    private static var selectedItemBackgroundColor: Color {
#if os(tvOS)
        .gray.opacity(0.3)
#else
        .accentColor
#endif
    }
    
    private static var backgroundColor: Color {
#if os(iOS)
        Color(UIColor.systemGroupedBackground)
#else
            .clear
#endif
    }
    
    // MARK: - Properties
    @Binding public var symbol: String
    @State private var searchText = ""
    @Environment(\.presentationMode) private var presentationMode
    
    // MARK: - Public Init
    /// Initializes `SymbolPicker` with a string binding that captures the raw value of
    /// user-selected SFSymbol.
    /// - Parameter symbol: String binding to store user selection.
    public init(symbol: Binding<String>) {
        _symbol = symbol
    }
    
    // MARK: - View Components
    @ViewBuilder
    private var searchableSymbolGrid: some View {
#if os(iOS)
        if #available(iOS 15.0, *) {
            symbolGrid
                .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always))
        } else {
            VStack {
                TextField(i18n("search"), text: $searchText)
                    .padding(8)
                    .padding(.horizontal, 8)
                    .background(Color(UIColor.systemGray5))
                    .cornerRadius(8)
                    .padding(.horizontal, 16)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                
                symbolGrid
                    .padding()
            }
        }
        
#elseif os(tvOS)
        VStack {
            TextField(i18n("search"), text: $searchText)
                .padding(.horizontal, 8)
                .autocapitalization(.none)
                .disableAutocorrection(true)
            symbolGrid
        }
        
        /// `searchable` is crashing on tvOS 16. What the hell aPPLE?
        ///
        /// symbolGrid
        ///     .searchable(text: $searchText, placement: .automatic)
#elseif os(macOS)
        VStack(spacing: 0) {
            HStack {
                TextField(i18n("search"), text: $searchText)
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
#else
        symbolGrid
            .searchable(text: $searchText, placement: .automatic)
#endif
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
#if os(tvOS)
                                .frame(minWidth: Self.gridDimension, minHeight: Self.gridDimension)
#else
                                .frame(maxWidth: .infinity, minHeight: Self.gridDimension)
#endif
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
#if os(iOS)
                    .hoverEffect(.lift)
#endif
                }
            }
        }
    }
    
    public var body: some View {
#if !os(macOS)
        NavigationView {
            ZStack {
#if os(iOS)
                Self.backgroundColor.edgesIgnoringSafeArea(.all)
#endif
                searchableSymbolGrid
            }
#if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
#endif
            
#if !os(tvOS)
            /// tvOS can use back button on remote
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(i18n("cancel")) {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
#endif
        }
        .navigationViewStyle(.stack)
#else
        searchableSymbolGrid
            .frame(width: 540, height: 320, alignment: .center)
#endif
    }
}

#Preview {
    SymbolPicker(symbol: .constant("square.and.arrow.up"))
}
