//
//  CalculatorBrain.swift
//  Calculator
//
//  Created by aishwarya pant on 23/06/17.
//  Copyright © 2017 aishwarya. All rights reserved.
//

import Foundation

struct CalculatorBrain {
    
    private var expression = [Element]()
    
    private enum Element {
        case operand(Double)
        case operatorSymbol(String)
        case variable(String)
    }
    
    mutating func setOperand(_ operand: Double) {
        resetIfNewExpression()
        expression.append(Element.operand(operand))
    }
    
    private mutating func resetIfNewExpression() {
        if let lastElement = expression.last {
            switch lastElement {
            case .operatorSymbol(let symbol):
                if let operation = operations[symbol] {
                    switch operation {
                    case .equals: fallthrough
                    case .unaryOperation( _,  _):
                        clear()
                    default: break
                    }
                }
            default: break
            }
        }
    }
    
    mutating func setOperand(variable named: String) {
        resetIfNewExpression()
        expression.append(Element.variable(named))
    }
    
    mutating func setOperator(_ symbol: String) {
        expression.append(Element.operatorSymbol(symbol))
    }
    
    mutating func undo() {
        if !expression.isEmpty {
            expression.removeLast()
        }
    }
    
    mutating func clear() {
        expression.removeAll(keepingCapacity: true)
    }
    
    enum Operation {
        case constant(value: Double, description: String)
        case unaryOperation((Double) -> Double, (String) -> String)
        case binaryOperation((Double, Double) -> Double)
        case random(() -> Double, description: String)
        case equals
    }
    
    var operations: [String: Operation] = [
        "π" : Operation.constant(value: Double.pi, description: "π"),
        "e" : Operation.constant(value: M_E, description: "e"),
        "rand" : Operation.random({Double(arc4random()) / Double(UINT32_MAX)},
                                  description: "rand()"),
        "=" : Operation.equals,
        "√" : Operation.unaryOperation(sqrt, { "√(" +  $0 + ")" }),
        "cos" : Operation.unaryOperation(cos, { "cos(" + $0 + ")" }),
        "sin" : Operation.unaryOperation(sin, { "sin(" + $0 + ")" }),
        "log" : Operation.unaryOperation(log, { "log(" + $0 + ")" }),
        "x²" : Operation.unaryOperation({ pow($0, 2)}, { "(" + $0 + ")²" }),
        "±" : Operation.unaryOperation({ -$0 }, { "±(" + $0 + ")" }),
        "x" : Operation.binaryOperation({ $0 * $1 }),
        "÷" : Operation.binaryOperation({ $0 / $1 }),
        "%" : Operation.binaryOperation({ Double(Int($0) % Int($1)) }),
        "+" : Operation.binaryOperation({ $0 + $1 }),
        "-" : Operation.binaryOperation({ $0 - $1 }),
        ]
    
    func evaluate(using variables: Dictionary<String,Double>? = nil)
        -> (value: Double?, isPending: Bool, description: String) {
            
            var accumulator: (value: Double?, description: String) = (nil, " ")
            var pendingBinaryOperation: PendingBinaryOperation?
            
            func performOperation(_ symbol: String) {
                if let operation = operations[symbol] {
                    switch operation {
                    case .constant(let value, let description):
                        accumulator = (value, accumulator.description.appending(description))
                    case .unaryOperation(let function, let description):
                        if let value = accumulator.value{
                            accumulator = (function(value), description(accumulator.description))
                        }
                    case .binaryOperation(let function):
                        if accumulator.value != nil {
                            performPendingBinaryOperation()
                            pendingBinaryOperation = PendingBinaryOperation(function: function,
                                                                            firstOperand: accumulator.value!)
                            accumulator.description = accumulator.description.appending(symbol)
                        }
                    case .random(let function, let description ):
                        accumulator = (function(), accumulator.description.appending(description))
                    case .equals:
                        performPendingBinaryOperation()
                        pendingBinaryOperation = nil
                    }
                }
            }
            
            func performPendingBinaryOperation() {
                if pendingBinaryOperation != nil {
                    accumulator.value = pendingBinaryOperation!.perform(with: accumulator.value!)
                }
            }
            
            struct PendingBinaryOperation {
                let function: (Double, Double) -> Double
                let firstOperand: Double
                
                func perform(with secondOperand: Double) -> Double {
                    return function(firstOperand, secondOperand)
                }
            }
            for element in expression {
                switch element {
                case .variable(let name):
                    accumulator.value = variables?[name] ?? 0
                    accumulator.description = accumulator.description.appending(name)
                case .operand(let value):
                    accumulator = (value, accumulator.description.appending(value.formatted))
                case .operatorSymbol(let symbol):
                    performOperation(symbol)
                }
            }
            
            let isPending = pendingBinaryOperation != nil
            let result = expression.count == 0 ? 0 : accumulator.value
            let description = accumulator.description
            return (result, isPending, description)
    }
    
    @available(*, deprecated)
    public var resultIsPending: Bool {
        get {
            return evaluate().isPending
        }
    }
    
    @available(*, deprecated)
    var result: (value: Double?, description: String?) {
        get {
            return (evaluate().value, evaluate().description)
        }
    }
}

extension Double {
    static let fourFractionDigits: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 4
        return formatter
    }()
    var formatted: String {
        return Double.fourFractionDigits.string(for: self) ?? ""
    }
}










