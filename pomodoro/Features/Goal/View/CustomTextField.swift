import SwiftUI

struct CustomTextField: View {
    var title: String
    @Binding var text: String

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(title)
                .font(.system(size: 20))
                .bold()

            TextField("", text: $text)
                .padding(12)
                .background(Color.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.gray.opacity(0.5), lineWidth: 1)
                )
                .padding(10)
                .shadow(color: Color.gray.opacity(0.3), radius: 2, x: 0, y: 2)
            
        }
    }
}
