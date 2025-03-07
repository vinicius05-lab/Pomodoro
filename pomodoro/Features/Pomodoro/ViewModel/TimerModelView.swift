import Foundation
import SwiftUI

class TimerViewModel: ObservableObject {
    @Published var timeElapsed: Int = 0
    @Published var totalTime: Int
    @Published var isRunning: Bool = false
    @Published var currentCycle: Int = 1
    @Published var isPomodoro: Bool = true
    @Published var totalCycles: Int
    
    private var timer: Timer?
    private var settingsViewModel: SettingsViewModel
    
    init(minutes: Int, seconds: Int, settingsViewModel: SettingsViewModel) {
        self.totalTime = (minutes * 60) + seconds
        self.settingsViewModel = settingsViewModel
        self.totalCycles = settingsViewModel.pomodoroCycles // Definir ciclos com base na configuração
    }
    
    func startTimer() {
        isRunning = true
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            
            if self.timeElapsed < self.totalTime {
                self.timeElapsed += 1
            } else {
                self.switchMode() // Alternar entre Pomodoro e descanso automaticamente
            }
        }
    }
    
    func pauseTimer() {
        isRunning = false
        timer?.invalidate()
    }
    
    func resetTimer() {
        timer?.invalidate()
        timeElapsed = 0
        isRunning = false
    }
    
    private func switchMode() {
        let wasRunning = isRunning // Armazena o estado antes da troca

        isPomodoro.toggle()
        timeElapsed = 0

        if isPomodoro {
            totalTime = (settingsViewModel.selectedPomodoroTime ?? 30) * 60
            currentCycle += 1
            if currentCycle > totalCycles {
                currentCycle = 1
            }
            
        } else {
            totalTime = (settingsViewModel.selectedRestTime ?? 5) * 60
        }

        if wasRunning {
            startTimer()
        } else {
            pauseTimer() // Garante que o botão de pausa continue funcionando no descanso
        }
    }

    
    func updateTime(minutes: Int) {
        totalTime = minutes * 60
        timeElapsed = 0
    }
    
    func formatTime() -> String {
        let remainingTime = totalTime - timeElapsed
        let minutes = remainingTime / 60
        let seconds = remainingTime % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}
