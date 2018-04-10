//
//  LongPressButton.swift
//  LongpressButton
//
//  Created by Peter Stajger on 09/04/2018.
//  Copyright © 2018 UITouch. All rights reserved.
//

import Foundation
import UIKit

///
/// A custom UI control that allows user to trigger an event when long presses the controll. When user
/// puts a finer on the control an internal timer is started and after minimumPressDuration is reached
/// control begins new timer and starts animating the progress. Also a UIControlEvent.valueChanged event
/// is sent. If user lifts the finger before requiredPressDuration is reached UIControlEvent.touchCancel
/// control event is sent. If user holds finger longer than requiredPressDuration, progress animation is
/// finished and UIControlEvent.primaryActionTriggered is called.
///
/// To configure the control you can use various of methods, such as for setting titles for control states
/// and events, title text attibutes and background colors for control states. In general, supported control
/// events are .valueChanged, .primaryActionTriggered and control states are .normal and .disabled. You can
/// also configure thouch down animation by specifying transform and durations. For more info see corresponding
/// methods below.
///
@objcMembers
class LongPressButton : UIControl {
    
    ///
    /// A minimum duration that user has to press the button to start recongnizing long press. Otherwise
    /// it's a simple touch up.
    ///
    dynamic var minimumPressDuration: TimeInterval = 0.15 {
        didSet { gestureRecognizer.minimumPressDuration = minimumPressDuration }
    }
    
    ///
    /// A required duration that user has to press the button to trigger main event.
    ///
    dynamic var requiredPressDuration: TimeInterval = 2 {
        didSet { gestureRecognizer.requiredPressDuration = requiredPressDuration }
    }
    
    private var gestureRecognizer: PressGestureRecognizer!
    private var isEnabledToken: NSKeyValueObservation!
    private var progressView: ProgressView!
    private var titleLabel: UILabel!
    
    private var textAttributesForStates: [UInt: [NSAttributedStringKey: Any]] = [:]
    private var backgroundColorsForStates: [UInt: UIColor] = [:]
    
    private var titlesForStates: [UInt: String] = [:]
    private var titlesForEvents: [UInt: String] = [:]
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        gestureRecognizer = PressGestureRecognizer(target: self, action: #selector(gestureStateChanged(_:)))
        gestureRecognizer.pressDelegate = self
        gestureRecognizer.minimumPressDuration = minimumPressDuration
        gestureRecognizer.requiredPressDuration = requiredPressDuration
        addGestureRecognizer(gestureRecognizer)
        
        progressView = ProgressView(frame: .zero)
        progressView.progressColor = progressColor
        addSubview(progressView)
        
        titleLabel = UILabel(frame: .zero)
        titleLabel.backgroundColor = .clear
        titleLabel.textAlignment = .center
        titleLabel.lineBreakMode = .byTruncatingMiddle
        addSubview(titleLabel)
        
        isEnabledToken = observe(\.isEnabled, changeHandler: { [weak self](object, _) in
            self?.updateTitleText()
            self?.updateTitleLabelAppearance()
            self?.updateBackgroundColor()
        })
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        progressView.frame = bounds
        titleLabel.frame = bounds
    }
    
    
    // MARK: - Appearance Methods
    
    ///
    /// Sets color of progress bar.
    ///
    dynamic var progressColor: UIColor? = UIColor.red {
        didSet {
            progressView.progressColor = progressColor
        }
    }
    
    ///
    /// Supported NSAttributedStringKey keys: .font, .foregroundColor
    ///
    dynamic func setTitleTextAttributes(_ attributes: [NSAttributedStringKey: Any], forState: UIControlState) {
        textAttributesForStates[forState.rawValue] = attributes
        updateTitleLabelAppearance()
    }
    
    ///
    /// Supported control states: .normal, .disabled
    ///
    dynamic func setBackgroundColor(_ color: UIColor, forState: UIControlState) {
        backgroundColorsForStates[forState.rawValue] = color
        updateBackgroundColor()
    }
    
    
    // MARK: - Configuration Methods
    
    ///
    /// Supported states are .normal, .disabled
    ///
    func setTitle(_ title: String?, forState: UIControlState) {
        titlesForStates[forState.rawValue] = title
        updateTitleText()
    }
    
