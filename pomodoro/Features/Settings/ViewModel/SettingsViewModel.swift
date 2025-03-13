import SwiftUI

class SettingsViewModel: ObservableObject {
    @Published var selectedPomodoroTime: Int? = 30
    @Published var selectedRestTime: Int? = 5
    @Published var volume: Double = 0.5
    @AppStorage("isDarkMode") var darkMode = false
    @Published var vibrate = true
    @Published var selectedSound = "Alarme.mp3"
    @Published var pomodoroCycles: Int = 2
    @Published var goalTitle: String?
    @Published var goal: GoalModel?
}
