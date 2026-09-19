import AVFoundation

final class SoundEffects {
    static let shared = SoundEffects()

    private let engine = AVAudioEngine()
    private let player = AVAudioPlayerNode()

    private init() {
        engine.attach(player)
        engine.connect(player, to: engine.mainMixerNode, format: nil)
        try? engine.start()
    }

    func playDialTick() {
        playSweep(startFrequency: 620, endFrequency: 860, duration: 0.07, volume: 0.16)
    }

    func playActivation() {
        playSweep(startFrequency: 180, endFrequency: 920, duration: 0.42, volume: 0.3)
    }

    func playReset() {
        playSweep(startFrequency: 780, endFrequency: 260, duration: 0.28, volume: 0.22)
    }

    private func playSweep(startFrequency: Float, endFrequency: Float, duration: Float, volume: Float) {
        let format = AVAudioFormat(standardFormatWithSampleRate: 44_100, channels: 1)
        let frameCount = AVAudioFrameCount(44_100 * duration)
        guard let format, let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: frameCount),
              let samples = buffer.floatChannelData?[0] else { return }

        buffer.frameLength = frameCount
        for frame in 0..<Int(frameCount) {
            let progress = Float(frame) / Float(frameCount)
            let frequency = startFrequency + ((endFrequency - startFrequency) * progress)
            let envelope = min(progress * 18, 1) * min((1 - progress) * 18, 1)
            samples[frame] = sin(2 * .pi * frequency * Float(frame) / 44_100) * volume * envelope
        }

        if !engine.isRunning {
            try? engine.start()
        }
        player.stop()
        player.scheduleBuffer(buffer)
        player.play()
    }
}