    ///
    /// Supported events are .valueChanged, .primaryActionTriggered
    ///
    func setTitle(_ title: String?, forEvent: UIControlEvents) {
        titlesForEvents[forEvent.rawValue] = title
        updateTitleText()
    }
    
    
    // MARK: - Transform Animation Methods
    
    ///
    /// Transform is used when user touches downt he control
    ///
    dynamic var touchDownTransform = CGAffineTransform(scaleX: 0.96, y: 0.96)
    
    ///
    /// Touch down animation duration
    ///
    dynamic var touchDownDuration: TimeInterval = 0.05
    
    ///
    /// Touch up animation duration
    ///
    dynamic var touchUpDuration: TimeInterval = 0.1
    
    
    // MARK: - Private Methods
    
    @objc private func gestureStateChanged(_ recognizer: PressGestureRecognizer) {
        switch recognizer.state {
        case .began:
            sendActions(for: .touchDown)
            touchedDown()
            updateTitleText()
        case .ended:
            sendActions(for: .primaryActionTriggered)
            touchedUp()
            updateTitleText()
        case .cancelled:
            sendActions(for: .touchCancel)
            touchedUp()
            progressView.setProgress(0, duration: recognizer.requiredPressDuration, delay: 0, animated: true)
            updateTitleText()
        case .failed:
            sendActions(for: .touchCancel)
            touchedUp()
            progressView.setProgress(0, duration: 0, delay: 0, animated: false)
            updateTitleText()
        default:
            break
        }
    }
    
    private func updateTitleLabelAppearance() {
        var attributes: [NSAttributedStringKey: Any]?
        if state.contains(.disabled), let disabledAttributes = textAttributesForStates[UIControlState.disabled.rawValue] {
            attributes = disabledAttributes
        }
        else if let normalAttributes = textAttributesForStates[UIControlState.normal.rawValue] {
            attributes = normalAttributes
        }
        
        titleLabel.font = attributes?[.font] as? UIFont
        titleLabel.textColor = attributes?[.foregroundColor] as? UIColor
    }
    
    private func updateBackgroundColor() {
        if state.contains(.disabled), let disabledBackgroundColor = backgroundColorsForStates[UIControlState.disabled.rawValue] {
            backgroundColor = disabledBackgroundColor
        }
        else if let disabledBackgroundColor = backgroundColorsForStates[UIControlState.normal.rawValue] {
            backgroundColor = disabledBackgroundColor
        }
        else {
            backgroundColor = nil
        }
    }
    
    private func updateTitleText() {
        titleLabel.text = titleForCurrentState()
    }
    
    private func titleForCurrentState() -> String {
        if state.contains(.disabled), let disabledTitle = titlesForStates[UIControlState.disabled.rawValue] {
            return disabledTitle
        }
        else {
            if gestureRecognizer.state == .ended, let endedTitle = titlesForEvents[UIControlEvents.primaryActionTriggered.rawValue] {
                return endedTitle
            }
            else if gestureRecognizer.isTestingLongPress, let longPressTitle = titlesForEvents[UIControlEvents.valueChanged.rawValue] {
                return longPressTitle
            }
            else {
                return titlesForStates[UIControlState.normal.rawValue] ?? ""
            }
        }
    }
    
    private func touchedDown() {
        transformButtonSizeAnimated(transform: touchDownTransform, duration: touchDownDuration)
    }
    
    private func touchedUp() {
        transformButtonSizeAnimated(transform: .identity, duration: touchUpDuration)
    }

    private func transformButtonSizeAnimated(transform: CGAffineTransform, duration: TimeInterval) {
        UIView.animate(withDuration: duration) {
            self.transform = transform
        }
    }
    
}

extension LongPressButton : PressGestureRecognizerDelegate {
    
    func gestureRecognizerDidRecognizeMinimumPressDuration(_ recognizer: PressGestureRecognizer) {
        sendActions(for: .valueChanged)
        progressView.setProgress(1, duration: recognizer.requiredPressDuration, delay: 0, animated: true)
        updateTitleText()
    }
    
}

