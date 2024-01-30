//
//  AudioPlayerService.swift
//  tip-calculator
//
//  Created by rafael.guimaraes on 25/01/24.
//

import Foundation
import AVFoundation

protocol AudioPlayerService {
    func playSound()
}

final class DefaultAudioPlayer: AudioPlayerService {
    
    private var player: AVAudioPlayer?
    
    func playSound() {
        guard let path = Bundle.main.path(forResource: "click", ofType: "m4a") else { return }
        
        let url = URL(fileURLWithPath: path)
        do {
            player = try AVAudioPlayer(contentsOf: url)
        } catch(let error) {
            print(error.localizedDescription)
        }
    }
    
    
}
