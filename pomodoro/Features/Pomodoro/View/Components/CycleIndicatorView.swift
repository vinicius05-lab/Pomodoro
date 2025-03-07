import SwiftUI

struct CycleIndicatorView: View {
    @Binding var currentCycle: Int
    @Binding var totalCycles: Int

    var body: some View {
        HStack(spacing: 8) {
            ForEach(0..<totalCycles, id: \.self) { index in
                Circle()
                    .frame(width: index < currentCycle ? 17 : 11, height: index < currentCycle ? 17 : 11)
                    .foregroundColor(index < currentCycle ? .vermelhoPadrao : .cinza)
            }
        }
        .padding(.bottom, 20)
    }
}
