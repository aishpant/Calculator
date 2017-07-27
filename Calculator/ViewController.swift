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
                if !textCurrentlyInDisplay.contains(decimalMark) {
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
    
    private var variables: [String: Double]?
    
    @IBAction func addVariable(_ sender: UIButton) {
        brain.setOperand(variable: "M")
        evaluate()
    }
    
    
    @IBAction func evaluateWithMemory(_ sender: UIButton) {
        
        if variables != nil {
            variables!["M"] = displayValue
        } else {
            variables = ["M" : displayValue]
        }
        userIsTyping = false
        evaluate()
    }
    
    @IBAction func clear(_ sender: UIButton) {
        brain.clear()
        displayValue = 0
        evaluate()
    }
    
    @IBAction func undo(_ sender: UIButton) {
        if userIsTyping {
            displayValue = Double(String(displayValue.formatted.dropLast())) ?? 0
        } else {
            brain.undo()
        }
        evaluate()
    }
    
    var displayValue: Double {
        get {
            return Double.fourFractionDigits.number(from: display.text!)?.doubleValue ?? 0
        }
        set {
            display.text = newValue.formatted
        }
    }
    
    private var brain = CalculatorBrain()
    
    @IBAction func performOperation(_ sender: UIButton) {
        
        if userIsTyping {
            brain.setOperand(displayValue)
            userIsTyping = false
        }
        if let symbol = sender.currentTitle {
            brain.performOperation(symbol)
        }
        evaluate()
    }
    
    private func evaluate() {
        
        if displayValue.formatted == "0" {
            userIsTyping = false
        }
        
        let result = brain.evaluate(using: variables)
        if let result = result.value {
            displayValue = result
        }
        
        operationSequence.text = result.description
        operationSequence.text = result.isPending ? operationSequence.text!.appending("...")
            : operationSequence.text!.appending("=")
    }
}

