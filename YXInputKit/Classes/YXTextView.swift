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
                cacheText = cacheText.isEmpty ? text : cacheText
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
    
    @IBInspectable var isTransparent = false {
        didSet {
            guard let containerView = containerView else { return }
            containerView.layer.mask = isTransparent ? nil : visableLayer
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
            if let selectedRange = selectedTextRange {
                let cursorFrame = caretRect(for: selectedRange.start)
                if cursorFrame.maxY > visableLayer.frame.maxY && !isTransparent {
                    setContentOffset(CGPoint(x: 0, y: contentOffset.y + font!.lineHeight), animated: false)
                }
            }
        }
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
 
        if text.count > limitNumbers {
            
            let diffResult = firstDifferenceBetweenStrings(s1: text, s2: cacheText)
            if case .noDifference = diffResult  {
                return
            } else if case let .differenceAtIndex(leftIndex) = diffResult {
                
                /// get left text
                let leftIndexRange = text.startIndex..<text.index(text.startIndex, offsetBy: leftIndex)
                let left = String(text[leftIndexRange])
                
                /// get right text
                let right = text[text.index(text.index(text.startIndex, offsetBy: leftIndex), offsetBy: text.count - cacheText.count)..<text.endIndex]
                var insertText = text!
                let insertStartIndex = insertText.index(insertText.startIndex, offsetBy: leftIndex)
                let insertEndIndex = insertText.index(insertStartIndex, offsetBy: limitNumbers - left.count - right.count)
                
                /// get the string to be inserted
                insertText = String(insertText[insertStartIndex..<insertEndIndex])
                
                text = left + insertText + right
                let selectText = left + insertText
                let selectedRangeLenght = (selectText as NSString).range(of: selectText).length
                self.selectedRange.location = selectedRangeLenght
                
            }
        }
        
        updateCounterDisplay(text.count)
        cacheText = text
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
