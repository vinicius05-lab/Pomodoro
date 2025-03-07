import SwiftUI

struct TimerPomodoro: View {
    @StateObject private var viewModel: TimerViewModel
    @EnvironmentObject var settingsViewModel: SettingsViewModel
    
    init(minutes: Int = 30, seconds: Int = 0) {
           _viewModel = StateObject(wrappedValue: TimerViewModel(minutes: minutes, seconds: seconds, settingsViewModel: SettingsViewModel()))
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                /*HStack {
                    Text("Pomodoro")
                        .font(.system(size: 25, weight: .bold))
                        .foregroundColor(.black)
                }
                .frame(maxWidth: .infinity)
                .padding(.top, 10)
                .padding(.bottom, 10)*/
                
                ZStack {
                    Circle()
                        .stroke(Color.gray.opacity(0.2), lineWidth: 20)
                        .frame(width: 283, height: 282)
                    
                    Circle()
                        .trim(from: CGFloat(viewModel.timeElapsed) / CGFloat(viewModel.totalTime), to: 1)
                        .stroke(
                            viewModel.isPomodoro ? .vermelhoPadrao: .green,
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
                //.padding()
                
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
                            viewModel.resetTimer()
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
    TimerPomodoro()
        .environmentObject(SettingsViewModel())
}
