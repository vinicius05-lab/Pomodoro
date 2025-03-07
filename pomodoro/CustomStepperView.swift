import SwiftUI

struct CustomStepperView: View {
    @Binding var value: Int // Agora usa um Binding ao invés de @State

    var body: some View {
        HStack(spacing: 0) {
            Button(action: { if value > 1 { value -= 1 } }) {
                Image(systemName: "minus")
                    .frame(width: 30, height: 30)
                    .background(Color(.systemGray5))
                    .cornerRadius(5, corners: [.topLeft, .bottomLeft])
            }

            Text("\(value)")
                .font(.title2)
                .frame(minWidth: 40)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 8)

            Button(action: { if value < 10 { value += 1 } }) {
                Image(systemName: "plus")
                    .frame(width: 30, height: 30)
                    .background(Color(.systemGray5))
                    .cornerRadius(5, corners: [.topRight, .bottomRight])
            }
        }
        .overlay(
            RoundedRectangle(cornerRadius: 5)
                .stroke(Color.gray, lineWidth: 1)
        )
    }
}

// Extensão para arredondar cantos específicos
extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat
    var corners: UIRectCorner

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}
