import Foundation
import AVFoundation
import Combine

@MainActor
final class TimerEngine: ObservableObject {
    // Countdown state
    @Published var remainingSeconds: Int
    @Published var totalMinutes: Int = 25 {
        didSet { if !isRunning { remainingSeconds = totalMinutes * 60 } }
    }
    @Published var isRunning: Bool = false

    // Random duration mode
    @Published var useRandomDuration: Bool = false
    @Published var minRandomMinutes: Double = 15
    @Published var maxRandomMinutes: Double = 45

    // Random sound cue settings
    @Published var soundEnabled: Bool = true
    @Published var minCooldownSeconds: Double = 45
    @Published var maxCooldownSeconds: Double = 120

    private var tickTimer: Timer?
    private var nextCueDate: Date?
    private var player: AVAudioPlayer?

    init() {
        remainingSeconds = 25 * 60
        loadPlayer()
    }

    private func loadPlayer() {
        guard let url = Bundle.module.url(forResource: "tick", withExtension: "mp3") else {
            print("CTUClock: could not locate tick.mp3 in bundle resources")
            return
        }
        do {
            player = try AVAudioPlayer(contentsOf: url)
            player?.prepareToPlay()
        } catch {
            print("CTUClock: failed to load audio player: \(error)")
        }
    }

    var formattedTime: String {
        let m = remainingSeconds / 60
        let s = remainingSeconds % 60
        return String(format: "%02d:%02d", m, s)
    }

    func start() {
        if remainingSeconds <= 0 {
            remainingSeconds = resolveDurationSeconds()
        }
        guard !isRunning else { return }
        isRunning = true
        scheduleNextCue()
        tickTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            Task { @MainActor in self?.tick() }
        }
    }

    func pause() {
        isRunning = false
        tickTimer?.invalidate()
        tickTimer = nil
    }

    func reset() {
        pause()
        remainingSeconds = resolveDurationSeconds()
        nextCueDate = nil
    }

    private func resolveDurationSeconds() -> Int {
        if useRandomDuration {
            let lo = Int(min(minRandomMinutes, maxRandomMinutes))
            let hi = Int(max(minRandomMinutes, maxRandomMinutes))
            return Int.random(in: lo...hi) * 60
        } else {
            return totalMinutes * 60
        }
    }

    private func tick() {
        guard isRunning else { return }

        if remainingSeconds <= 0 {
            pause()
            playCue()
            return
        }

        remainingSeconds -= 1

        if soundEnabled, let cueDate = nextCueDate, Date() >= cueDate {
            playCue()
            scheduleNextCue()
        }

        if remainingSeconds == 0 {
            pause()
            playCue()
        }
    }

    private func scheduleNextCue() {
        let lo = min(minCooldownSeconds, maxCooldownSeconds)
        let hi = max(minCooldownSeconds, maxCooldownSeconds)
        let interval = Double.random(in: lo...hi)
        nextCueDate = Date().addingTimeInterval(interval)
    }

    func playCue() {
        guard soundEnabled, let player else { return }
        player.currentTime = 0
        player.play()
    }
}
