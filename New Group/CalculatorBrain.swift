//
//  CalculatorBrain.swift
//  Teens in ai sn done
//
//  Created by Gnanasuntharam Thivyarajah on 14/05/2020.
//  Copyright © 2020 [Company]. All rights reserved.
//

import Foundation

class CalculatorSBrain {
    
    fileprivate var acumulator: Double? = 0.0
    fileprivate var internalProgram = [AnyObject]()
    
    func setOperand(_ operand: Double) {
        acumulator = operand
          }
    
    fileprivate var operations: Dictionary<String, Operation> = [
        "∏": Operation.constant(.pi),
        "e": Operation.constant(M_E),
        "±": Operation.unaryOperation {-$0},
        "√": Operation.unaryOperation(sqrt),
        "cos": Operation.unaryOperation(cos),
        "+": Operation.binaryOperation { $0 + $1 },
        "−": Operation.binaryOperation { $0 - $1 },
        "×": Operation.binaryOperation { $0 * $1 },
        "÷": Operation.binaryOperation { $0 / $1 },
        "%": Operation.percentage,
        "=": Operation.equals,
        "C": Operation.clear,
        "AC": Operation.clear
    ]
    
    fileprivate enum Operation {
        case constant(Double)
        case unaryOperation((Double) -> Double)
        case binaryOperation((Double,Double) -> Double)
        case percentage
        case equals
        case clear
    }
    
    func performOperation(_ symbol: String){
        internalProgram.append(symbol as AnyObject)

        if let operation = operations[symbol]{
            
            switch operation {
            case .constant(let value):
                acumulator = value
            case .unaryOperation(let function):
                acumulator = function(acumulator!)
            case .binaryOperation(let function):
                executePendingBinaryOperation()
                pending =  pendingBinaryOperationInfo(binaryFunction: function, firstOperand: acumulator!)
            case .equals:
               executePendingBinaryOperation()
            case .percentage:
                executePendingBinaryOperation()
                acumulator = acumulator!/100
            case .clear:
                acumulator = 0.0
                pending = nil
            }
        }
//        print ("acumulator: \(acumulator!)")
    }
    
    
    fileprivate func executePendingBinaryOperation(){
        if pending != nil  {
            acumulator = pending!.binaryFunction(pending!.firstOperand,acumulator!)
            //print("acumulator \(acumulator)")
            pending = nil
        }
    }
    
    fileprivate var pending: pendingBinaryOperationInfo?
    
    fileprivate struct  pendingBinaryOperationInfo {
        var binaryFunction: ((Double,Double) -> Double)
        var firstOperand: Double!
    }
    
    typealias PropertyList = AnyObject
    var program: PropertyList{
        get{
            return internalProgram as CalculatorSBrain.PropertyList
        }
        set{
            clear()
            if let arrayOfOps = newValue as? [AnyObject] {
                for op in arrayOfOps {
                    if let operand = op as? Double {
                        setOperand(operand)
                    } else if let operation = op as? String {
                        performOperation(operation)
                    }
                }
            }
        }
    }
    
    fileprivate func clear(){
        acumulator = 0.0
        pending = nil
        internalProgram.removeAll()
    }
    
    var result: Double? {
        get {
            return acumulator
        }
    }
}
