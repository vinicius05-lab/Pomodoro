import SwiftUI
import SwiftData

struct GoalView: View {
    
    @Environment(\.modelContext) private var context
    @Query private var goals: [GoalModel] = []
    
    var body: some View {
        NavigationStack {
            ScrollView { // Adicionando o ScrollView para rolar as metas
                VStack {
                    if goals.isEmpty {
                        VStack {
                            Text("Nenhuma meta cadastrada.")
                                .foregroundColor(.secondary)
                            
                            Spacer()
                        }
                    } else {
                        ForEach(goals) { goal in
                            ZStack {
                                RoundedRectangle(cornerRadius: 10)
                                    .frame(width: 363, height: 47)
                                    .foregroundColor(Color.vermelhoPadrao)
                                
                                HStack {
                                    Text(goal.title)
                                        .foregroundColor(.white)
                                        .frame(maxWidth: .infinity, alignment: .leading) 
                                    
                                    Spacer()
                                    
                                    HStack(spacing: 16) {
                                        Button(action: {
                                            context.delete(goal)
                                        }) {
                                            Image(systemName: "trash.circle")
                                                .font(.system(size: 24))
                                                .foregroundColor(.white) // Cor do ícone
                                        }
                                        
                                        NavigationLink(destination: GoalCreateView(goal: goal)) {
                                            Image(systemName: "ellipsis.circle")
                                                .font(.system(size: 24))
                                                .foregroundColor(.white) // Cor do ícone
                                        }
                                    }
                                }
                                .padding(.horizontal) // Ajuste o padding conforme necessário
                            }
                            .bold()
                            .foregroundStyle(.white)
                            .padding(.vertical, 5)
                        }

                    }
                    
                    Spacer()
                }
                .padding(.horizontal) // Ajustando o padding horizontal
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
    }
}


struct GoalCreateView: View {
    
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    
    @State private var title: String = ""
    @State private var descript: String = ""
    @State private var scheduledDate: Date = Date()
    @State private var isScheduled: Bool = false // Variável para controlar a caixa de seleção
    
    private let model = SettingsModel()
    @EnvironmentObject private var viewModel: SettingsViewModel
    
    @State var goal: GoalModel?
    
    /*if let goal {
        goal.scheduledDate ? isScheduled = true : isScheduled = false
    }*/
    
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
                        
                        if let goal = goal {
                            goal.title = title
                            goal.descript = descript
                            goal.scheduledDate = isScheduled ? scheduledDate : nil
                            goal.pomodoroTimer = viewModel.selectedPomodoroTime!
                            goal.restTimer = viewModel.selectedRestTime!
                            goal.pomodoroCycles = viewModel.pomodoroCycles
                        } else {
                            // Se o usuário optou por agendar, passa a data, caso contrário passa nil
                            let goalModel: GoalModel = GoalModel(
                                title: title,
                                descript: descript,
                                pomodoroTimer: viewModel.selectedPomodoroTime!,
                                restTimer: viewModel.selectedRestTime!,
                                pomodoroCycles: viewModel.pomodoroCycles,
                                scheduledDate: isScheduled ? scheduledDate : nil
                            )
                            
                            context.insert(goalModel)
                        }
                        
                        dismiss()
                    }) {
                        Text("Salvar")
                    }
                }
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
}

#Preview {
    GoalView()
        .environmentObject(SettingsViewModel())
        .modelContainer(for: GoalModel.self)
}
