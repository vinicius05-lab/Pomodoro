import SwiftUI
import AVKit

struct ContentView: View {
    let audioFileName = "alarm"
    @State private var isPlaying = false
    @State private var player: AVAudioPlayer?
    @State private var totalTime: TimeInterval = 0.0
    @State private var currentTime: TimeInterval = 0.0
    
    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)
            
            VStack {
                HStack {
                    VStack {
                        Text("Mountain Song")
                            .font(.title)
                        Slider(value: Binding(get: {
                            currentTime
                        }, set: { newValue in
                            seekaAudio(to: newValue)
                        }), in: 0...totalTime)
                        .accentColor(.white)
                        
                        HStack {
                            Text(timeString(time: currentTime))
                                .foregroundStyle(.white)
                            Spacer()
                            Text(timeString(time: totalTime))
                                .foregroundStyle(.white)
                        }
                        .padding(.horizontal)
                    }
                    .padding()
                    Image(systemName: isPlaying ? "pause.circle.fill" : "play.circle.fill")
                        .font(.largeTitle)
                        .onTapGesture {
                            //                            isPlaying.toggle()
                            isPlaying ? stopAudio() : playAudio()
                        }
                }
            }
            .foregroundStyle(.white)
        }
        .onAppear(perform: setupAudioPlayer)
        .onReceive(Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()) { _ in
            updateProgress()
        }
        
    }
    
    private func setupAudioPlayer() {
        guard let url = Bundle.main.url(forResource: audioFileName, withExtension: "wav") else {
            print("Audio não encontrado")
            return
        }
        
        do {
            player = try AVAudioPlayer(contentsOf: url)
            player?.prepareToPlay()
            totalTime = player?.duration ?? 0.0
        } catch {
            print("Erro ao carregar audio: \(error)")
        }
    }
    
    private func playAudio() {
        player?.play()
        isPlaying = true
    }
    
    private func stopAudio() {
        player?.pause()
        isPlaying = false
    }
    private func updateProgress() {
        guard let player = player else { return }
        currentTime = player.currentTime
    }
    
    private func seekaAudio(to time: TimeInterval) {
        player?.currentTime = time
    }
    
    private func timeString(time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

#Preview {
    ContentView()
}
