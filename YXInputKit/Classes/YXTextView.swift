//
//  YXTextView.swift
//  YXTextField
//
//  Created by 蔡志文 on 2020/5/11.
//  Copyright © 2020 didong. All rights reserved.
//

import UIKit

@IBDesignable
open class YXTextView: UITextView {
    
    //MARK - Placeholder
    private var placeholderLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        return label
    }()
    
    @IBInspectable public var placeholder: String? {
        didSet { updatePlaceholder() }
    }
    
    @IBInspectable public var placeholderColor: UIColor? {
        didSet { updatePlaceholder() }
    }
    
    public var placeholderFont: UIFont? {
        didSet { updatePlaceholder() }
    }
    
    @IBInspectable public var attributedPlaceholder: NSAttributedString? {
        didSet { updatePlaceholder() }
    }
    
    @IBInspectable public var placeholderPadding: UIEdgeInsets = UIEdgeInsets(top: 8, left: 4, bottom: 8, right: 0) {
        didSet { updatePlaceholderLayout() }
    }
    
    open override var textContainerInset: UIEdgeInsets {
        didSet {
            placeholderPadding = textContainerInset
            placeholderPadding.left += 4    // fix placeholderLabel position
        }
    }
    
    //MARK: Counter
    /// 如果 `counterLabel` 存在，则 `counterLabel` 就是 `rightAttachView`
    private var counterLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .right
        label.isHidden = true
        return label
    }()
    
    @IBInspectable open var limitNumbers: Int = 1000 {
        didSet { updateCounterDisplay(text.count) }
    }
    
    open var counterFont: UIFont? {
        didSet { updateCounterStyle() }
    }
    
    @IBInspectable open var counterTextColor: UIColor? {
        didSet { updateCounterStyle() }
    }
    
    @IBInspectable open var isCounterEnable: Bool = false {
        didSet { updateCounterStyle() }
    }
    
    var counterPadding: UIEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 5, right: 5) {
        didSet { updateCounterStyle() }
    }
    
    
    open var counterClosure: ((Int, Int, UILabel) -> ())? {
        didSet { updateCounterDisplay(0) }
    }
    
    open override var text: String! {
        didSet {
            placeholderLabel.isHidden = text.count > 0
            if let text = text {
                updateCounterDisplay(text.count)
            }
        }
    }
    
    // Layer
    @IBInspectable var borderWidth: CGFloat = 0 {
        didSet { layer.borderWidth = borderWidth }
    }
    
    @IBInspectable var borderColor: UIColor = .clear {
        didSet { layer.borderColor = borderColor.cgColor }
    }
    
    @IBInspectable var cornerRadius: CGFloat = 0 {
        didSet { layer.cornerRadius = cornerRadius }
    }
    
    private let visableLayer = CALayer()
    
    private var cacheText: String = ""
    private var cacheSelectedRange: NSRange = NSRange(location: -1, length: 0)
    
    public override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        setup()
    }
    
    required public init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    func setup() {
        showsVerticalScrollIndicator = false
        visableLayer.backgroundColor = UIColor.white.cgColor
        addSubview(placeholderLabel)
        addSubview(counterLabel)
        updatePlaceholderLayout()
        let textChangedSelector = #selector(textDidChanged)
        NotificationCenter.default.addObserver(self, selector: textChangedSelector, name: UITextView.textDidChangeNotification, object: self)
        
        for view in subviews where "\(type(of: view.self))" == "_UITextContainerView" {
            view.layer.mask = visableLayer
        }
       
    }
    
    
    open override func layoutSubviews() {
        super.layoutSubviews()

        let frame = placeholderLabel.textRect(
            forBounds:
                CGRect(x: placeholderPadding.left,
                       y: placeholderPadding.top,
                       width: bounds.width - placeholderPadding.left - placeholderPadding.right,
                       height: .infinity),
            limitedToNumberOfLines: 0)
        placeholderLabel.frame = frame
        

        let size = counterLabel.sizeThatFits(.zero)
        counterLabel.frame = CGRect(
            x: counterPadding.left,
            y: bounds.height - size.height - counterPadding.bottom,
            width: bounds.width - counterPadding.left - counterPadding.right,
            height: size.height)
       
        var counterFrame = counterLabel.frame
        counterFrame.origin.y += contentOffset.y
        counterLabel.frame = counterFrame
        
        CATransaction.begin()
        _  = CATransaction.setDisableActions(true)
        visableLayer.frame = CGRect(x: 0, y: contentOffset.y + textContainerInset.top, width: bounds.width, height: bounds.height - textContainerInset.top - textContainerInset.bottom)
        CATransaction.commit()
    }
    
    @objc private func textDidChanged() {
        placeholderLabel.isHidden = text.count > 0
        if markedTextRange?.start == nil, isCounterEnable {
            updateLimitNumberOfText()
        }
        
        let offset = contentSize.height > bounds.height ? contentSize.height - bounds.height : 0
        setContentOffset(CGPoint(x: 0, y: offset), animated: false)
    }
    
    
    private func updatePlaceholder() {
        if let placeholder = placeholder {
            self.placeholderLabel.attributedText = nil
            self.placeholderLabel.text = placeholder
            self.placeholderLabel.font = (placeholderFont ?? font) ?? UIFont.systemFont(ofSize: 12)
            self.placeholderLabel.textColor = placeholderColor ?? textColor
            return
        }
        
        if let attributedPlaceholder = attributedPlaceholder {
            self.placeholderLabel.text = nil
            self.placeholderLabel.attributedText = attributedPlaceholder
        }
        
        updatePlaceholderLayout()
    }
    
    private func updatePlaceholderLayout() {
        setNeedsLayout()
        layoutIfNeeded()
    }
    
    
    private func updateLimitNumberOfText() {
        guard let _ = text else { return }
       
        if self.cacheSelectedRange.location == -1 {
            self.cacheSelectedRange = selectedRange
        }
       
        let encoding = String.Encoding(rawValue: CFStringConvertEncodingToNSStringEncoding(CFStringEncoding(CFStringEncodings.GB_18030_2000.rawValue)))
        guard let data = text.data(using: encoding) else { return}
        let length = data.count
        if length > limitNumbers {
            let subData = data.subdata(in: 0 ..< limitNumbers)
            // 当截取超出最大长度字符时把中文字符截断返回的 content 会是 nil
            var content = String(data: subData, encoding: encoding)
            if content == nil {
                let subData = data.subdata(in: 0 ..< limitNumbers - 1)
                content = String(data: subData, encoding: encoding)
            }
            
            
        
            let preStartIndex = text.startIndex
            let preEndIndex = text.index(preStartIndex, offsetBy: self.cacheSelectedRange.location)
            let prefixString = text[preStartIndex..<preEndIndex]
            
            let suffixStartIndex = text.index(preStartIndex, offsetBy: selectedRange.location)
            let suffixString = text[suffixStartIndex..<text.endIndex]

            var addText = text!
            addText.removeSubrange(suffixStartIndex..<text.endIndex)
            let addEndIndex = addText.index(preStartIndex, offsetBy: self.cacheSelectedRange.location)
            addText.removeSubrange(addText.startIndex..<addEndIndex)
            
            
            let subLength = limitNumbers - calcuteLength(with: String(prefixString)) - calcuteLength(with: String(suffixString))
            let saveText = getSubString(from: addText, subLength: subLength)
            text = prefixString + saveText + suffixString
            self.cacheSelectedRange.location = self.cacheSelectedRange.location + saveText.count
            selectedRange = self.cacheSelectedRange
            updateCounterDisplay(calcuteLength(with: text))
        } else {
            updateCounterDisplay(length)
        }
        
        cacheText = text
        self.cacheSelectedRange = selectedRange
    }
    
    func getSubString(from string: String, subLength: Int) -> String {
        let encoding = String.Encoding(rawValue: CFStringConvertEncodingToNSStringEncoding(CFStringEncoding(CFStringEncodings.GB_18030_2000.rawValue)))
        guard let data = string.data(using: encoding), subLength > 0 else { return "" }
        let length = data.count
        if length >= subLength {
            let subData = data.subdata(in: 0 ..< subLength)
            // 当截取超出最大长度字符时把中文字符截断返回的 content 会是 nil
            var content = String(data: subData, encoding: encoding)
            if content == nil {
                let subData = data.subdata(in: 0 ..< subLength - 1)
                content = String(data: subData, encoding: encoding)
            }
            return content ?? ""
        }
        return ""
    }
    
    func updateCounterStyle() {
        counterLabel.isHidden = !isCounterEnable
        if !isCounterEnable {
            counterLabel.text = nil
            counterLabel.attributedText = nil
            return
        }
        
        if isCounterEnable {
            counterLabel.font = counterFont
            counterLabel.textColor = counterTextColor
        }
        setNeedsLayout()
        layoutIfNeeded()
    }
    
    func updateCounterDisplay(_ words: Int) {
        counterLabel.text = "\(words)/\(limitNumbers)"  // default display style
        if let closure = counterClosure {
            closure(words, limitNumbers, counterLabel)
        }
    }
    
    func calcuteLength(with text: String) -> Int {
         let encoding = String.Encoding(rawValue: CFStringConvertEncodingToNSStringEncoding(CFStringEncoding(CFStringEncodings.GB_18030_2000.rawValue)))
        guard let data = text.data(using: encoding) else { return 0}
        return data.count
    }
    
    open override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.cacheSelectedRange = self.selectedRange
            print(self.selectedRange)
        }
        return super.hitTest(point, with: event)
    }
}
