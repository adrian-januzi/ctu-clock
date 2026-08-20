import SwiftUI
import AppKit

@main
struct CTUClockApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    @StateObject private var engine = TimerEngine()

    var body: some Scene {
        MenuBarExtra {
            ControlPanel(engine: engine)
        } label: {
            Text(engine.formattedTime)
                .font(.system(.body, design: .monospaced).monospacedDigit())
        }
        .menuBarExtraStyle(.window)
    }
}

final class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApplication.shared.setActivationPolicy(.accessory)
    }
}

private let presetMinutes = [5, 10, 15, 20, 25, 30, 45, 60]

struct ControlPanel: View {
    @ObservedObject var engine: TimerEngine

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("CTU COUNTDOWN")
                .font(.caption)
                .fontWeight(.bold)
                .foregroundStyle(.secondary)

            Text(engine.formattedTime)
                .font(.system(size: 40, weight: .heavy, design: .monospaced))
                .foregroundStyle(Color(red: 0.85, green: 0.08, blue: 0.08))
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.vertical, 4)

            HStack(spacing: 8) {
                Button(engine.isRunning ? "Pause" : "Start") {
                    engine.isRunning ? engine.pause() : engine.start()
                }
                .keyboardShortcut(.defaultAction)

                Button("Reset") { engine.reset() }
            }

            Divider()

            Toggle("Random duration", isOn: $engine.useRandomDuration)
                .disabled(engine.isRunning)

            if engine.useRandomDuration {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Range: \(Int(engine.minRandomMinutes)) – \(Int(engine.maxRandomMinutes)) min")
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    HStack {
                        Text("Min")
                        Slider(value: $engine.minRandomMinutes, in: 1...90, step: 1)
                    }
                    HStack {
                        Text("Max")
                        Slider(value: $engine.maxRandomMinutes, in: 1...120, step: 1)
                    }
                }
                .disabled(engine.isRunning)
            } else {
                Picker("Duration", selection: $engine.totalMinutes) {
                    ForEach(presetMinutes, id: \.self) { m in
                        Text("\(m) min").tag(m)
                    }
                }
                .disabled(engine.isRunning)
            }

            Divider()

            HStack {
                Toggle("Play \"24\" clock sound", isOn: $engine.soundEnabled)
                Spacer()
                Button("Test") { engine.playCue() }
                    .disabled(!engine.soundEnabled)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text("Random interval: \(Int(engine.minCooldownSeconds))s – \(Int(engine.maxCooldownSeconds))s")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                HStack {
                    Text("Min")
                    Slider(value: $engine.minCooldownSeconds, in: 10...180, step: 5)
                }
                HStack {
                    Text("Max")
                    Slider(value: $engine.maxCooldownSeconds, in: 15...300, step: 5)
                }
            }

            Divider()

            Button("Quit CTU Clock") {
                NSApplication.shared.terminate(nil)
            }
        }
        .padding(16)
        .frame(width: 260)
    }
}
