//
//  CAlculatorViewModel.swift
//  tip-calculator
//
//  Created by rafael.guimaraes on 21/01/24.
//

import Combine
import Foundation

class CalculatorViewModel {
    //Enter Bill / Chose your Bill / Split the total...
    struct Input {
        let billPublisher: AnyPublisher<Double, Never>
        let tipPublisher: AnyPublisher<Tip, Never>
        let splitPublisher: AnyPublisher<Int, Never>
        
        let logoViewTapPublisher: AnyPublisher<Void, Never>
    }

    //Total p/ Person / Total Bill / Total tip
    struct OutPut {
        let updateViewPublisher: AnyPublisher<Result, Never>
        
        let resetCalculatorPublicher: AnyPublisher<Void, Never>
    }
    
    private var cancellables = Set<AnyCancellable>()
    
    private let audioPlayerService: AudioPlayerService
    //Dependency injection...
    init(audioPlayerService: AudioPlayerService = DefaultAudioPlayer()) {
        self.audioPlayerService = audioPlayerService
    }
    
    func transform(input: Input) -> OutPut {
        
        /*input.billPublisher.sink { bill in
            print("the bill: \(bill)")
        }.store(in: &cancellables)*/
        
        /*input.tipPublisher.sink { tip in
            print("the tip: \(tip)")
        }.store(in: &cancellables)*/
        
        /*input.splitPublisher.sink { split in
            print("the split: \(split)")
        }.store(in: &cancellables)*/
        
        let updateViewPublisher = Publishers.CombineLatest3(
            input.billPublisher,
            input.tipPublisher,
            input.splitPublisher
        ).flatMap { [unowned self] (bill, tip, split) in
            let totalTip = getTipAmount(bill: bill, tip: tip)
            let totalBill = bill + totalTip
            let amountPerPerson = totalBill / Double(split)
            
            let result = Result(
                amountPerPerson: amountPerPerson,
                totalBill: totalBill,
                totalTip: totalTip
            )
            
            return Just(result)
        }.eraseToAnyPublisher()
        
        //Separado aqui para adicionar um som ao clicar 2 vezes no logo
        //let resultCalculatorPublisher = input.logoViewTapPublisher
        
        let resultCalculatorPublisher = input.logoViewTapPublisher.handleEvents(receiveOutput: { [unowned self] in
            
            audioPlayerService.playSound()
            
        }).flatMap {
            return Just($0)
        }.eraseToAnyPublisher()
        
        /*
        //HardCode sample
        let result = Result(
            amountPerPerson: 500,
            totalBill: 1000,
            totalTip: 50.0
        )
        
        return OutPut(updateViewPublisher: Just(result).eraseToAnyPublisher())
         */
        return OutPut(updateViewPublisher: updateViewPublisher, resetCalculatorPublicher: resultCalculatorPublisher)
    }
    
    private func getTipAmount(bill: Double, tip: Tip) -> Double {
        switch tip {
            
        case .none:
            return 0
        case .tenPercent:
            return bill * 0.1
        case .fifteenPercent:
            return bill * 0.15
        case .twentyPercent:
            return bill * 0.20
        case .custom(let value):
            return Double(value)
        }
    }
}
