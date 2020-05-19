//
//  YXTextField.swift
//  YXTextField
//
//  Created by 蔡志文 on 2020/5/8.
//  Copyright © 2020 didong. All rights reserved.
//

import UIKit

private class PaddingView: UIView {
    
    var spacing: CGFloat = 0
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        translatesAutoresizingMaskIntoConstraints = false
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        translatesAutoresizingMaskIntoConstraints = false
    }
    
    override var intrinsicContentSize: CGSize {
        return CGSize(width: spacing, height: 0)
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        return CGSize(width: spacing, height: 0)
    }
}

@IBDesignable
open class YXTextField: UITextField {
    
    //MARK: - Left View List
    private var leftContainerView: UIStackView = UIStackView()
    
    private var leftPaddingView = PaddingView()

    open var leftAttachView: UIView? {
        didSet {
            if let oldView = oldValue {
                oldView.removeFromSuperview()
                leftContainerView.removeArrangedSubview(oldView)
            }
            if let view = leftAttachView {
                leftContainerView.addArrangedSubview(view)
            }
            setNeedsLayout()
        }
    }
    
    @IBInspectable open var leftPadding: CGFloat = 0 {
        didSet {
            leftPaddingView.spacing = leftPadding
            leftPaddingView.invalidateIntrinsicContentSize()
            setNeedsLayout()
        }
    }
    

    //MARK: - Right View List
    private var rightContainerView: UIStackView = UIStackView()
    
    private var rightPaddingView = PaddingView()
    
    /// 如果 `secureEntryButton` 存在，那么该值就是 `secureEntryButton`, 但是后续如果有重新赋于新值则 `secureEntryButton` 将被覆盖
    open var rightAttachView: UIView? {
        didSet {
            if let oldView = oldValue {
                oldView.removeFromSuperview()
                rightContainerView.removeArrangedSubview(oldView)
            }
            if let view = rightAttachView {
                view.translatesAutoresizingMaskIntoConstraints = false
                let index = rightContainerView.arrangedSubviews.count - 1
                rightContainerView.insertArrangedSubview(view, at: index)
                view.tag = index
            }
            setNeedsLayout()
        }
    }
    
    open var rightContainerSpacing: CGFloat = 0 {
        didSet {
            rightContainerView.spacing = rightContainerSpacing
            setNeedsLayout()
        }
    }
    
    @IBInspectable open var rightPadding: CGFloat = 0 {
        didSet {
            rightPaddingView.spacing = rightPadding
            rightPaddingView.invalidateIntrinsicContentSize()
            setNeedsLayout()
        }
    }
    
