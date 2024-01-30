//
//  ClockView.swift
//  tip-calculator
//
//  Created by rafael.guimaraes on 29/01/24.
//

import SwiftUI

//struct ClockView: View {
  //  @ObservedObject var viewModel: ClockViewModel

//Permite mudar a classe de boa...
struct ClockView<T: ClockViewModelProtocol>: View {
    /*@State var hour = "10"
    @State var minute = "00"
    @State var second  = "22"*/
    
    //@State var viewModel: ClockViewModelProtocol
    //@ObservedObject var viewModel: ClockViewModel
    @ObservedObject var viewModel: T
    //let timer = Timer.TimerPublisher(interval: 1, runLoop: .main, mode: .common).autoconnect()
    
    var body: some View {
        HStack {
            Text(viewModel.hour)
            Text(":")
            Text(viewModel.minute)
            Text(":")
            Text(viewModel.second)
        }
        .font(.largeTitle).monospacedDigit()
        /*.onReceive(timer) { _ in
            viewModel.update()
        }*/
    }
}

#Preview {
    VStack {
        ClockView(viewModel: ClockViewModel())
        ClockView(viewModel: ClockViewModelTwo())
    }
}
