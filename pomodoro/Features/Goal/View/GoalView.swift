import SwiftUI
import SwiftData
import UserNotifications

struct GoalView: View {
    @Environment(\.modelContext) private var context
    @Query var goals: [GoalModel]
    
    @EnvironmentObject private var settingsViewModel: SettingsViewModel
    @Binding var selectedTab: Int // Adicione um Binding para a aba ativa
    
    @State private var showDeleteConfirmation: Bool = false
    @State private var goalToDelete: GoalModel?

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack {
                    if goals.isEmpty {
                        Text("Nenhuma meta cadastrada.")
                            .foregroundColor(.secondary)
                    } else {
                        ForEach(goals) { goal in
                            ZStack {
                                RoundedRectangle(cornerRadius: 10)
                                    .frame(width: 363, height: 47)
                                    .foregroundColor(goal.isChecked && settingsViewModel.darkMode ? .orange : goal.isChecked && !settingsViewModel.darkMode ? Color.green : Color.vermelhoPadrao)
                                    .onTapGesture {
                                        // Define as configurações do Pomodoro com os valores da meta
                                        settingsViewModel.selectedPomodoroTime = goal.pomodoroTimer
                                        settingsViewModel.selectedRestTime = goal.restTimer
                                        settingsViewModel.pomodoroCycles = goal.pomodoroCycles
                                        
                                        // Muda para a aba do Pomodoro
                                        selectedTab = 0
                                    }

                                HStack {
                                    CheckboxView(isChecked: Binding(
                                        get: { goal.isChecked },
                                        set: { newValue in
                                            goal.isChecked = newValue
                                            try? context.save()
                                        }
                                    ))
                                    
                                    Text(goal.title)
                                        .foregroundColor(.white)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                    
                                    Spacer()
                                    
                                    HStack(spacing: 16) {
                                        Button(action: {
                                            showDeleteConfirmation = true
                                            goalToDelete = goal
                                        }) {
                                            Image(systemName: "trash.circle")
                                                .font(.system(size: 24))
                                                .foregroundColor(.white)
                                        }
                                        
                                        NavigationLink(destination: GoalCreateView(goal: goal)) {
                                            Image(systemName: "ellipsis.circle")
                                                .font(.system(size: 24))
                                                .foregroundColor(.white)
                                        }
                                    }
                                }
                                .padding(.horizontal)
                            }
                            .bold()
                            .foregroundStyle(.white)
                            .padding(.vertical, 5)
                        }
                    }
                    Spacer()
                }
                .padding(.horizontal)
            }
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Metas")
                        .font(.title2)
                        .bold()
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink(destination: GoalCreateView()) {
                        Image(systemName: "plus")
                    }
                }
            }
        }
        .alert("Tem certeza de que deseja deletar esta meta?", isPresented: $showDeleteConfirmation) {
            Button("Cancelar", role: .cancel) {}
            Button("Sim", role: .destructive) {
                self.showDeleteConfirmation = true
                if let goal = goalToDelete {
                    context.delete(goal)
                    try? context.save()
                }
            }
        }
    }
}

struct GoalCreateView: View {
    
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    
    @State private var title: String = ""
    @State private var descript: String = ""
    @State private var scheduledDate: Date = Date()
    @State private var isScheduled: Bool = false // Variável para controlar a caixa de seleção
    @State private var showMessageTitleEmpty: Bool = false
    
    private let model = SettingsModel()
    @EnvironmentObject private var viewModel: SettingsViewModel
    
    @State var goal: GoalModel?
    
    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                VStack(alignment: .leading, spacing: 25) {
                    
                    CustomTextField(title: "Title", text: $title)
                        .padding(.top, -30)
                    
                    CustomTextField(title: "Description", text: $descript)
                    
                    // Caixa de seleção para agendar ou não
                    Toggle(isOn: $isScheduled) {
                        Text("Definir data para a meta:")
                            .font(.system(size: 20))
                            .bold()
                    }
                    .tint(.vermelhoPadrao)
                    .padding(.top, 10)
                    
                    // Exibe o DatePicker apenas se a caixa de seleção estiver marcada
                    if isScheduled {
                        VStack(alignment: .leading, spacing: 8) {
                            DatePicker("Escolha a data e hora", selection: $scheduledDate, displayedComponents: [.date, .hourAndMinute])
                                .datePickerStyle(.compact)
                        }
                    }
                    
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
                }
                .padding()
                .onAppear {
                    requestNotificationPermission()
                    
                    if let goal = goal {
                        title = goal.title
                        descript = goal.descript
                        scheduledDate = goal.scheduledDate ?? Date()
                        isScheduled = goal.scheduledDate != nil
                        viewModel.selectedPomodoroTime = goal.pomodoroTimer
                        viewModel.selectedRestTime = goal.restTimer
                        viewModel.pomodoroCycles = goal.pomodoroCycles
                    }
                }
            }
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Nova Meta")
                        .bold()
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        
                        if title.isEmpty {
                            showMessageTitleEmpty = true
                            return
                        }
                        
                        if let goal = goal {
                            goal.title = title
                            goal.descript = descript
                            goal.scheduledDate = isScheduled ? scheduledDate : nil
                            goal.pomodoroTimer = viewModel.selectedPomodoroTime!
                            goal.restTimer = viewModel.selectedRestTime!
                            goal.pomodoroCycles = viewModel.pomodoroCycles
                            
                            if isScheduled {
                                scheduleNotification(for: goal)
                            }
                            
                        } else {
                            if title.isEmpty {
                                showMessageTitleEmpty = true
                                return
                            }
                            
                            let goalModel: GoalModel = GoalModel(
                                title: title,
                                descript: descript,
                                pomodoroTimer: viewModel.selectedPomodoroTime!,
                                restTimer: viewModel.selectedRestTime!,
                                pomodoroCycles: viewModel.pomodoroCycles,
                                scheduledDate: isScheduled ? scheduledDate : nil
                            )
                            
                            context.insert(goalModel)
                            
                            if isScheduled {
                                scheduleNotification(for: goalModel)
                            }
                        }
                        
                        dismiss()
                    }) {
                        Text("Salvar")
                    }
                }
            }
            .alert("Título é obrigatório", isPresented: $showMessageTitleEmpty) {
                Button("OK", role: .cancel) {}
            } message: {
                Text("Por favor, preencha o título antes de salvar")
            }
        }
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
                .environmentObject(viewModel)
            }
        }
        .frame(maxWidth: .infinity)
    }
    
    func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error = error {
                print("Erro ao solicitar permissão: \(error.localizedDescription)")
            } else {
                print("Permissão concedida: \(granted)")
            }
        }
    }
    
    func scheduleNotification(for goal: GoalModel) {
        let content = UNMutableNotificationContent()
        content.title = "Lembrete de Meta 📌"
        content.body = "Sua meta '\(goal.title)' está programada para agora!"
        content.sound = .default
        
        // Criando o trigger baseado na data definida pelo usuário
        guard let scheduledDate = goal.scheduledDate else { return }
        let triggerDate = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: scheduledDate)
        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: false)
        
        // Criando a requisição da notificação
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        
        // Adicionando a notificação ao sistema
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Erro ao agendar notificação: \(error.localizedDescription)")
            } else {
                print("Notificação agendada para \(scheduledDate)")
            }
        }
    }
    
}

#Preview {
    GoalView(selectedTab: .constant(0)) // Passando um Binding válido
        .environmentObject(SettingsViewModel()) // Injetando o ViewModel
        .modelContainer(for: GoalModel.self) // Configurando SwiftData
}