    //MARK: - Clear
    open var clearView: UIView? {
        didSet {
            if let oldView = oldValue {
                oldView.removeFromSuperview()
                rightContainerView.removeArrangedSubview(oldView)
            }
            if let view = clearView {
                view.translatesAutoresizingMaskIntoConstraints = false
                rightContainerView.insertArrangedSubview(view, at: 0)
                view.isUserInteractionEnabled = true
                view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(textClearAction)))
                updateClearViewState()
                view.tag = 0
            }
            setNeedsLayout()
        }
    }
    
    //MARK: - Border
    @IBInspectable open var borderWidth: CGFloat = 0 {
        didSet {
            backgroundLayer.lineWidth = borderWidth
        }
    }
    
    @IBInspectable open var borderColor: UIColor = .clear {
        didSet {
            backgroundLayer.strokeColor = borderColor.cgColor
        }
    }
    
    @IBInspectable open var cornerRadius: CGFloat = 0 {
        didSet {
            backgroundLayer.path = UIBezierPath(roundedRect: bounds, cornerRadius: cornerRadius).cgPath
        }
    }
    
    private var backgroundLayer: CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.strokeStart = 0
        layer.strokeEnd = 1
        layer.fillColor = UIColor.clear.cgColor
        return layer
    }()
    
    open override var backgroundColor: UIColor? {
        set { backgroundLayer.fillColor = newValue?.cgColor }
        get {
            if let fillColor = backgroundLayer.fillColor {
                return UIColor(cgColor: fillColor)
            } else {
                return nil
            }
        }
    }
    
    //MARK: - Placeholder
    @IBInspectable open var placeholderColor: UIColor? {
        didSet { updatePlaceholderStyle() }
    }
    
    open var placeholderFont: UIFont? {
        didSet { updatePlaceholderStyle() }
    }
    

    //MARK: - Secure Text Entry
    private var secureEntryButton: UIButton?
    
    open var secureEntryOnImage: UIImage? {
        didSet { updateSecureEntryStyle() }
    }
    
    open var secureEntryOffImage: UIImage? {
        didSet { updateSecureEntryStyle() }
    }
    
    @IBInspectable open var secureEntryOnImageName: String? {
        didSet {
            if let imageName = secureEntryOnImageName {
                secureEntryOnImage = UIImage(named: imageName)
            }
        }
    }
    
    @IBInspectable open var secureEntryOffImageName: String? {
        didSet {
            if let imageName = secureEntryOffImageName {
                secureEntryOffImage = UIImage(named: imageName)
            }
        }
    }
    
    var secureEntryInsets: UIEdgeInsets = UIEdgeInsets.zero {
        didSet { secureEntryButton?.contentEdgeInsets = secureEntryInsets }
    }
    
    
    open override var isSecureTextEntry: Bool {
        didSet {
            secureEntryButton?.isSelected = isSecureTextEntry
        }
    }
    
    
    //MARK: Counter
    /// 如果 `counterLabel` 存在，则 `counterLabel` 就是 `rightAttachView`
    private var counterLabel: UILabel?
    
    @IBInspectable open var limitNumbers: Int = Int.max
    
    open var counterFont: UIFont? {
        didSet { updateCounterStyle() }
    }
    
    @IBInspectable open var counterTextColor: UIColor? {
        didSet { updateCounterStyle() }
    }
    
    @IBInspectable open var isCounterEnable: Bool = false {
        didSet { updateCounterStyle() }
    }
    
    open var counterClosure: ((Int, Int, UILabel) -> ())? {
        didSet { updateCounterDisplay(text?.count ?? 0) }
    }
    
    
    //MARK: Match input text
    private var cacheText: String?
    
    public var matcher: Matcher?
    
    public var blockMatchInput: Bool = true
    
    public var matchInputClosure: ((Bool) -> Void)?
    
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required public init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    func setup() {
        
        layer.addSublayer(backgroundLayer)
        
        leftContainerView.translatesAutoresizingMaskIntoConstraints = false
        leftContainerView.addArrangedSubview(leftPaddingView)
        leftView = leftContainerView;
        leftViewMode = .always
        
        rightContainerView.translatesAutoresizingMaskIntoConstraints = false
        rightContainerView.addArrangedSubview(rightPaddingView)
        rightView = rightContainerView
        rightViewMode = .always

        placeholderFont = font
        
        let textChangedSelector = #selector(textDidChanged)
        let beginEditingSelector = #selector(textDidBeginEditing)
        NotificationCenter.default.addObserver(self, selector: textChangedSelector, name: UITextField.textDidChangeNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: beginEditingSelector, name: UITextField.textDidBeginEditingNotification, object: nil)
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        backgroundLayer.path = UIBezierPath(roundedRect: bounds, cornerRadius: cornerRadius).cgPath
    }
    
    
    private var isFixedConstrraints = false
    open override func updateConstraints() {
        super.updateConstraints()
        if let _ = leftContainerView.superview, let _ = rightContainerView.superview, !isFixedConstrraints {
            isFixedConstrraints = true
            NSLayoutConstraint.activate([
                leftContainerView.leadingAnchor.constraint(equalTo: leadingAnchor),
                leftContainerView.topAnchor.constraint(equalTo: topAnchor),
                leftContainerView.bottomAnchor.constraint(equalTo: bottomAnchor),
                
                rightContainerView.rightAnchor.constraint(equalTo: rightAnchor),
                rightContainerView.topAnchor.constraint(equalTo: topAnchor),
                rightContainerView.bottomAnchor.constraint(equalTo: bottomAnchor),

                leftPaddingView.heightAnchor.constraint(equalToConstant: bounds.height),
                rightPaddingView.heightAnchor.constraint(equalToConstant: bounds.height)
            ])
            
            setNeedsLayout()
            layoutIfNeeded()
        }
    }

    open override var font: UIFont? {
        didSet { placeholderFont = font ?? UIFont.systemFont(ofSize: 15)}
    }
    
    @objc private func textDidChanged() {
        if markedTextRange?.start == nil {
            updateLimitNumberOfText()
            matchInputString()
        }
        
        updateClearViewState()
    }
    
    @objc private func textDidBeginEditing() {
        updateClearViewState()
    }
    
    @objc private func toggleSecureEntryAction() {
        isSecureTextEntry.toggle()
    }
    
    @objc private func textClearAction() {
        text = nil
        updateClearViewState()
        updateCounterDisplay(text?.count ?? 0)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

private extension YXTextField {
    
    private func matchInputString() {
        guard let text = text, text.count > 0, let matcher = matcher else {
            cacheText = nil
            return
        }
        let matched = matcher.match(text)
        if blockMatchInput {
            if matched {
                cacheText = text
            } else {
                self.text = cacheText
            }
        }
        
        if let closure = matchInputClosure {
            closure(matched)
        }
    }
    
    private func updateLimitNumberOfText() {
        guard let string = text else { return }
        let length = string.count
        if length > limitNumbers {
            text = String(string[string.startIndex..<string.index(string.startIndex, offsetBy: limitNumbers)])
            updateCounterDisplay(text!.count)
        } else {
            text = string
            updateCounterDisplay(length)
        }
    }
    
    func updateClearViewState() {
        if let text = text, text.count > 0 {
            clearView?.isHidden = false
        } else {
            clearView?.isHidden = true
        }
    }
    
    func updatePlaceholderStyle() {
        guard let placeholder = placeholder else { return }
        let attributedText = NSAttributedString(
            string: placeholder,
            attributes: [
                NSAttributedString.Key.foregroundColor: placeholderColor ?? UIColor.clear,
                NSAttributedString.Key.font: placeholderFont ?? UIFont.systemFont(ofSize: 15)
        ])
        self.attributedPlaceholder =  attributedText
    }
    
    func updateSecureEntryStyle() {
        guard let secureEntryOnImage = secureEntryOnImage, let secureEntryOffImage = secureEntryOffImage else {
            secureEntryButton?.removeFromSuperview()
            secureEntryButton = nil
            setNeedsLayout()
            return
        }
       
        if secureEntryButton == nil {
            secureEntryButton = UIButton()
            secureEntryButton?.translatesAutoresizingMaskIntoConstraints = false
            secureEntryButton?.setImage(secureEntryOnImage, for: .selected)
            secureEntryButton?.setImage(secureEntryOffImage, for: .normal)
            secureEntryButton?.contentEdgeInsets = secureEntryInsets
            secureEntryButton?.isSelected = isSecureTextEntry
            secureEntryButton?.sizeToFit()
            secureEntryButton?.addTarget(self, action: #selector(toggleSecureEntryAction), for: .touchUpInside)
            var index = 0
            if let  clearView = clearView {
                index = clearView.tag + 1
            } else if let attachView = rightAttachView {
                index = attachView.tag
            }
            rightContainerView.insertArrangedSubview(secureEntryButton!, at: index)
            setNeedsLayout()
        }
    }
    
    func updateCounterStyle() {
        if !isCounterEnable, let _ = counterLabel {
            counterLabel?.removeFromSuperview()
            counterLabel = nil
            return
        }
        
        if isCounterEnable {
            if counterLabel == nil {
                counterLabel = UILabel()
                rightAttachView = counterLabel
            }
            counterLabel?.font = counterFont
            counterLabel?.textColor = counterTextColor
        }
    }
    
    func updateCounterDisplay(_ words: Int) {
        guard let counterLabel = counterLabel else { return }
        counterLabel.text = "\(words)/\(limitNumbers)"  // default display style
        if let closure = counterClosure {
            closure(words, limitNumbers, counterLabel)
        }
    }
    
    
}



