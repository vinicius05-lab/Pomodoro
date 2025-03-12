import SwiftUI

struct CheckboxView: View {
    @Binding var isChecked: Bool

    var body: some View {
        Button(action: {
            isChecked.toggle()
        }) {
            HStack {
                ZStack {
                    Image(systemName: "square.fill")
                        .foregroundColor(.white)
                        .font(.system(size: 20))
                    
                    /*Image(systemName: "square")
                        .foregroundColor(.black)
                        .font(.system(size: 20))*/
                    
                   if isChecked {
                        Image(systemName: "checkmark")
                           .foregroundColor(.vermelhoPadrao)
                           .font(.system(size: 15))
                           .bold()
                    }
                }
            }
        }
        .buttonStyle(.plain)
    }
}
