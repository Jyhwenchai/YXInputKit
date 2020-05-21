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
        leftButton.setTitleColor(.darkGray, for: .normal)

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
        
        
        let textView = YXTextView(frame: CGRect(x: 20, y: 200, width: view.bounds.width - 40, height: 120))
        textView.limitNumbers = 500
        textView.text = """
        UITextView supports the display of text using custom style information and also supports text editing. You typically use a text view to display multiple lines of text, such as when displaying the body of a large text document.

        This class supports multiple text styles through use of the attributedText property. (Styled text is not supported in versions of iOS earlier than iOS 6.) Setting a value for this property causes the text view to use the style information provided in the attributed string. You can still use the font, textColor, and textAlignment properties to set style attributes, but those properties apply to all of the text in the text view. It’s recommended that you use a text view—and not a UIWebView object—to display both plain and rich text in your app.
        """
        textView.isCounterEnable = true
        textView.placeholder = "please input something"
        textView.counterClosure = { (count, maxValue, label) in
//            print("TextView counter: \(count)/\(maxValue)")
        }
        textView.backgroundColor = UIColor.orange
        textView.layer.borderColor = UIColor.red.cgColor
        textView.layer.borderWidth = 5.0
        textView.layer.cornerRadius = 10
        textView.textContainerInset = UIEdgeInsets(top: 15, left: 15, bottom: 35, right: 5)
        textView.counterPadding = UIEdgeInsets(top: 0, left: 0, bottom: 10, right: 10)
        view.addSubview(textView)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }

}
