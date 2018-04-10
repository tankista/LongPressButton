//
//  RootViewController.swift
//  LongpressButton
//
//  Created by Peter Stajger on 07/04/2018.
//  Copyright © 2018 UITouch. All rights reserved.
//

import UIKit

class RootViewController: UIViewController {

    @IBOutlet weak var button: LongPressButton!
    @IBOutlet weak var stateLabel: UILabel!
    @IBOutlet weak var enabledSwitch: UISwitch!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //set titles for control states and events
        button.setTitle("Hold to start", forState: .normal)
        button.setTitle("Disabled", forState: .disabled)
        button.setTitle("Release to cancel", forEvent: .valueChanged)
        button.setTitle("Action triggered", forEvent: .primaryActionTriggered)
        
        //configure text attributes for control states
        button.setTitleTextAttributes([.font: UIFont.systemFont(ofSize: 17, weight: .semibold), .foregroundColor: UIColor.white], forState: .normal)
        button.setTitleTextAttributes([.font: UIFont.systemFont(ofSize: 17, weight: .regular), .foregroundColor: UIColor.white.withAlphaComponent(0.7)], forState: .disabled)
        
        //configure background colors for control states
        button.progressColor = UIColor(red: 129/255, green: 209/255, blue: 53/255, alpha: 1)
        button.setBackgroundColor(UIColor(red: 60/255, green: 177/255, blue: 245/255, alpha: 1), forState: .normal)
        button.setBackgroundColor(UIColor.gray, forState: .disabled)
        
        //add target-action selectors for all supported events
        button.addTarget(self, action: #selector(buttonTouchedDown(_:)), for: .touchDown)
        button.addTarget(self, action: #selector(buttonTouchCancelled(_:)), for: .touchCancel)
        button.addTarget(self, action: #selector(buttonLongPressStarted(_:)), for: .valueChanged)
        button.addTarget(self, action: #selector(buttonLongPressDetected(_:)), for: .primaryActionTriggered)
        
        
        //hookups with IB
        button.isEnabled = enabledSwitch.isOn
        stateLabel.text = "Cancelled"
    }
    
    @objc private func buttonTouchedDown(_ sender: LongPressButton) {
        stateLabel.text = "Touched Down"
    }
    
    @objc private func buttonTouchCancelled(_ sender: LongPressButton) {
        stateLabel.text = "Cancelled"
    }
    
    @objc private func buttonLongPressStarted(_ sender: LongPressButton) {
        stateLabel.text = "Started"
    }
    
    @objc private func buttonLongPressDetected(_ sender: LongPressButton) {
        stateLabel.text = "Detected"
    }
    
    @IBAction func enabledChanged(_ sender: UISwitch) {
        button.isEnabled = enabledSwitch.isOn
    }
}

