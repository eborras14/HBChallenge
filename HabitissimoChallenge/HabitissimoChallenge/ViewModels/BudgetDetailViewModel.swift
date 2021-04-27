//
//  BudgetDetailViewModel.swift
//  HabitissimoChallenge
//
//  Created by Eduard Borras Ruiz on 27/4/21.
//

import UIKit

class BudgetDetailViewModel: NSObject, ViewModelProtocol {
    
    // MARK: Properties
    
    var budget: Budget?
    var delegate: ViewModelFieldsProtocol?

    
    // MARK: Custom constructor
    
    init(_ budget: Budget) {
        self.budget = budget
    }
    
    // MARK: - ViewModelProtocol
    
    func bindData() {
        
        //Description budget
        let descriptionTextField = delegate?.getField(for: BudgetDetailFieldIdentifier.descriptionId.rawValue) as? UITextField
        descriptionTextField?.text = budget?.descriptionBudget
        
        //Category budget
        let categoryView = delegate?.getField(for: BudgetDetailFieldIdentifier.categoryId.rawValue) as? DropdownField
        categoryView?.configure(title: "") //TODO: Setear correctamente
       
        //SubCategory budget
        let subCategoryView = delegate?.getField(for: BudgetDetailFieldIdentifier.subCategoryId.rawValue) as? DropdownField
        subCategoryView?.configure(title: "") //TODO: Setear correctamente
        
        //Name budget
        let nameTextField = delegate?.getField(for: BudgetDetailFieldIdentifier.nameId.rawValue) as? UITextField
        nameTextField?.text = budget?.name
        
        //Email budget
        let emailTextField = delegate?.getField(for: BudgetDetailFieldIdentifier.emailId.rawValue) as? UITextField
        emailTextField?.text = budget?.email
        
        //Phone budget
        let phoneTextField = delegate?.getField(for: BudgetDetailFieldIdentifier.phoneId.rawValue) as? UITextField
        phoneTextField?.text = budget?.phoneNumber
    }
    

}

// MARK: UITextFieldDelegate

extension BudgetDetailViewModel: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if let text = textField.text,
           let textRange = Range(range, in: text) {
            
           let updatedText = text.replacingCharacters(in: textRange,
                                                       with: string)
            let identifier = delegate?.getIdentifier(for: textField)
            
            switch identifier {
            case BudgetDetailFieldIdentifier.descriptionId.rawValue:
                budget?.descriptionBudget = updatedText
                break
            case BudgetDetailFieldIdentifier.nameId.rawValue:
                budget?.name = updatedText
                break
            case BudgetDetailFieldIdentifier.emailId.rawValue:
                budget?.email = updatedText
                break
            case BudgetDetailFieldIdentifier.phoneId.rawValue:
                //TODO: Hacer validacion solo numeros
                budget?.phoneNumber = updatedText
                break
            default:
                break
            }
           
            
            
            
        }
        
        return true
    }
    
}
