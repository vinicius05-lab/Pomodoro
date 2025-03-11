import SwiftData
import Foundation

@Model
class TimerStateModel: Identifiable {
    @Attribute(.unique) var id: UUID = UUID()
    var timeElapsed: Int
    var totalTime: Int
    var isRunning: Bool
    var currentCycle: Int
    var isPomodoro: Bool
    var totalCycles: Int
    
    init(timeElapsed: Int, totalTime: Int, isRunning: Bool, currentCycle: Int, isPomodoro: Bool, totalCycles: Int) {
        self.timeElapsed = timeElapsed
        self.totalTime = totalTime
        self.isRunning = isRunning
        self.currentCycle = currentCycle
        self.isPomodoro = isPomodoro
        self.totalCycles = totalCycles
    }
}
