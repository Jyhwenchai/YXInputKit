//
//  ViewController.swift
//  YXInputKit
//
//  Created by Jyhwenchai on 05/12/2020.
//  Copyright (c) 2020 Jyhwenchai. All rights reserved.
//

import UIKit
import YXInputKit
class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        let textField = YXTextField(frame: CGRect(x: 20, y: 100, width: view.bounds.width - 40, height: 44))
        textField.leftPadding = 10
        textField.rightPadding = 10
        let leftButton = UIButton()
        leftButton.setTitle("left", for: .normal)

        textField.leftAttachView = leftButton
        let clearView = UILabel()
        clearView.text = "clear"
        
        
        textField.clearView = clearView
        textField.secureEntryOnImageName = "icon_notshown"
        textField.secureEntryOffImageName = "icon_display"
        textField.borderWidth = 5
        textField.borderColor = .orange
        textField.placeholder = "please input something"
        textField.placeholderColor = .cyan
        textField.cornerRadius = 22
        textField.isCounterEnable = true
        textField.limitNumbers = 20
        textField.rightContainerSpacing = 10
        textField.counterClosure = { (count, maxValue, label) in
            print("TextField counter: \(count)/\(maxValue)")
        }
        view.addSubview(textField)
        
        
        let textView = YXTextView(frame: CGRect(x: 20, y: 150, width: view.bounds.width - 40, height: 120))
        textView.limitNumbers = 30
        textView.text = "因为公司有很多模块，几乎每个模块都需要发布视频、"
        textView.isCounterEnable = true
        textView.placeholder = "please input something"
        textView.counterClosure = { (count, maxValue, label) in
//            print("TextView counter: \(count)/\(maxValue)")
        }
        textView.layer.borderColor = UIColor.red.cgColor
        textView.layer.borderWidth = 5.0
        textView.layer.cornerRadius = 10
        textView.textContainerInset = UIEdgeInsets(top: 15, left: 15, bottom: 45, right: 5)
        textView.counterPadding = UIEdgeInsets(top: 0, left: 0, bottom: 10, right: 10)
        textView.delegate = self
        view.addSubview(textView)

        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        
        let spacingView = SpacingView()
        
        spacingView.translatesAutoresizingMaskIntoConstraints = false
//        spacingView.setContentCompressionResistancePriority(.required, for: .horizontal)
        stackView.addArrangedSubview(spacingView)
        
        stackView.sizeToFit()
        print(stackView)

        let string = "12345"
        print(string[string.startIndex..<string.index(string.startIndex, offsetBy: 2)])
        
//        let systemTextField = UITextField(frame: CGRect(x: 30, y: 330, width: view.bounds.width - 60, height: 44))
//        systemTextField.placeholder = "please input something"
//        systemTextField.leftView = stackView
//        systemTextField.leftViewMode = .always
//        view.addSubview(systemTextField)
//        view.layoutIfNeeded()
//        NSLayoutConstraint.activate([
//            stackView.leadingAnchor.constraint(equalTo: systemTextField.leadingAnchor),
//            stackView.topAnchor.constraint(equalTo: systemTextField.topAnchor),
//            stackView.bottomAnchor.constraint(equalTo: systemTextField.bottomAnchor)
//        ])

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }

}

extension ViewController: UITextViewDelegate {
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
         print("textViewShouldBeginEditing")
        return true
    }
}

class SpacingView: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.blue
        
    }
    
    override var intrinsicContentSize: CGSize {
        return CGSize(width: 10, height: 44)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
         backgroundColor = UIColor.blue
    }
}
