//
//  ViewController.swift
//  tip-calculator
//
//  Created by rafael.guimaraes on 19/01/24.
//

import SnapKit
import UIKit
import Combine

class CalculatorViewController: UIViewController {
    private let logoView = LogoView()
    private let resultView = ResultView()
    private let billInputView = BillInputView()
    private let tipInputView = TipInputView()
    private let splitInputView = SplitInputView()

    private lazy var vStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [
            logoView,
            resultView,
            billInputView,
            tipInputView,
            splitInputView,
            UIView()
        ])
        stackView.axis = .vertical
        stackView.spacing = 36
        return stackView
    }()
    
    private let viewModel = CalculatorViewModel()
    private var cancellables = Set<AnyCancellable>()
    
    //Controla o TAP em qualquer lugar da tela...
    private lazy var viewTapPublisher: AnyPublisher<Void, Never> = {
        let tapGesture = UITapGestureRecognizer(target: self, action: nil)
        view.addGestureRecognizer(tapGesture)
        return tapGesture.tapPublisher.flatMap { _ in
            Just(())
        }.eraseToAnyPublisher()
    }()
    
    //
    private lazy var logoViewTapPublisher: AnyPublisher<Void, Never> = {
        let tapGesture = UITapGestureRecognizer(target: self, action: nil)
        tapGesture.numberOfTapsRequired = 2
        logoView.addGestureRecognizer(tapGesture)
        return tapGesture.tapPublisher.flatMap { _ in
            Just(())
        }.eraseToAnyPublisher()
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        layout()
        bind()
        observe()
    }
    
    //Call the Transform: viewModel
    private func bind() {
        
        /*billInputView.billPublisher.sink { bill in
            print("Bill \(bill)")
        }.store(in: &cancellables)
         */
        
        //Just(10).eraseToAnyPublisher()
        //Just(.tenPercent).eraseToAnyPublisher(),
        //Just(5).eraseToAnyPublisher()
        let input = CalculatorViewModel.Input(
            billPublisher: billInputView.billPublisher,
            tipPublisher: tipInputView.tipPublisher,
            splitPublisher: splitInputView.splitPublisher,
            
            logoViewTapPublisher: logoViewTapPublisher
        )
        let output = viewModel.transform(input: input)
        
        //Para ver os resultados, no console, e atualizar a view ...
        output.updateViewPublisher.sink { [unowned self] result in
            //print(">>>>> \(result)")
            resultView.configure(result: result)
        }.store(in: &cancellables)
        
        output.resetCalculatorPublicher.sink { [unowned self]  _ in
            //print(">>>>> resetPublisher")
            billInputView.reset()
            tipInputView.reset()
            splitInputView.reset()
            
            UIView.animate(
                withDuration: 0.1,
                delay: 0,
                usingSpringWithDamping: 5.0,
                initialSpringVelocity: 0.5,
                options: .curveEaseInOut) {
                    self.logoView.transform = .init(scaleX: 1.5, y: 1.5)
                } completion: { _ in
                    UIView.animate(withDuration: 0.1) {
                        self.logoView.transform = .identity
                    }
                }
        }.store(in: &cancellables)
        
    }
    
    private func observe() {
        //viewTapPublisher.sink { <#()#> in
        //    <#code#>
        //}
        
        viewTapPublisher.sink { [unowned self] value in
            //print("value: \(value)")
            //Para sair o teclado, se clicar fora...
            view.endEditing(true)
        }.store(in: &cancellables)
        
        /*logoViewTapPublisher.sink { [unowned self] _ in
            print("logo view is tapped")
        }.store(in: &cancellables)*/
        
    }

    private func layout() {
        view.backgroundColor = ThemeColor.bg
        view.addSubview(vStackView)

        vStackView.snp.makeConstraints { make in
            make.leading.equalTo(view.snp.leadingMargin).offset(16)
            make.trailing.equalTo(view.snp.trailingMargin).offset(-16)
            make.bottom.equalTo(view.snp.bottomMargin).offset(-16)
            make.top.equalTo(view.snp.topMargin).offset(16)
        }

        logoView.snp.makeConstraints { make in
            make.height.equalTo(48)
        }

        resultView.snp.makeConstraints { make in
            make.height.equalTo(224)
        }

        billInputView.snp.makeConstraints { make in
            make.height.equalTo(56)
        }

        tipInputView.snp.makeConstraints { make in
            make.height.equalTo(56 + 56 + 15)
        }

        splitInputView.snp.makeConstraints { make in
            make.height.equalTo(56)
        }
    }
}
