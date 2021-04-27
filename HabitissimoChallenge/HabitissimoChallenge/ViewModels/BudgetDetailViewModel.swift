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
    var delegate: ViewModelUtilsProtocol?

    
    // MARK: Custom constructor
    
    init(_ budget: Budget) {
        self.budget = budget
    }
    
    // MARK: Save logic
    
    func saveAction() {
        
        let validateMessage = validateBudget()
        
        if let validateMessage = validateMessage {
            
            let acceptAction = UIAlertAction.init(title: NSLocalizedString("AcceptTitle", comment: ""), style: .default, handler: nil)
            
            delegate?.showAlert?(NSLocalizedString("AtentionTitle", comment: ""), message: validateMessage, actions: [acceptAction])
            
        }else {
            (BudgetController.sharedInstance() as? BudgetController)?.save(budget)
        }
        
    }
    
    // MARK: Validations
    
    private func validateBudget() -> String? {
        
        if budget?.descriptionBudget == "" {
            return NSLocalizedString("DescriptionMandatoryError", comment: "")
        }
        else if budget?.categoryName == "" {
            return NSLocalizedString("CategoryMandatoryError", comment: "")
        }
        else if budget?.subCategoryName == "" {
            return NSLocalizedString("SubCategoryMandatoryError", comment: "")
        }
        else if budget?.name == "" {
            return NSLocalizedString("NameMandatoryError", comment: "")
        }
        else if budget?.email == "" {
            return NSLocalizedString("EmailMandatoryError", comment: "")
        }
        else if budget?.phoneNumber == "" {
            return NSLocalizedString("PhoneMandatoryError", comment: "")
        }
        else if budget?.locationName == "" {
            return NSLocalizedString("LocationMandatoryError", comment: "")
        }
        else if Validations.isValidEmail(budget?.email ?? "") == false {
            return NSLocalizedString("EmailFormatError", comment: "")
        }
        else if Validations.isValidPhoneNumber(budget?.phoneNumber ?? "") == false {
            return NSLocalizedString("PhoneFormatError", comment: "")
        }
        
        
        return nil
    }
    
    // MARK: - ViewModelProtocol
    
    func bindData() {
        
        //Description budget
        let descriptionTextField = delegate?.getField?(for: BudgetDetailFieldIdentifier.descriptionId.rawValue) as? UITextField
        descriptionTextField?.text = budget?.descriptionBudget
        
        //Category budget
        let categoryView = delegate?.getField?(for: BudgetDetailFieldIdentifier.categoryId.rawValue) as? DropdownField
        categoryView?.configure(title: budget?.categoryName ?? "")
       
        //SubCategory budget
        let subCategoryView = delegate?.getField?(for: BudgetDetailFieldIdentifier.subCategoryId.rawValue) as? DropdownField
        subCategoryView?.configure(title: budget?.subCategoryName ?? "")
        
        //Name budget
        let nameTextField = delegate?.getField?(for: BudgetDetailFieldIdentifier.nameId.rawValue) as? UITextField
        nameTextField?.text = budget?.name
        
        //Email budget
        let emailTextField = delegate?.getField?(for: BudgetDetailFieldIdentifier.emailId.rawValue) as? UITextField
        emailTextField?.text = budget?.email
        
        //Phone budget
        let phoneTextField = delegate?.getField?(for: BudgetDetailFieldIdentifier.phoneId.rawValue) as? UITextField
        phoneTextField?.text = budget?.phoneNumber
        
        //Location budget
        let locationView = delegate?.getField?(for: BudgetDetailFieldIdentifier.locationId.rawValue) as? LocationField
        locationView?.configure(title: budget?.locationName ?? "")
    }
    

}

// MARK: UITextFieldDelegate

extension BudgetDetailViewModel: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if let text = textField.text,
           let textRange = Range(range, in: text) {
            
           let updatedText = text.replacingCharacters(in: textRange,
                                                       with: string)
            let identifier = delegate?.getIdentifier?(for: textField)
            
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
                
                if Validations.isNumber(updatedText) == true {
                    budget?.phoneNumber = updatedText
                }
                
                return Validations.isNumber(updatedText)
            default:
                break
            }
        }
        return true
    }
}

// MARK: DropdownFieldDelegate

extension BudgetDetailViewModel: DropdownFieldDelegate {
    
