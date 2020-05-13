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
        let clearView = UILabel()
        clearView.text = "clear"
        textField.clearView = clearView
        textField.secureEntryOnImageName = "icon_notshown"
        textField.secureEntryOffImageName = "icon_display"
        textField.borderWidth = 5
        textField.borderColor = .orange
        textField.placeholder = "Hello, World!"
        textField.placeholderColor = .cyan
        textField.cornerRadius = 22
        textField.isCounterEnable = true
        textField.limitNumbers = 20
        textField.rightContainerSpacing = 10
        textField.counterClosure = { (count, maxValue, label) in
            print("TextField counter: \(count)/\(maxValue)")
        }
        view.addSubview(textField)
        
        
        let textView = YXTextView(frame: CGRect(x: 20, y: 250, width: view.bounds.width - 40, height: 120))
        textView.limitNumbers = 2000
        textView.text = "因为公司有很多模块，几乎每个模块都需要发布视频、语言、照片。所以在很多库的基础上，搭建了一个集合，其中包括带placeHolder的TextView、录制小视频、录制音频、选择照片或拍照。"
        textView.isCounterEnable = true
        textView.placeholder = "Hello, WorldHello, WorldHello, WorldHello, WorldHello, WorldHello, WorldHello, WorldHello, WorldHello, WorldHello, WorldHello, WorldHello, WorldHello, World"
        textView.counterClosure = { (count, maxValue, label) in
//            print("TextView counter: \(count)/\(maxValue)")
        }
        textView.layer.borderColor = UIColor.red.cgColor
        textView.layer.borderWidth = 5.0
        textView.layer.cornerRadius = 10
        textView.textContainerInset = UIEdgeInsets(top: 15, left: 15, bottom: 25, right: 5)
        view.addSubview(textView)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

