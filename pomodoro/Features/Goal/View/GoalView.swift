import SwiftUI
import SwiftData

struct GoalView: View {
    
    @Environment(\.modelContext) private var context
    @Query private var goals: [GoalModel] = []
    
    var body: some View {
        NavigationStack {
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
                                    .padding(.trailing, 220)
                                
                                HStack(spacing: 16) {
                                    Button(action: {
                                        context.delete(goal)
                                    }) {
                                        Image(systemName: "trash.circle")
                                            .font(.system(size: 24))
                                    }
                                    
                                    NavigationLink(destination: GoalCreateView()) {
                                        Image(systemName: "ellipsis.circle")
                                            .font(.system(size: 24))
                                    }
                                }
                            }
                        }
                        .bold()
                        .foregroundStyle(.white)
                    }
                }
                
                Spacer()
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
    
    private let model = SettingsModel()
    @EnvironmentObject private var viewModel: SettingsViewModel
    
    var body: some View {
        GeometryReader { geometry in
            VStack (alignment: .leading, spacing: 25){
                
                CustomTextField(title: "Title", text: $title)
                    .padding(.top, -30)
                
                CustomTextField(title: "Description", text: $descript)
                
                VStack(alignment: .leading, spacing: 8) {
                        Text("Agendar para:")
                            .font(.system(size: 20))
                            .bold()
                                   
                        DatePicker("Escolha a data e hora", selection: $scheduledDate, displayedComponents: [.date, .hourAndMinute])
                            .datePickerStyle(.compact)
                }
                
                Text("Tempo Pomodoro")
                    .font(.system(size: 25))
                    .bold()
                
                createTimeSelectionRow(
                    times: model.pomodoroTimes,
                    width: geometry.size.width * 0.2,
                    selectedTime: $viewModel.selectedPomodoroTime
                )
                
                HStack {
                    Text("Ciclos de Pomodoro")
                        .font(.system(size: 25))
                        .bold()
                    Spacer()
                    CustomStepperView(value: $viewModel.pomodoroCycles)
                }
                
                Text("Tempo de Descanso")
                    .font(.system(size: 25))
                    .bold()
                
                createTimeSelectionRow(
                    times: model.restTimes,
                    width: geometry.size.width * 0.2,
                    selectedTime: $viewModel.selectedRestTime
                )
            }
            .padding()
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Nova Meta")
                        .bold()
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        let goal: GoalModel = GoalModel(title: title, descript: descript, pomodoroTimer: viewModel.selectedPomodoroTime!, restTimer: viewModel.selectedRestTime!, pomodoroCycles: viewModel.pomodoroCycles)
                        
                        context.insert(goal)
                        
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