    func selectedItem(_ item: DropdownField) {
        
        let dropdownFieldId = delegate?.getIdentifier?(for: item)
        
        switch dropdownFieldId {
        case BudgetDetailFieldIdentifier.categoryId.rawValue:
            budget?.categoryName = item.selectedItem?.name ?? ""
            budget?.categoryId = item.selectedItem?.id ?? ""
            budget?.subCategoryName = ""
            break
        case BudgetDetailFieldIdentifier.subCategoryId.rawValue:
            budget?.subCategoryName = item.selectedItem?.name ?? ""
            break
        default:
            break
        }

        bindData()
    }
    
    func loadDataSource(field: DropdownField,
                        success: @escaping ([PicklistItem]) -> ()) {
        
        switch field {
        
        case delegate?.getField?(for: BudgetDetailFieldIdentifier.categoryId.rawValue):
            NetworkManager.shared.GETListRequest(NetworkURL.CategoriesURL.rawValue, headers: nil, parameters: nil, model: Category.self) { (categories) in
                
                var picklistItems: [PicklistItem] = []
                
                for category in categories {
                    picklistItems.append(category.mapToPicklist())
                }
                
                success(picklistItems)
                
            } failure: { [unowned self] (error) in
                
                let acceptAction = UIAlertAction.init(title: NSLocalizedString("AcceptTitle", comment: ""), style: .default, handler: nil)
                
                delegate?.showAlert?(NSLocalizedString("AtentionTitle", comment: ""), message: error.localizedDescription, actions: [acceptAction])
            }
            
            break
            
        case delegate?.getField?(for: BudgetDetailFieldIdentifier.subCategoryId.rawValue):
            
            if budget?.categoryId == "" {
                
                let acceptAction = UIAlertAction.init(title: NSLocalizedString("AcceptTitle", comment: ""), style: .default, handler: nil)
                delegate?.showAlert?(NSLocalizedString("AtentionTitle", comment: ""), message: NSLocalizedString("CategoryEmptyError", comment: ""), actions: [acceptAction])
                
            }else {
                NetworkManager.shared.GETListRequest("\(NetworkURL.CategoriesURL.rawValue)\(budget?.categoryId ?? "")", headers: nil, parameters: nil, model: Category.self) { (subCategories) in
                    
                    var picklistItems: [PicklistItem] = []
                    
                    for subCategory in subCategories {
                        picklistItems.append(subCategory.mapToPicklist())
                    }
                    
                    success(picklistItems)
                    
                } failure: { [unowned self] (error) in
                    let acceptAction = UIAlertAction.init(title: NSLocalizedString("AcceptTitle", comment: ""), style: .default, handler: nil)
                    delegate?.showAlert?(NSLocalizedString("AtentionTitle", comment: ""), message: error.localizedDescription, actions: [acceptAction])
                }
            }
            
            break
        default:
            break
        }
    }
}

// MARK: LocationFieldDelegate

extension BudgetDetailViewModel: LocationFieldDelegate {

    func loadDataSource(field: LocationField, success: @escaping ([PicklistItem]) -> ()) {
        
        switch field {
        
        case delegate?.getField?(for: BudgetDetailFieldIdentifier.locationId.rawValue):
            NetworkManager.shared.GETListRequest(NetworkURL.LocationURL.rawValue, headers: nil, parameters: nil, model: Location.self) { (locations) in
                
                var picklistItems: [PicklistItem] = []
                
                for location in locations {
                    picklistItems.append(location.mapToPicklist())
                }
                
                success(picklistItems)
                
            } failure: { [unowned self] (error) in
                let acceptAction = UIAlertAction.init(title: NSLocalizedString("AcceptTitle", comment: ""), style: .default, handler: nil)
                delegate?.showAlert?(NSLocalizedString("AtentionTitle", comment: ""), message: error.localizedDescription, actions: [acceptAction])
            }
            
            break
        default:
            break
        }
        
    }
    
    func selectedItem(_ item: LocationField) {
        
        let locationFieldId = delegate?.getIdentifier?(for: item)
        
        switch locationFieldId {
        case BudgetDetailFieldIdentifier.locationId.rawValue:
            budget?.locationName = item.selectedItem?.value ?? ""
            break
        default:
            break
        }
        bindData()
    }

    

}
