//
//  Model.swift
//  SCalc WatchKit Extension
//
//  Created by Plinio Vilela on 06/05/19.
//  Copyright © 2019 Plinio Vilela. All rights reserved.
//

import Foundation

open class Model {
      func treatEvent(event : String) -> Result {
        var statusStr = ""
        switch state{
        case "firstNumberState":
            switch event{
            case ".":
                if (!currentNumberStr.contains(".")){
                    appendToNumberStr(numStr: event)
                    statusStr = "temp"
                }
            case "0","1","2","3","4","5","6","7","8","9":
                var extra = ""
                if(negation){
                    extra = "-"
                    negation = false
                }
                appendToNumberStr(numStr: extra+event)
                if (event=="0"){
                    if(currentNumberStr.contains(".")){
                        statusStr = "temp"
                    }
                }
            case "+","-","x","/":
                if (currentNumberStr != "0"){
                    operation = event
                    firstNumber = Double(currentNumberStr)!
                    let firstNumberStr = currentNumberStr
                    state = "secondNumberState"
                    currentNumberStr = "0"
                    return Result(numberStr: firstNumberStr, statusStr: event)
                }else{
                    if((event == "-")&&(firstNumber == 0.0)){
                        negation = true
                    }
                }
            case "Invert":
                firstNumber = Double(currentNumberStr)!
                firstNumber = (-1) * firstNumber
                currentNumberStr = "0"
                appendToNumberStr(numStr: String(firstNumber))
            case "Clear":
                clearLabel()
            default:
                return Result(numberStr: currentNumberStr, statusStr: "")
            }
        case "secondNumberState" :
            secondNumber = Double(currentNumberStr)!
            switch event{
            case ".":
                if (!currentNumberStr.contains(".")){
                    appendToNumberStr(numStr: event)
                    statusStr = "temp"
                }
            case "0","1","2","3","4","5","6","7","8","9":
                appendToNumberStr(numStr: event)
                if (event=="0"){
                    if(currentNumberStr.contains(".")){
                        statusStr = "temp"
                    }
                }
            case "+","-","x","/":
                if (secondNumber != 0.0) {
                    let result = executeOperation()
                    firstNumber = result.num
                    statusStr = result.status
                    secondNumber = 0.0
                    currentNumberStr = "0"
                }
                let firstNumberStr = firstNumber.toString(decimal: 11)
                operation = event
                return Result(numberStr: firstNumberStr, statusStr: operation)
            case "Invert":
                secondNumber = (-1) * secondNumber
                currentNumberStr = "0"
                appendToNumberStr(numStr: String(secondNumber))
            case "=":
                let result = executeOperation()
                firstNumber = result.num
                statusStr = result.status
                secondNumber = 0
                currentNumberStr = firstNumber.toString(decimal: 11)
                state = "firstNumberState"
                return Result(numberStr: currentNumberStr, statusStr: statusStr)
            case "Clear":
                state = "firstNumberState"
                clearLabel()
            default:
                return Result(numberStr: currentNumberStr, statusStr: statusStr)
            }
        default:
            print("state: default")
        }
        return Result(numberStr: currentNumberStr, statusStr: statusStr)
    }
}
