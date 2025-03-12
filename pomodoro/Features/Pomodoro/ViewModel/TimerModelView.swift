import Foundation
import SwiftUI

class TimerViewModel: ObservableObject {
    @Published var timeElapsed: Int = 0
    @Published var totalTime: Int
    @Published var isRunning: Bool = false
    @Published var currentCycle: Int = 1
    @Published var isPomodoro: Bool = true
    @Published var totalCycles: Int
    @Published var showAlert: Bool = false
    @Published var isRestTimeAlert: Bool = false
    @Published var showResetConfirmation: Bool = false
    
    private var timer: Timer?
    private var settingsViewModel: SettingsViewModel
    
    init(minutes: Int, seconds: Int, settingsViewModel: SettingsViewModel) {
        self.totalTime = (minutes * 60) + seconds
        self.settingsViewModel = settingsViewModel
        self.totalCycles = settingsViewModel.pomodoroCycles
    }
    
    func startTimer() {
        timer?.invalidate()
        isRunning = true
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            
            if self.timeElapsed < self.totalTime {
                self.timeElapsed += 1
            } else {
                self.switchMode()
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
        
        // Mantém o mesmo tempo do modo atual
        if isPomodoro {
            totalTime = (settingsViewModel.selectedPomodoroTime ?? 30) * 60
        } else {
            totalTime = (settingsViewModel.selectedRestTime ?? 5) * 60
        }
    }
    
    func resetAll() {
        timer?.invalidate()
        timeElapsed = 0
        isRunning = false
        currentCycle = 1 // ❌ Isso faz com que ele volte ao primeiro ciclo
        isPomodoro = true // ❌ Isso sempre redefine para Pomodoro
        totalTime = (settingsViewModel.selectedPomodoroTime ?? 30) * 60
    }

    private func switchMode() {
        if isPomodoro {
            showAlert = true
        } else {
            isRestTimeAlert = true
        }
    }

    func startRestTime() {
        isPomodoro = false
        timeElapsed = 0
        totalTime = (settingsViewModel.selectedRestTime ?? 5) * 60
        startTimer()
    }
    
    func startPomodoro() {
        if currentCycle >= totalCycles {
            resetAll() // Se for o último ciclo, reseta tudo e para.
            return
        }
        
        isPomodoro = true
        timeElapsed = 0
        totalTime = (settingsViewModel.selectedPomodoroTime ?? 30) * 60
        currentCycle += 1 // Incrementa o ciclo ao iniciar um novo Pomodoro
        startTimer()
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
