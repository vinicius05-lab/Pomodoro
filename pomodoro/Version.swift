import SwiftUI

struct Version: View {
    
    @State private var minutes: Int = 5
    @State private var seconds: Int
    @State private var isRunning: Bool = false
    
    private var initialMinutes: Int
    private var initialSeconds: Int
    
    init(minutes: Int, seconds: Int) {
        self.minutes = minutes
        self.seconds = seconds
        
        initialMinutes = minutes
        initialSeconds = seconds
    }
    
    var body: some View {
        VStack {
            Text(formatTime(mintes: minutes, seconds: seconds))
                .font(.system(size: 42, weight: .bold, design: .monospaced))
            
            HStack(spacing: 25) {
                
                Button(action: {
                    resetTime()
                }) {
                    Image(systemName: "arrow.counterclockwise.circle.fill")
                        .resizable()
                        .scaledToFit()
                        .foregroundStyle(.gray)
                        .frame(maxWidth: 60)
                }

                Button(action: {
                    isRunning.toggle()
                    startTime()
                }) {
                    Image(systemName: isRunning ? "pause.circle.fill" : "play.circle.fill")
                        .resizable()
                        .scaledToFit()
                        .foregroundStyle(.gray)
                        .frame(maxWidth: 60)
                }
                    
            }
        }
    }

    private func startTime() {
        if minutes > 0 || seconds > 0 {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                if isRunning {
                    decrementTime()
                    startTime()
                }
            }
        }
    }
    
    private func decrementTime() {
        if seconds > 0 {
            seconds -= 1
        } else if minutes > 0 {
            minutes -= 1
            seconds = 59
        }
    }
    
    private func resetTime() {
        isRunning = false
        minutes = initialMinutes
        seconds = initialSeconds
    }
    
    private func formatTime(mintes: Int, seconds: Int) -> String {
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

#Preview {
    TimerPomodoro(minutes: 5, seconds: 0)
}
