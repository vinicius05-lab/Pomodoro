import SwiftUI

struct TabBarView: View {
    //@StateObject private var settingsViewModel = SettingsViewModel() // Cria a instância do ViewModel
    
    @StateObject private var timerViewModel: TimerViewModel = TimerViewModel(minutes: 30, seconds: 0, settingsViewModel: SettingsViewModel())
    
    @State private var selectedTab = 0
    
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
        TabView(selection: $selectedTab) {
            TimerPomodoro(/*settingsViewModel: timerViewModel.settingsViewModel*/)
                        .tabItem {
                            Label("Pomodoro", systemImage: "play.circle.fill")
                        }
                        .tag(0) // Defina um identificador para a aba
                    
                    SettingsView()
                        .tabItem {
                            Label("Configurações", systemImage: "gearshape.fill")
                        }
                        .tag(1)

                GoalView(selectedTab: $selectedTab) // Passe o binding da aba
                    .tabItem {
                            Label("Metas", systemImage: "square.and.pencil")
                    }
                    .tag(2)
        }
        .environmentObject(timerViewModel)
        .environmentObject(timerViewModel.settingsViewModel)
        .preferredColorScheme(timerViewModel.settingsViewModel.darkMode ? .dark : .light)
    }
}

#Preview {
    TabBarView()
        .modelContainer(for: GoalModel.self)
}
