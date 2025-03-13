import SwiftUI

struct CustomTextField: View {
    var title: String
    @Binding var text: String

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(title)
                .font(.system(size: 20))
                .bold()
                .foregroundColor(.primary) // Adapta-se ao tema claro/escuro

            TextField("", text: $text)
                .padding(12)
                .background(Color(UIColor.secondarySystemBackground)) // Fundo adaptável
                .cornerRadius(12) // Deixa os cantos arredondados
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.gray.opacity(0.5), lineWidth: 1)
                )
                .padding(10)
                .shadow(color: Color.gray.opacity(0.3), radius: 2, x: 0, y: 2)
        }
    }
}
