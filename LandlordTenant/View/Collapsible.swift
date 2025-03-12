import SwiftUI

struct Collapsible<Content: View>: View {
    @State var label: () -> Text
    @State var content: () -> Content
    @State private var collapsed: Bool = true

    var body: some View {
        VStack {
            Button(action: {
                self.collapsed.toggle()
            }) {
                HStack {
                    self.label()
                        .font(.headline) // Use headline font
                        .fontWeight(.bold) // Make it bold
                    Spacer()
                    Image(systemName: self.collapsed ? "chevron.down" : "chevron.up")
                        .foregroundColor(.accentColor) // Use the accent color
                }
                .padding(.bottom, 1)
                .background(Color.white.opacity(0.01)) // Make entire row tappable
                .contentShape(Rectangle()) // Make entire row tappable
            }
            .buttonStyle(PlainButtonStyle())

            if !collapsed {
                content()
                    .padding(.top, 5)
            }
        }
        .padding(.bottom, 5)
    }
}
