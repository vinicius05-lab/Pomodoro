import SwiftUI

struct SettingsView: View {
    private let model = SettingsModel()
    @EnvironmentObject private var viewModel: SettingsViewModel

    var body: some View {
        GeometryReader { geometry in
            VStack(alignment: .leading, spacing: 25) {
                
                Text("Tempo Pomodoro")
                    .font(.system(size: 20))
                    .bold()
                
                createTimeSelectionRow(
                    times: model.pomodoroTimes,
                    width: geometry.size.width * 0.2,
                    selectedTime: $viewModel.selectedPomodoroTime
                )
                
                HStack {
                    Text("Ciclos de Pomodoro")
                        .font(.system(size: 20))
                        .bold()
                    Spacer()
                    CustomStepperView(value: $viewModel.pomodoroCycles)
                }
                
                Text("Tempo de Descanso")
                    .font(.system(size: 20))
                    .bold()
                
                createTimeSelectionRow(
                    times: model.restTimes,
                    width: geometry.size.width * 0.2,
                    selectedTime: $viewModel.selectedRestTime
                )
                
                HStack {
                    Text("Som")
                        .font(.system(size: 20))
                        .bold()
             
                    Image(systemName:
                            viewModel.volume == 0 ? "speaker.slash.fill" :
                            viewModel.volume >= 0.15 && viewModel.volume < 0.4 ? "speaker.wave.1.fill" :
                            viewModel.volume >= 0.4 && viewModel.volume < 0.6 ? "speaker.wave.2.fill" :
                            viewModel.volume >= 0.6 ? "speaker.wave.3.fill" :
                           "speaker.fill"
                    )
                        .font(.system(size: 30))
                        .padding(.leading, 3)
                        .foregroundStyle(.vermelhoPadrao)
                }
                .frame(height: 25)
                
                Slider(value: $viewModel.volume, in: 0...1)

                HStack {
                    Text("Modo Escuro")
                        .font(.system(size: 20))
                        .bold()
                    Spacer()
                    Toggle("", isOn: $viewModel.darkMode)
                        .tint(.vermelhoPadrao)
                }
                .padding(.top, 10)
                
                HStack {
                    Text("Vibrar")
                        .font(.system(size: 20))
                        .bold()
                    Spacer()
                    Toggle("", isOn: $viewModel.vibrate)
                        .tint(.vermelhoPadrao)
                }
                
                HStack {
                    Text("Som do Alarme")
                        .font(.system(size: 20))
                        .bold()
                    Spacer()
                    Menu {
                        Picker("Som", selection: $viewModel.selectedSound) {
                            ForEach(model.sounds, id: \.self) { sound in
                                Text(sound).tag(sound)
                            }
                        }
                    } label: {
                        Text(viewModel.selectedSound)
                            .foregroundColor(.blue) // Aplica a cor azul
                    }
                }
            }
            .padding()
        }
        .preferredColorScheme(viewModel.darkMode ? .dark : .light)
    }

    private func createTimeSelectionRow(times: [Int], width: CGFloat, selectedTime: Binding<Int?>) -> some View {
        HStack(spacing: 16) {
            ForEach(times, id: \.self) { time in
                TimeBox(
                    time: time,
                    width: width,
                    isSelected: selectedTime.wrappedValue == time,
                    onSelect: {
                        withAnimation { selectedTime.wrappedValue = time }
                    }
                )
                .environmentObject(viewModel) // Passando o viewModel para o TimeBox
            }
        }
        .frame(maxWidth: .infinity)
    }


    private func getVolumeIcon() -> String {
        switch viewModel.volume {
        case 0: return "speaker.slash.fill"
        case 0.15..<0.4: return "speaker.wave.1.fill"
        case 0.4..<0.6: return "speaker.wave.2.fill"
        case 0.6...1: return "speaker.wave.3.fill"
        default: return "speaker.fill"
        }
    }
}

struct SectionView<Content: View>: View {
    let title: String
    let content: Content

    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)
                .bold()
            content
        }
    }
}

struct TimeBox: View {
    let time: Int
    let width: CGFloat
    let isSelected: Bool
    let onSelect: () -> Void

    @EnvironmentObject var viewModel: SettingsViewModel // Obtendo o modo escuro

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .fill(isSelected ? Color.vermelhoPadrao : (viewModel.darkMode ? Color.black : Color.white)) // Alterna cores no Dark Mode
                .frame(width: width, height: width)
                .onTapGesture { onSelect() }
            
            VStack {
                Text("\(time)")
                    .font(.title)
                    .bold()
                
                Text("minutos")
                    .font(.subheadline)
                    .bold()
            }
            .foregroundColor(isSelected ? .white : (viewModel.darkMode ? .white : .black)) // Alterna cor do texto
        }
    }
}


#Preview {
    SettingsView()
        .environmentObject(SettingsViewModel())
}
