//
//  TipInputView.swift
//  tip-calculator
//
//  Created by rafael.guimaraes on 21/01/24.
//

import Combine
import UIKit
// import CombineCocoa

class TipInputView: UIView {
    private let headerView: HeaderView = {
        let view = HeaderView()
        view.configure(
            topText: "Choose",
            bottomText: "your tip"
        )
        return view
    }()

    private lazy var tenPercentTipButton: UIButton = {
        let button = buildTipButton(tip: .tenPercent)

        button.tapPublisher.flatMap({
            Just(Tip.tenPercent)
        }).assign(to: \.value, on: tipSubject)
            .store(in: &cancellables)

        return button
    }()

    private lazy var fifteenPercentTipButton: UIButton = {
        let button = buildTipButton(tip: .fifteenPercent)
        
        button.tapPublisher.flatMap({
            Just(Tip.fifteenPercent)
        }).assign(to: \.value, on: tipSubject)
            .store(in: &cancellables)
        
        return button
    }()

    private lazy var twentyPercentTipButton: UIButton = {
        let button = buildTipButton(tip: .twentyPercent)
        
        button.tapPublisher.flatMap({
            Just(Tip.twentyPercent)
        }).assign(to: \.value, on: tipSubject)
            .store(in: &cancellables)
        
        return button
    }()

    private lazy var buttonHStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [
            tenPercentTipButton,
            fifteenPercentTipButton,
            twentyPercentTipButton,
        ])
        stackView.distribution = .fillEqually
        stackView.spacing = 16
        stackView.axis = .horizontal
        return stackView
    }()

    private lazy var custonTipButton: UIButton = {
        let button = UIButton()
        button.setTitle("Custon tip", for: .normal)
        button.titleLabel?.font = ThemeFont.bold(ofSize: 20)
        button.backgroundColor = ThemeColor.primary
        button.tintColor = .white
        button.addCornerRadius(radius: 8.0)
        
        //TODO: verificar o Custon
        button.tapPublisher.sink{ [weak self] _ in
            //Just(Tip.custom(value: 10))
            self?.handleCustonTipButton()
        }.store(in: &cancellables)
        
        return button
    }()

    private lazy var buttonVStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [
            buttonHStackView,
            custonTipButton,
        ])
        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.distribution = .fillEqually
        return stackView
    }()

    private var cancellables = Set<AnyCancellable>()
    // para enviar as atualizacoes para a viewControler
    // Permite passar um valor default ... por isso não usou o passthoighSubject
    private let tipSubject: CurrentValueSubject<Tip, Never> = .init(.none) // Valor default

    var tipPublisher: AnyPublisher<Tip, Never> {
        return tipSubject.eraseToAnyPublisher()
    }
    

    init() {
        super.init(frame: .zero)
        layout()
        observe()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func reset() {
        tipSubject.send(.none)
    }

    private func layout() {
        [headerView, buttonVStackView].forEach(addSubview(_:))
        buttonVStackView.snp.makeConstraints { make in
            make.top.bottom.trailing.equalToSuperview()
        }

        headerView.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.trailing.equalTo(buttonVStackView.snp.leading).offset(-24)
            make.width.equalTo(68)
            make.centerY.equalTo(buttonHStackView.snp.centerY)
        }
    }

    private func buildTipButton(tip: Tip) -> UIButton {
        let button = UIButton(type: .custom)
        button.backgroundColor = ThemeColor.primary
        button.addCornerRadius(radius: 8.0)
        let text = NSMutableAttributedString(
            string: tip.stringValues,
            attributes: [
                .font: ThemeFont.bold(ofSize: 20),
                .foregroundColor: UIColor.white,
            ]
        )
        text.addAttributes([
            .font: ThemeFont.demibold(ofSize: 14),
        ], range: NSMakeRange(2, 1))
        button.setAttributedTitle(text, for: .normal)
        return button
    }
    
    private func handleCustonTipButton() {
        let alertController: UIAlertController = {
            let controller = UIAlertController(
                title: "Enter custom tip",
                message: nil,
                preferredStyle: .alert
            )
            controller.addTextField { textField in
                textField.placeholder = "Make it generous !"
                textField.keyboardType = .numberPad
                textField.autocapitalizationType = .none
            }
            
            let cancelAction = UIAlertAction(
                title: "Cancel",
                style: .cancel
            )
            
            let okAction = UIAlertAction(
                title: "OK",
                style: .default
            ) { [weak self] _ in
                guard let text = controller.textFields?.first?.text, let value = Int(text) else {
                    return
                }
                self?.tipSubject.send(.custom(value: value))
            }
            
            [okAction, cancelAction].forEach(controller.addAction(_:))
            
            return controller
        }()
        
        //extension UIResponder...
        parentViewController?.present(alertController, animated: true)
    }
    
    
    
    //Manipulando estados dos botoes...
    //Muda a cor do selecionado, e os valores do custom
    
    private func observe() {
        tipSubject.sink { [unowned self] tip in
            resetView()
            
            switch tip {
                
            case .none:
                break
            case .tenPercent:
                tenPercentTipButton.backgroundColor = ThemeColor.secondary
            case .fifteenPercent:
                fifteenPercentTipButton.backgroundColor = ThemeColor.secondary
            case .twentyPercent:
                twentyPercentTipButton.backgroundColor = ThemeColor.secondary
            case .custom(let value):
                custonTipButton.backgroundColor = ThemeColor.secondary
                let text = NSMutableAttributedString(
                    string: "$\(value)",
                    attributes: [
                        .font: ThemeFont.bold(ofSize: 20)
                    ]
                )
                text.addAttributes([
                    .font: ThemeFont.bold(ofSize: 14)
                ], range: NSMakeRange(0, 1))
                
                custonTipButton.setAttributedTitle(text, for: .normal)
            }
        }.store(in: &cancellables)

    }
    
    
    private func resetView() {
        [
            tenPercentTipButton,
            twentyPercentTipButton,
            fifteenPercentTipButton,
            custonTipButton
        ].forEach {
            $0.backgroundColor = ThemeColor.primary
        }
        
        let text = NSMutableAttributedString(
            string: "Custom tip",
            attributes: [
                .font: ThemeFont.bold(ofSize: 20),
                .foregroundColor: UIColor.white
            ]
        )
        custonTipButton.setAttributedTitle(text, for: .normal)
        
        
        
    }
}
