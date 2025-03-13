import SwiftUI

struct TimerPomodoro: View {
    @StateObject private var viewModel: TimerViewModel

    @EnvironmentObject var settingsViewModel: SettingsViewModel

    init(minutes: Int = 30, seconds: Int = 0, settingsViewModel: SettingsViewModel) {
        _viewModel = StateObject(wrappedValue: TimerViewModel(minutes: minutes, seconds: seconds, settingsViewModel: settingsViewModel))
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                if let title = settingsViewModel.goalTitle {
                    Text(title)
                        .font(.system(size: 20, weight: .bold))
                        .padding(.bottom, 130)
                        .padding(.top, -60)
                }
                
                ZStack {
                    
                    Circle()
                        .stroke(Color.gray.opacity(0.2), lineWidth: 20)
                        .frame(width: 283, height: 282)
                    
                    Circle()
                        .trim(from: CGFloat(viewModel.timeElapsed) / CGFloat(viewModel.totalTime), to: 1)
                        .stroke(
                            viewModel.isPomodoro ? .vermelhoPadrao:
                                !viewModel.isPomodoro && settingsViewModel.darkMode ? .orange:
                                    .green,
                            style: StrokeStyle(lineWidth: 20, lineCap: .round)
                        )
                        .rotationEffect(.degrees(-90))
                        .animation(.easeInOut(duration: 0.2), value: viewModel.timeElapsed)
                        .frame(width: 283, height: 282)
                    
                    Text(viewModel.formatTime())
                        .font(.system(size: 52))
                        .bold()
                }
                .padding(.top, -100)
                
                CycleIndicatorView(currentCycle: $viewModel.currentCycle, totalCycles: $viewModel.totalCycles)
                
                ZStack {
                    RoundedRectangle(cornerRadius: 20)
                        .frame(width: 151, height: 38)
                        .foregroundStyle(.bluishPurple)
                    
                    Text(viewModel.isPomodoro ? "Tempo de Foco": "Descanso")
                        .bold()
                        .foregroundStyle(.white)
                    
                }
                .padding(.bottom, 25)
                
                HStack(spacing: 60) {
                    VStack {
                        Button(action: {
                            viewModel.showResetConfirmation = true // Exibe o alerta antes de reiniciar
                        }) {
                            ZStack {
                                Circle()
                                    .frame(maxWidth: 65)
                                    .foregroundStyle(.white)
                                
                                Image(systemName: "arrow.counterclockwise.circle.fill")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(maxWidth: 65)
                            }
                        }
                        Text("Reiniciar")
                            .foregroundStyle(settingsViewModel.darkMode ? .white : .black)
                            .bold()
                    }
                    .alert("Tem certeza que deseja reiniciar?", isPresented: $viewModel.showResetConfirmation) {
                        Button("Cancelar", role: .cancel) {}
                        Button("Sim", role: .destructive) {
                            viewModel.resetTimer()
                        }
                    }

                    
                    VStack {
                        Button(action: {
                            if viewModel.isRunning {
                                viewModel.pauseTimer()
                            } else {
                                viewModel.startTimer()
                            }
                        }) {
                            ZStack {
                                Circle()
                                    .frame(maxWidth: 65)
                                    .foregroundStyle(.white)
                                
                                Image(systemName: viewModel.isRunning ? "pause.circle.fill" : "play.circle.fill")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(maxWidth: 65)
                            }
                        }
                        Text(viewModel.isRunning ? "Pausar" : "Iniciar")
                            .foregroundStyle(settingsViewModel.darkMode ? .white : .black)
                            .bold()
                    }
                }
                .foregroundStyle(.vermelhoPadrao)
            }
            .onAppear {
                let minutes = settingsViewModel.selectedPomodoroTime ?? 30
                viewModel.updateTime(minutes: minutes)
            }
            .onChange(of: settingsViewModel.pomodoroCycles) { _, newValue in
                viewModel.totalCycles = newValue
            }
            .alert("Tempo de foco acabou!", isPresented: $viewModel.showAlert) {
                Button("Ok") {
                    viewModel.startRestTime()
                    viewModel.stopAudio()
                    viewModel.stopVibrating()
                }
            } message: {
                Text("Agora é hora de descansar.")
            }
            .alert("Tempo de descanso acabou!", isPresented: $viewModel.isRestTimeAlert) {
                Button("Ok") {
                    viewModel.startPomodoro()
                    viewModel.stopAudio()
                    viewModel.stopVibrating()
                }
            } message: {
                Text("Agora é hora de focar novamente.")
            }
            .onAppear {
                if settingsViewModel.vibrate {
                    viewModel.startVibrating() // Inicia a vibração ao exibir o alerta
                }
            }
            .onChange(of: viewModel.showAlert) {
                if viewModel.showAlert {
                    viewModel.playAudio() // Toca o som quando o alerta de foco aparece
                }
            }
            .onChange(of: viewModel.isRestTimeAlert) {
                if viewModel.isRestTimeAlert {
                    viewModel.playAudio() // Toca o som quando o alerta de descanso aparece
                }
            }
            
            .toolbar { // 🔹 Adicionando a Toolbar
                ToolbarItem(placement: .principal) {
                    Text("Pomodoro")
                        .font(.title2)
                        .bold()
                }
            }
        }

    }
}

#Preview {
    TimerPomodoro(settingsViewModel: SettingsViewModel())
        .environmentObject(SettingsViewModel())
}
