//
//  ViewController.swift
//  Calculator
//
//  Created by aishwarya pant on 22/06/17.
//  Copyright © 2017 aishwarya. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var display: UILabel!
    
    @IBOutlet weak var operationSequence: UILabel!
    
    var userIsTyping: Bool = false
    
    @IBAction func touchDigit(_ sender: UIButton) {
        
        let digit = sender.currentTitle!
        let decimalMark = "."
        
        if userIsTyping {
            let textCurrentlyInDisplay = display.text!
            switch digit {
            case decimalMark:
                if !textCurrentlyInDisplay.contains(".") {
                    fallthrough
                }
            default:
                display.text = textCurrentlyInDisplay + digit
            }
            display.text = textCurrentlyInDisplay + digit
        } else {
            display.text = digit
            userIsTyping = true
        }
        
    }
    
    var displayValue: Double {
        get {
            return Double(display.text!)!
        }
        set {
            display.text = String(newValue)
        }
    }
    
    private var brain = CalculatorBrain()
    
    @IBAction func performOperation(_ sender: UIButton) {
        
        if userIsTyping {
            brain.setOperand(displayValue)
            userIsTyping = false
        }
        if let mathematicalSymbol = sender.currentTitle {
            brain.performOperation(mathematicalSymbol)
        }
        if let result = brain.result.value {
            displayValue = result
        }
        else if !brain.resultIsPending {
            displayValue = 0
        }
        operationSequence.text = brain.result.description ?? " "
        
        if brain.resultIsPending {
            operationSequence.text = operationSequence.text!.appending("...")
        }
        else if brain.result.description != nil {
            operationSequence.text = operationSequence.text!.appending("=")
        }
        
    }
}

