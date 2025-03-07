import SwiftUI

@main
struct pomodoroApp: App {
    @StateObject private var settingsViewModel = SettingsViewModel() // Criar a instância aqui

    var body: some Scene {
        WindowGroup {
            TabBarView()
                .environmentObject(settingsViewModel)
                .modelContainer(for: GoalModel.self)
        }
    }
}
