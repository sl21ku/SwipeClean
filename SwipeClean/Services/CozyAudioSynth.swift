// CozyAudioSynth.swift
// Native Swift programmatic audio synthesizer for SwipeClean cozy sounds.

import Foundation
import AVFoundation

final class CozyAudioSynth: Sendable {
    static let shared = CozyAudioSynth()
    
    private let engine: AVAudioEngine
    private let mainMixer: AVAudioMixerNode
    
    private init() {
        self.engine = AVAudioEngine()
        self.mainMixer = engine.mainMixerNode
        
        // Start engine in background
        do {
            try engine.start()
        } catch {
            print("Failed to start AVAudioEngine: \(error)")
        }
    }
    
    private func ensureEngineIsRunning() {
        guard !engine.isRunning else { return }
        do {
            try engine.start()
        } catch {
            print("Failed to restart AVAudioEngine: \(error)")
        }
    }
    
    // Play a synthesized sound defined by a frame-generation closure
    private func playSynthesizedSound(duration: Double, generator: @escaping @Sendable (Int64, Int64) -> Float) {
        ensureEngineIsRunning()
        
        let sampleRate: Double = 44100.0
        let format = AVAudioFormat(standardFormatWithSampleRate: sampleRate, channels: 1)!
        let maxFrames = Int64(duration * sampleRate)
        var elapsedFrames: Int64 = 0
        
        var sourceNode: AVAudioSourceNode?
        
        sourceNode = AVAudioSourceNode { _, _, frameCount, audioBufferList -> OSStatus in
            let abl = UnsafeMutableAudioBufferListPointer(audioBufferList)
            guard let buffer = abl[0].mData?.assumingMemoryBound(to: Float.self) else { return noErr }
            
            for frame in 0..<Int(frameCount) {
                let currentFrame = elapsedFrames + Int64(frame)
                if currentFrame >= maxFrames {
                    buffer[frame] = 0
                } else {
                    buffer[frame] = generator(currentFrame, maxFrames)
                }
            }
            
            elapsedFrames += Int64(frameCount)
            
            if elapsedFrames >= maxFrames {
                // Detach and clean up once finished to save CPU
                if let node = sourceNode {
                    DispatchQueue.global(qos: .userInitiated).async { [weak self] in
                        guard let self = self else { return }
                        self.engine.detach(node)
                    }
                }
            }
            return noErr
        }
        
        guard let node = sourceNode else { return }
        engine.attach(node)
        engine.connect(node, to: mainMixer, format: format)
    }
    
    // 1. Cozy paper shuffle sound (soft friction)
    func playPaperShuffle() {
        playSynthesizedSound(duration: 0.15) { currentFrame, maxFrames in
            let envelope = 1.0 - Float(currentFrame) / Float(maxFrames)
            let noise = Float.random(in: -1.0...1.0)
            return noise * 0.04 * envelope
        }
    }
    
    // 2. Snap/Keep sound (delightful woody click/camera shutter snap)
    func playSnapSound() {
        playSynthesizedSound(duration: 0.08) { currentFrame, maxFrames in
            let progress = Double(currentFrame) / Double(maxFrames)
            let freq = 800.0 + 800.0 * progress
            let phase = 2.0 * .pi * freq * (Double(currentFrame) / 44100.0)
            
            var sample = Float(sin(phase)) * 0.08 * Float(1.0 - progress)
            // Add click noise texture
            let noise = Float.random(in: -1.0...1.0)
            sample += noise * 0.02 * Float(1.0 - progress)
            return sample
        }
    }
    
    // 3. Trash/Discard sound (satisfying wood box drop / crumple thud)
    func playTrashSound() {
        playSynthesizedSound(duration: 0.25) { currentFrame, maxFrames in
            let progress = Double(currentFrame) / Double(maxFrames)
            let freq = 140.0 - 90.0 * progress
            let phase = 2.0 * .pi * freq * (Double(currentFrame) / 44100.0)
            
            var sample = Float(sin(phase)) * 0.12 * Float(1.0 - progress)
            // Add soft crumple noise texture
            let noise = Float.random(in: -1.0...1.0)
            sample += noise * 0.04 * Float(1.0 - progress)
            return sample
        }
    }
    
    // 4. Wooden slot spin tick
    func playSlotSpin() {
        playSynthesizedSound(duration: 0.02) { currentFrame, maxFrames in
            let progress = Double(currentFrame) / Double(maxFrames)
            let freq = 600.0 - 400.0 * progress
            let phase = 2.0 * .pi * freq * (Double(currentFrame) / 44100.0)
            return Float(sin(phase)) * 0.06 * Float(1.0 - progress)
        }
    }
    
    // 5. Cozy chime arpeggio for winning (C5 -> E5 -> G5 -> C6)
    func playWinChime() {
        playSynthesizedSound(duration: 1.2) { currentFrame, maxFrames in
            let notes = [523.25, 659.25, 783.99, 1046.50]
            let delayFrames = [0, 3528, 7056, 10584] // 0.08s delays at 44.1kHz
            
            var sample: Float = 0.0
            
            for (idx, freq) in notes.enumerated() {
                let startFrame = Int64(delayFrames[idx])
                if currentFrame >= startFrame {
                    let noteFrame = currentFrame - startFrame
                    let noteDurationFrames = maxFrames - startFrame
                    let progress = Double(noteFrame) / Double(noteDurationFrames)
                    let phase = 2.0 * .pi * freq * (Double(noteFrame) / 44100.0)
                    
                    let envelope = exp(-3.0 * progress) // Fast fade
                    sample += Float(sin(phase) + 0.3 * sin(phase * 2.0)) * 0.06 * Float(envelope)
                }
            }
            return sample
        }
    }
    
    // 6. Cozy failure sound (sad double wooden thud)
    func playLoseSound() {
        playSynthesizedSound(duration: 0.4) { currentFrame, maxFrames in
            let notes = [220.0, 196.0] // A3 -> G3
            let delayFrames = [0, 5292] // 0.12s delay
            
            var sample: Float = 0.0
            for (idx, freq) in notes.enumerated() {
                let startFrame = Int64(delayFrames[idx])
                if currentFrame >= startFrame {
                    let noteFrame = currentFrame - startFrame
                    let noteDurationFrames = maxFrames - startFrame
                    let progress = Double(noteFrame) / Double(noteDurationFrames)
                    let phase = 2.0 * .pi * freq * (Double(noteFrame) / 44100.0)
                    
                    let envelope = exp(-4.0 * progress)
                    sample += Float(sin(phase)) * 0.08 * Float(envelope)
                }
            }
            return sample
        }
    }
    
    // 7. Click/Select sound for shop purchase
    func playClickSound() {
        playSynthesizedSound(duration: 0.04) { currentFrame, maxFrames in
            let progress = Double(currentFrame) / Double(maxFrames)
            let freq = 1000.0 - 500.0 * progress
            let phase = 2.0 * .pi * freq * (Double(currentFrame) / 44100.0)
            return Float(sin(phase)) * 0.05 * Float(1.0 - progress)
        }
    }
}
