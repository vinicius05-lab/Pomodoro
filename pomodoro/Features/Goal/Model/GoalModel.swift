import Foundation
import SwiftData

@Model
class GoalModel {
    var id: UUID
    var title: String
    var descript: String
    var pomodoroTimer: Int
    var restTimer: Int
    var pomodoroCycles: Int
    
    init(title: String, descript: String, pomodoroTimer: Int, restTimer: Int, pomodoroCycles: Int) {
        self.id = UUID()
        self.title = title
        self.descript = descript
        self.pomodoroTimer = pomodoroTimer
        self.restTimer = restTimer
        self.pomodoroCycles = pomodoroCycles
    }
}
