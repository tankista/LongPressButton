//
//  PressGestureRecognizer.swift
//  LongpressButton
//
//  Created by Peter Stajger on 07/04/2018.
//  Copyright © 2018 UITouch. All rights reserved.
//

import Foundation
import UIKit
import UIKit.UIGestureRecognizerSubclass

protocol PressGestureRecognizerDelegate: class {
    func gestureRecognizerDidRecognizeMinimumPressDuration(_ recognizer: PressGestureRecognizer)
}

/**
 Gesture recognizer simulating long press.
 
 1. begins as soon as user taches the button with 1 finger -> user begun interaction
 2. after minimumPressDuration elapses state is changed  -> long press was initiated
 3. after requiredPressDuration elapeses state is changed to finished -> long press recognized
 4. in every other case state is changed to cancelled -> long press cancelled
 
 - Note: difference between PressGestureRecognizer and UILongPressGestureRecognizer is that
 the former changes state to `begin` imediatelly, while the latter begins only after `minimumPressDuration`
 is elapsed. And we need to track when user begun the interaction.
 */
class PressGestureRecognizer : UIGestureRecognizer {
    
    var minimumPressDuration: TimeInterval = 0.25
    var requiredPressDuration: TimeInterval = 3
    
    var isTestingLongPress: Bool = false
    
    weak var pressDelegate: PressGestureRecognizerDelegate?
    
    private var timerInterval: TimeInterval = 0.05
    private var timer: Timer?
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent) {
        
        guard touches.count == 1 else {
            state = .failed
            return
        }
        
        timer = Timer.scheduledTimer(timeInterval: minimumPressDuration, target: self, selector: #selector(minimumPressDurationTimerTriggered), userInfo: nil, repeats: false)
        state = .began
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent) {
        isTestingLongPress = false
        state = .cancelled
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent) {
        isTestingLongPress = false
        state = .cancelled
    }
    
    override func reset() {
        isTestingLongPress = false
        timer?.invalidate()
        timer = nil
    }
    
    // MARK: Private Methods
    
    @objc private func minimumPressDurationTimerTriggered(_ timer: Timer) {
        isTestingLongPress = true
        pressDelegate?.gestureRecognizerDidRecognizeMinimumPressDuration(self)
        self.timer = Timer.scheduledTimer(timeInterval: requiredPressDuration, target: self, selector: #selector(requiredPressDurationTimerTriggered), userInfo: nil, repeats: false)
    }
    
    @objc private func requiredPressDurationTimerTriggered(_ timer: Timer) {
        state = .ended
        isTestingLongPress = false
    }
    
}
