//
//  Validations.swift
//  HabitissimoChallenge
//
//  Created by Eduard Borras Ruiz on 27/4/21.
//

import Foundation

class Validations {
    
    static func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }
    
    static func isValidPhoneNumber(_ phone: String) -> Bool {
        let PHONE_REGEX = "^[0-9]{6,16}$"
        let phoneTest = NSPredicate(format: "SELF MATCHES %@", PHONE_REGEX)
        let result = phoneTest.evaluate(with: phone)
        return result
    }
    
    static func isNumber(_ value: String) -> Bool {
        let REGEX_NUMBER = "^[0-9]{0,16}$"
        let phoneTest = NSPredicate(format: "SELF MATCHES %@", REGEX_NUMBER)
        let result = phoneTest.evaluate(with: value)
        return result
    }
    
}
