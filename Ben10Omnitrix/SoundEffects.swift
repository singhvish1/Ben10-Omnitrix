import AVFoundation

final class SoundEffects {
    static let shared = SoundEffects()

    private let engine = AVAudioEngine()
    private let player = AVAudioPlayerNode()

    private init() {
        engine.attach(player)
        let outputFormat = engine.mainMixerNode.outputFormat(forBus: 0)
        engine.connect(player, to: engine.mainMixerNode, format: outputFormat)
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
        let format = engine.mainMixerNode.outputFormat(forBus: 0)
        let sampleRate = Float(format.sampleRate)
        let channelCount = Int(format.channelCount)
        let frameCount = AVAudioFrameCount(sampleRate * duration)
        guard channelCount > 0,
              sampleRate > 0,
              let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: frameCount),
              let samples = buffer.floatChannelData else { return }

        buffer.frameLength = frameCount
        for frame in 0..<Int(frameCount) {
            let progress = Float(frame) / Float(frameCount)
            let frequency = startFrequency + ((endFrequency - startFrequency) * progress)
            let envelope = min(progress * 18, 1) * min((1 - progress) * 18, 1)
            let sample = sin(2 * .pi * frequency * Float(frame) / sampleRate) * volume * envelope
            for channel in 0..<channelCount {
                samples[channel][frame] = sample
            }
        }

        if !engine.isRunning {
            guard (try? engine.start()) != nil else { return }
        }
        player.stop()
        player.scheduleBuffer(buffer)
        player.play()
    }
}
