import SwiftUI

struct TabBarView: View {
    @StateObject private var settingsViewModel = SettingsViewModel() // Cria a instância do ViewModel
    
    init() {
        // Define a aparência da TabBar
        let appearance = UITabBarAppearance()
        appearance.configureWithDefaultBackground() // Configura o fundo da tab bar
        appearance.backgroundColor = UIColor.systemBackground // Cor do sistema para o modo claro ou escuro
        
        // Aplica a aparência configurada à tab bar
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }

    var body: some View {
        TabView () {
            
            TimerPomodoro(settingsViewModel: settingsViewModel)
                .tabItem {
                    Label("Pomodoro", systemImage: "play.circle.fill")
                }
            
            SettingsView()
                .tabItem {
                    Label("Configurações", systemImage: "gearshape.fill")
                }
            
            GoalView()
                .tabItem {
                    Label("Metas", systemImage: "square.and.pencil")
                }
        }
        .environmentObject(settingsViewModel)
        .preferredColorScheme(settingsViewModel.darkMode ? .dark : .light)
    }
}

#Preview {
    TabBarView()
        .modelContainer(for: GoalModel.self)
}
