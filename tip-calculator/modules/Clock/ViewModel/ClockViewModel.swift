//
//  ClockViewModel.swift
//  tip-calculator
//
//  Created by rafael.guimaraes on 29/01/24.
//

import Foundation
import Combine

protocol ClockViewModelProtocol : ObservableObject {
    var hour: String {get set}
    var minute: String {get set}
    var second: String {get set}
    
    //mutating func update() //no caso de uma struct
    func update()
}

//
//class ClockViewModel: ClockViewModelProtocol {
/*struct ClockViewModel: ClockViewModelProtocol {
    var hour: String = "01"
    var minute: String = "00"
    var second: String = "00"
    
    mutating func update() {
        let date = Date()
        let calendar = Calendar.current
        
        let hour = calendar.component(.hour, from: date)
        let minute = calendar.component(.minute, from: date)
        let second = calendar.component(.second, from: date)
        
        self.hour = String(format: "%02d", hour)
        self.minute = String(format: "%02d", minute)
        self.second = String(format: "%02d", second)
    }
}*/

class ClockViewModel: ClockViewModelProtocol {
    @Published var hour = "01"
    @Published var minute = "00"
    @Published var second = "00"
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        Timer.publish(every: 1, on: .main, in: .common).autoconnect()
            .sink { [weak self] _ in
                self?.update()
            }
            .store(in: &cancellables)
    }
    
    func update() {
        let date = Date()
        let calendar = Calendar.current
        
        let hour = calendar.component(.hour, from: date)
        let minute = calendar.component(.minute, from: date)
        let second = calendar.component(.second, from: date)
        
        self.hour = String(format: "%02d", hour)
        self.minute = String(format: "%02d", minute)
        self.second = String(format: "%02d", second)
    }
}

class ClockViewModelTwo: ClockViewModelProtocol {
    @Published var hour = "01"
    @Published var minute = "00"
    @Published var second = "00"
    
    //private var cancellables = Set<AnyCancellable>()
    
    func update() {
        let date = Date()
        let calendar = Calendar.current
        
        let hour = calendar.component(.hour, from: date)
        let minute = calendar.component(.minute, from: date)
        let second = calendar.component(.second, from: date)
        
        self.hour = String(format: "%02d", hour)
        self.minute = String(format: "%02d", minute)
        self.second = String(format: "%02d", second)
    }
}
