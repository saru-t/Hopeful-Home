//
//  CalculatorViewController.swift
//  Teens in ai sn done
//
//  Created by Gnanasuntharam Thivyarajah on 14/05/2020.
//  Copyright © 2020 [Company]. All rights reserved.
//

import UIKit

//#warning("TODO FIXME")
// TODO: Clean up Code
// TODO: Check % and +/-
class CalculatorViewController: UIViewController {
    @IBOutlet weak fileprivate var display: UILabel!
    
    fileprivate var secretCode:Double?
    private var keychain = Keychain()
    
    fileprivate var userInTheMiddleOfTypingANumber = false
    fileprivate var decimalPointUsed = false
    fileprivate var negativeNumber = false
    
    fileprivate var brain = CalculatorSBrain()
    
    // FIXME: - 0000 in display
    @IBAction fileprivate func appendDigit(_ sender: UIButton) {
        let digit = sender.currentTitle
        var isdecimalpoint = false
        
        display.textColor = UIColor.white
        if (digit == "."){
            isdecimalpoint = true
        }
        if !(isdecimalpoint && decimalPointUsed){
            if userInTheMiddleOfTypingANumber {
                if isdecimalpoint {
                    decimalPointUsed = true
                }
                display.text = display.text! + digit!
            } else {
                if isdecimalpoint {
                    decimalPointUsed = true
                    let zerovalue = "0."
                    display.text = zerovalue
                } else {
                    display.text = digit
                }
                userInTheMiddleOfTypingANumber = true
            }
        }
    }
    

    fileprivate var displayValue: Double{
        get {
            guard let doubleText = Double(display.text!) else {
                return 0.0
            }
            return doubleText
        }
        set {
            if (displayValue == secretCode) {
                print("Secret Area")
                display.text = "Secret Area"
            }
            let value = newValue
            let remainder = value.truncatingRemainder(dividingBy: 1)
            if remainder == 0 {
               display.text = String(Int(value))
            }else{
                display.text = String(value)
            }
        }
    }
    
    func error(){
        display.textColor = UIColor.red
        display.text = "Error"
    }
    
    @IBAction fileprivate func operate(_ sender: UIButton) {
        decimalPointUsed = false
        
        if(secretCode == nil){
            let newCode = String(displayValue)
            print("New Code: \(newCode)")
//            UserDefaults.standard.set(newCode, forKey: "secret")
            _ = ((try? keychain.storeKeychain(username: "Calculators", password: newCode)) as Any??)
            
            secretCode = displayValue
            return
        }
        
        if (display.text == "CalculatorS"){
            displayValue = 0.0
        }

        if userInTheMiddleOfTypingANumber {
            brain.setOperand(displayValue)
            userInTheMiddleOfTypingANumber = false
        }
        if let mathematicalSymbol = sender.currentTitle {
            brain.performOperation(mathematicalSymbol)
            if brain.result != nil {
                display.textColor = UIColor.white
                displayValue = brain.result!
            } else {
                error()
            }
         }
    }
    

    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        guard let code = UserDefaults.standard.string(forKey: "secret") else {
        guard let code = try? keychain.getKeychain() else {
            print("No Code")
            display.text = "0"
            return
        }
        print("Code: \(code)")
        secretCode = Double(code)
    }
    
    // MARK: - Navigation
    @IBAction func unwindToCalculator(_ sender: UIStoryboardSegue){
        
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if (displayValue == secretCode) {
            return true
        } else {
            return false
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        var destinationvc = segue.destination
        destinationvc.shouldPerformSegue(withIdentifier: "SecretAreaSegue", sender: nil)
        
        if let navcon = destinationvc as? UINavigationController{
            destinationvc = navcon.visibleViewController ?? destinationvc
        }
        if let _ = destinationvc as? HomeScreenTwoViewController {
            if let identifier = segue.identifier {
                switch identifier {
                case "SecretAreaSegue":
                    displayValue = 0.0
                    display.text = "Secret Area"
                    print("SEGUE SECRET AREA")
                default:
                    break
                }
            }
        }
    }
    
}
