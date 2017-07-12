//
//  CalculatorBrain.swift
//  Calculator
//
//  Created by aishwarya pant on 23/06/17.
//  Copyright © 2017 aishwarya. All rights reserved.
//

import Foundation

struct CalculatorBrain {
    
    public var resultIsPending: Bool = false
    
    private var accumulator: (value: Double?, description: String?)
    
    var result: (value: Double?, description: String?) {
        get {
            return accumulator
        }
    }
    
    private var operations: Dictionary<String, Operation> = [
        "π" : Operation.constant(Double.pi),
        "e" : Operation.constant(M_E),
        "√" : Operation.unaryOperation(sqrt),
        "cos" : Operation.unaryOperation(cos),
        "sin" : Operation.unaryOperation(sin),
        "log" : Operation.unaryOperation(log),
        "x²" : Operation.unaryOperation({ pow($0, 2) }),
        "±" : Operation.unaryOperation({ -$0 }),
        "x" : Operation.binaryOperation({ $0 * $1 }),
        "÷" : Operation.binaryOperation({ $0 / $1 }),
        "%" : Operation.binaryOperation({ Double(Int($0) % Int($1)) }),
        "+" : Operation.binaryOperation({ $0 + $1 }),
        "-" : Operation.binaryOperation({ $0 - $1 }),
        "=" : Operation.equals,
        "C" : Operation.clear
    ]
    
    private enum Operation {
        case constant(Double)
        case unaryOperation((Double) -> Double)
        case binaryOperation((Double, Double) -> Double)
        case equals
        case clear
    }
    
    mutating func performOperation(_ symbol: String) {
        if let operation = operations[symbol] {
            switch operation {
            case .constant(let value):
                accumulator = (value, accumulator.description?.appending(symbol))
            case .unaryOperation(let function):
                if accumulator.value != nil {
                    accumulator.value = function(accumulator.value!)
                    accumulator.description = symbol + "(" + accumulator.description! + ")"
                    
                }
            case .binaryOperation(let function):
                if accumulator.value != nil {
                    resultIsPending = true
                    performPendingBinaryOperation()
                    pendingBinaryOperation = PendingBinaryOperation(function: function, firstOperand: accumulator.value!)
                    accumulator = (nil, accumulator.description?.appending(symbol))
                }
            case .equals:
                performPendingBinaryOperation()
                pendingBinaryOperation = nil
                resultIsPending = false
            case .clear:
                accumulator = (nil, nil)
                pendingBinaryOperation = nil
                resultIsPending = false
            }
        }
    }
    
    private mutating func performPendingBinaryOperation() {
        if pendingBinaryOperation != nil {
            accumulator.value = pendingBinaryOperation!.perform(with: accumulator.value!)
        }
    }
    
    private var pendingBinaryOperation: PendingBinaryOperation?
    
    private struct PendingBinaryOperation {
        let function: (Double, Double) -> Double
        let firstOperand: Double
        
        func perform(with secondOperand: Double) -> Double {
            return function(firstOperand, secondOperand)
        }
    }
    
    mutating func setOperand(_ operand: Double) {
        accumulator.value = operand
        accumulator.description = (accumulator.description == nil) ?
            String(operand) : accumulator.description?.appending(String(operand))
        
    }
}









