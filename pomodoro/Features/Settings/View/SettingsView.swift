import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var timerViewModel: TimerViewModel
    
    private let model = SettingsModel()
    @EnvironmentObject private var viewModel: SettingsViewModel
    @State private var tempSelectedPomodoroTime: Int?
    @State private var tempSelectedRestTime: Int?
    @State private var tempPomodoroCycles: Int
    @State private var tempVolume: Double
    @AppStorage("darkMode") private var tempDarkMode: Bool = false
    @State private var tempVibrate: Bool
    @State private var tempSelectedSound: String
    @State private var showAlert: Bool = false

    init() {
        _tempSelectedPomodoroTime = State(initialValue: 30)
        _tempSelectedRestTime = State(initialValue: 5)
        _tempPomodoroCycles = State(initialValue: 2)
        _tempVolume = State(initialValue: 0.5)
        _tempVibrate = State(initialValue: true)
        _tempSelectedSound = State(initialValue: "Alarme.mp3")
    }

    var body: some View {
        NavigationStack {
            GeometryReader { geometry in
                VStack(alignment: .leading, spacing: 25) {
                    Text("Tempo Pomodoro")
                        .font(.system(size: 20))
                        .bold()
                    createTimeSelectionRow(
                        times: model.pomodoroTimes,
                        width: geometry.size.width * 0.2,
                        selectedTime: $tempSelectedPomodoroTime
                    )

                    HStack {
                        Text("Ciclos de Pomodoro")
                            .font(.system(size: 20))
                            .bold()
                        Spacer()
                        CustomStepperView(value: $tempPomodoroCycles)
                    }

                    Text("Tempo de Descanso")
                        .font(.system(size: 20))
                        .bold()
                    createTimeSelectionRow(
                        times: model.restTimes,
                        width: geometry.size.width * 0.2,
                        selectedTime: $tempSelectedRestTime
                    )

                    HStack {
                        Text("Som")
                            .font(.system(size: 20))
                            .bold()
                        Image(systemName: getVolumeIcon())
                            .font(.system(size: 30))
                            .padding(.leading, 3)
                            .foregroundStyle(.vermelhoPadrao)
                    }
                    .frame(height: 25)
                    Slider(value: $tempVolume, in: 0...1)

                    HStack {
                        Text("Modo Escuro")
                            .font(.system(size: 20))
                            .bold()
                        Spacer()
                        Toggle("", isOn: $tempDarkMode)
                            .tint(.vermelhoPadrao)
                    }
                    .padding(.top, 10)

                    HStack {
                        Text("Vibrar")
                            .font(.system(size: 20))
                            .bold()
                        Spacer()
                        Toggle("", isOn: $tempVibrate)
                            .tint(.vermelhoPadrao)
                    }

                    HStack {
                        Text("Som do Alarme")
                            .font(.system(size: 20))
                            .bold()
                        Spacer()
                        Menu {
                            Picker("Som", selection: $tempSelectedSound) {
                                ForEach(model.sounds, id: \.self) { sound in
                                    Text(sound).tag(sound)
                                }
                            }
                        } label: {
                            Text(tempSelectedSound)
                                .foregroundColor(.blue)
                        }
                    }
                }
                .padding()
            }
            .padding(.top, -40)
            .preferredColorScheme(tempDarkMode ? .dark : .light)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Configurações")
                        .bold()
                        .font(.title2)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Salvar") {
                        showAlert = true
                    }
                    .bold()
                }
            }
            .alert("Tem certeza que deseja salvar as alterações?", isPresented: $showAlert) {
                Button("Cancelar", role: .cancel) {}
                Button("Salvar", role: .destructive) { salvarConfiguracoes() }
            } message: {
                Text("As alterações feitas vão alterar o estado atual da aplicação.")
            }
        }
    }
    
    private func salvarConfiguracoes() {
        viewModel.selectedPomodoroTime = tempSelectedPomodoroTime
        viewModel.pomodoroCycles = tempPomodoroCycles
        viewModel.selectedRestTime = tempSelectedRestTime
        viewModel.volume = tempVolume
        viewModel.darkMode = tempDarkMode
        viewModel.vibrate = tempVibrate
        viewModel.selectedSound = tempSelectedSound

        timerViewModel.resetAll()
    }

    private func createTimeSelectionRow(times: [Int], width: CGFloat, selectedTime: Binding<Int?>) -> some View {
        HStack(spacing: 16) {
            ForEach(times, id: \.self) { time in
                TimeBox(
                    time: time,
                    width: width,
                    isSelected: selectedTime.wrappedValue == time,
                    onSelect: { selectedTime.wrappedValue = time }
                )
                .environmentObject(viewModel)
            }
        }
        .frame(maxWidth: .infinity)
    }

    private func getVolumeIcon() -> String {
        switch tempVolume {
        case 0: return "speaker.slash.fill"
        case 0.15..<0.4: return "speaker.wave.1.fill"
        case 0.4..<0.6: return "speaker.wave.2.fill"
        case 0.6...1: return "speaker.wave.3.fill"
        default: return "speaker.fill"
        }
    }
}

struct TimeBox: View {
    let time: Int
    let width: CGFloat
    let isSelected: Bool
    let onSelect: () -> Void

    @Environment(\.colorScheme) var colorScheme  // Detecta o modo escuro do sistema

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .fill(isSelected ? Color.vermelhoPadrao : (colorScheme == .dark ? Color.gray.opacity(0.3) : Color.white)) // Ajusta o fundo corretamente
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
            .foregroundColor(isSelected ? .white : (colorScheme == .dark ? .white : .black)) // Ajusta a cor do texto
        }
    }
}
#Preview {
    SettingsView()
        .environmentObject(SettingsViewModel())
}
