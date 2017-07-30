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
    
    @IBOutlet weak var memoryValue: UILabel!
    
    var userIsTyping: Bool = false
    
    @IBAction func touchDigit(_ sender: CalculatorButton) {
        
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
    
    private var variableName: String?
    
    @IBAction func addVariable(_ sender: CalculatorButton) {
        if let name = sender.currentTitle {
            variableName = name
            brain.setOperand(variable: name)
            evaluate()
        }
    }
    
    @IBAction func evaluateWithVariable(_ sender: UIButton) {
        if variableName != nil {
            if variables != nil {
                variables![variableName!] = displayValue
            } else {
                variables = [variableName! : displayValue]
            }
            
            var title = memoryValue.text!
            if title.count == 2 {
                memoryValue.text = title.appending(displayValue.formatted)
            } else {
                let range = title.index(title.endIndex, offsetBy: -(title.count - 2))..<title.endIndex
                title.removeSubrange(range)
                title.append(contentsOf: displayValue.formatted)
                memoryValue.text = title
            }
            
            userIsTyping = false
            evaluate()
        }
    }
    
    @IBAction func clear(_ sender: CalculatorButton) {
        brain.clear()
        displayValue = 0
        userIsTyping = false
        variables = nil
        evaluate()
        var memory = memoryValue.text!
        let range = memory.index(memory.endIndex, offsetBy: -(memory.count - 2))..<memory.endIndex
        memory.removeSubrange(range)
        memoryValue.text = memory
    }
    
    @IBAction func undo(_ sender: CalculatorButton) {
        if userIsTyping {
            displayValue = Double(String(displayValue.formatted.dropLast())) ?? 0
            if displayValue.formatted == "0" {
                userIsTyping = false
            }
        } else {
            brain.undo()
            evaluate()
        }
        
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
    
    @IBAction func performOperation(_ sender: CalculatorButton) {
        
        if userIsTyping {
            brain.setOperand(displayValue)
            userIsTyping = false
        }
        if let symbol = sender.currentTitle {
            brain.setOperator(symbol)
        }
        evaluate()
    }
    
    private func evaluate(using variables: Dictionary<String,Double>? = nil) {
        
        let result = brain.evaluate(using: variables ?? self.variables)
        if let result = result.value {
            displayValue = result
        }
        
        operationSequence.text = result.description
        operationSequence.text = result.isPending ? operationSequence.text!.appending("...")
            : operationSequence.text!.appending("=")
    }
    
    
}

