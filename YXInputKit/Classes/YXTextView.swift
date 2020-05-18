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
    
    open var counterPadding: UIEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 5, right: 5) {
        didSet { updateCounterStyle() }
    }
    
    open var counterClosure: ((Int, Int, UILabel) -> ())? {
        didSet { updateCounterDisplay(text.count) }
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
    
    private var containerView: UIView?
    
    private var cacheText: String = ""
    
    fileprivate var cacheSelectedRange: NSRange = NSRange()
    
    @IBInspectable var isTransparent = false {
        didSet {
            guard let containerView = containerView else { return }
            containerView.layer.mask = isTransparent ? nil : visableLayer
        }
    }
    
    private var delegateRelay: TextViewDelegateRelay?
    open override var delegate: UITextViewDelegate? {
        get { super.delegate }
        set {
            let delegateRelay = TextViewDelegateRelay(realDelegate: newValue)
            super.delegate = delegateRelay
            self.delegateRelay = delegateRelay
        }
    }
    
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
            containerView = view
        }
        isTransparent = false
        self.delegate = nil
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
        visableLayer.frame = CGRect(x: 0, y: contentOffset.y, width: bounds.width, height: bounds.height - textContainerInset.bottom)
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
 
        let length = text.count
        if length > limitNumbers {
            let prefixStartIndex = text.startIndex
            let prefixEndIndex = text.index(prefixStartIndex, offsetBy: self.cacheSelectedRange.location)
            let prefixString = text[prefixStartIndex..<prefixEndIndex]
            
            let suffixStartIndex = text.index(prefixStartIndex, offsetBy: selectedRange.location)
            let suffixString = text[suffixStartIndex..<text.endIndex]

            var addText = text!
            addText.removeSubrange(suffixStartIndex..<text.endIndex)
            let addEndIndex = addText.index(prefixStartIndex, offsetBy: self.cacheSelectedRange.location)
            addText.removeSubrange(addText.startIndex..<addEndIndex)
            
            /// Remaining length
            let remainLength = limitNumbers - String(prefixString).count - String(suffixString).count
            let insertText = getSubString(from: addText, limitLength: remainLength)
            text = prefixString + insertText + suffixString
            self.cacheSelectedRange.location = self.cacheSelectedRange.location + insertText.count
            self.cacheSelectedRange.length = 0;
            selectedRange = self.cacheSelectedRange
            updateCounterDisplay(text.count)
        } else {
            updateCounterDisplay(length)
        }
        
        cacheText = text
        self.cacheSelectedRange = selectedRange
    }
    
    func getSubString(from string: String, limitLength: Int) -> String {
        let encoding = String.Encoding(rawValue: CFStringConvertEncodingToNSStringEncoding(CFStringEncoding(CFStringEncodings.GB_18030_2000.rawValue)))
        guard let data = string.data(using: encoding), limitLength > 0 else { return "" }
        let length = data.count
        if length >= limitLength {
            let subData = data.subdata(in: 0 ..< limitLength)
            // 当截取超出最大长度字符时把中文字符截断返回的 content 会是 nil
            var content = String(data: subData, encoding: encoding)
            if content == nil {
                let subData = data.subdata(in: 0 ..< limitLength - 1)
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
    
}

//MARK: - TextViewDelegateRelay
fileprivate class TextViewDelegateRelay: DelegateRelay, UITextViewDelegate  {
  
    @available(iOS 2.0, *)
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool  {
        if canResponseSelector(#selector(textViewShouldBeginEditing(_:))) {
            return realDelegate?.textViewShouldBeginEditing(textView) ?? true
        }
        return true
    }
    
    @available(iOS 2.0, *)
    func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
        if canResponseSelector(#selector(textViewShouldEndEditing(_:))) {
            return realDelegate?.textViewShouldEndEditing(textView) ?? true
        }
        return true
    }
    
    @available(iOS 2.0, *)
    func textViewDidBeginEditing(_ textView: UITextView) {
        if canResponseSelector(#selector(textViewDidBeginEditing(_:))) {
            realDelegate?.textViewDidBeginEditing(textView)
        }
    }
    
    @available(iOS 2.0, *)
    func textViewDidEndEditing(_ textView: UITextView) {
        if canResponseSelector(#selector(textViewDidEndEditing(_:))) {
            realDelegate?.textViewDidEndEditing(textView)
        }
    }
    
    
    @available(iOS 2.0, *)
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        
        if let textView = textView as? YXTextView, textView.markedTextRange?.start == nil {
            textView.cacheSelectedRange = textView.selectedRange
        }
        
        if canResponseSelector(#selector(textView(_:shouldChangeTextIn:replacementText:))) {
            return realDelegate?.textView(textView, shouldChangeTextIn: range, replacementText: text) ?? true
        }
        
        return true
        
    }
    
    @available(iOS 2.0, *)
    func textViewDidChange(_ textView: UITextView) {
        if canResponseSelector(#selector(textViewDidChange(_:))) {
            realDelegate?.textViewDidChange?(textView)
        }
    }
    
    @available(iOS 2.0, *)
    func textViewDidChangeSelection(_ textView: UITextView) {
        if canResponseSelector(#selector(textViewDidChangeSelection(_:))) {
            realDelegate?.textViewDidChangeSelection?(textView)
        }
    }
    
    @available(iOS 10.0, *)
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        if canResponseSelector(#selector(textView(_:shouldInteractWith:in:interaction:) as (UITextView, URL, NSRange, UITextItemInteraction) -> Bool)) {
            return realDelegate?.textView(textView, shouldInteractWith: URL, in: characterRange, interaction: interaction) ?? true
        }
        return true
    }
    
    @available(iOS 10.0, *)
    func textView(_ textView: UITextView, shouldInteractWith textAttachment: NSTextAttachment, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        if canResponseSelector(#selector(textView(_:shouldInteractWith:in:interaction:) as (UITextView, NSTextAttachment, NSRange, UITextItemInteraction) -> Bool)) {
            return realDelegate?.textView(textView, shouldInteractWith: textAttachment, in: characterRange, interaction: interaction) ?? true
        }
        return true
    }
    
    @available(iOS, introduced: 7.0, deprecated: 10.0, message: "Use textView(_:shouldInteractWith:in:interaction:) instead.")
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange) -> Bool {
        if canResponseSelector(#selector(textView(_:shouldInteractWith:in:) as (UITextView, URL, NSRange) -> Bool)) {
            return realDelegate?.textView(textView, shouldInteractWith: URL, in: characterRange) ?? true
        }
        return true
    }
    
    @available(iOS, introduced: 7.0, deprecated: 10.0, message: "Use textView(_:shouldInteractWith:in:interaction:) instead.")
    func textView(_ textView: UITextView, shouldInteractWith textAttachment: NSTextAttachment, in characterRange: NSRange) -> Bool {
        if canResponseSelector(#selector(textView(_:shouldInteractWith:in:) as (UITextView, NSTextAttachment, NSRange) -> Bool)) {
            return realDelegate?.textView(textView, shouldInteractWith: textAttachment, in: characterRange) ?? true
        }
        return true
    }
    
    func canResponseSelector(_ selector: Selector) -> Bool {
        if let canResponse = realDelegate?.responds(to: selector), canResponse {
            return true
        }
        return false
    }
    
}
