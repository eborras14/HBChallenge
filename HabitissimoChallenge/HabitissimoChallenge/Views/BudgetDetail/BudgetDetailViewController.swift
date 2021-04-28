//
//  BudgetDetailViewController.swift
//  HabitissimoChallenge
//
//  Created by Eduard Borras Ruiz on 26/4/21.
//

import UIKit

enum BudgetDetailFieldIdentifier: Int {
    case descriptionId = 0
    case categoryId = 1
    case subCategoryId = 2
    case nameId = 3
    case emailId = 4
    case phoneId = 5
    case locationId = 6
    case unknownId = -1
}

class BudgetDetailViewController: UIViewController {
    
    // MARK: IBOutlets
    
    @IBOutlet weak var lblDescriptonTitle: UILabel!
    @IBOutlet weak var lblCategoryTitle: UILabel!
    @IBOutlet weak var lblSubCategoryTitle: UILabel!
    @IBOutlet weak var lblNameTitle: UILabel!
    @IBOutlet weak var lblEmailTitle: UILabel!
    @IBOutlet weak var lblLocationTitle: UILabel!
    @IBOutlet weak var lblPhoneTitle: UILabel!
    
    @IBOutlet weak var txtDescription: UITextField!
    @IBOutlet weak var categoryDropdownFieldView: DropdownField!
    @IBOutlet weak var subCategoryDrodownFieldView: DropdownField!
    @IBOutlet weak var txtName: UITextField!
    @IBOutlet weak var txtEmail: UITextField!
    @IBOutlet weak var txtPhone: UITextField!
    @IBOutlet weak var locationField: LocationField!
    
    // MARK: Properties
    
    private var viewModel: BudgetDetailViewModel?
    
    // MARK: LifeCycle methods
    
    init(_ budget: Budget) {
        super.init(nibName: "BudgetDetailViewController", bundle: nil)
        viewModel = BudgetDetailViewModel.init(budget)
        viewModel?.delegate = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
    }

}

// MARK: Setup UI

extension BudgetDetailViewController {
    
    private func setupUI() {
        
        setupTitles()
        
        setupDelegates()
        
        bindDataToView()
        
        addSaveBtn()
        
    }
    
    private func setupTitles() {
        lblDescriptonTitle.text = NSLocalizedString("DescriptionTitle", comment: "")
        lblCategoryTitle.text = NSLocalizedString("CategoryTitle", comment: "")
        lblSubCategoryTitle.text = NSLocalizedString("SubCategoryTitle", comment: "")
        lblNameTitle.text = NSLocalizedString("NameTitle", comment: "")
        lblEmailTitle.text = NSLocalizedString("EmailTitle", comment: "")
        lblLocationTitle.text = NSLocalizedString("LocationTitle", comment: "")
        lblPhoneTitle.text = NSLocalizedString("PhoneTitle", comment: "")
    }
    
    private func setupDelegates() {
        if let viewModel = viewModel {
            txtDescription.delegate = viewModel
            txtName.delegate = viewModel
            txtEmail.delegate = viewModel
            txtPhone.delegate = viewModel
            categoryDropdownFieldView.delegate = viewModel
            subCategoryDrodownFieldView.delegate = viewModel
            locationField.delegate = viewModel
        }
    }
    
    private func bindDataToView() {
        viewModel?.bindData()
    }
    
    private func addSaveBtn() {
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(saveAction))
    }
    
    // MARK: Util methods
    
    private func getViewController(_ type: UIViewController.Type) -> UIViewController? {
        
        let viewControllers = navigationController?.viewControllers ?? []
        
        for viewController in viewControllers {
            if viewController.isKind(of: type) {
                return viewController
            }
        }

       return nil
    }
    
}

// MARK: - ViewModelFieldsProtocol

extension BudgetDetailViewController: ViewModelUtilsProtocol {
    
    func getField(for identifier: Int) -> UIView? {
        
        switch identifier {
        case BudgetDetailFieldIdentifier.descriptionId.rawValue:
            return txtDescription
        case BudgetDetailFieldIdentifier.categoryId.rawValue:
            return categoryDropdownFieldView
        case BudgetDetailFieldIdentifier.subCategoryId.rawValue:
            return subCategoryDrodownFieldView
        case BudgetDetailFieldIdentifier.nameId.rawValue:
            return txtName
        case BudgetDetailFieldIdentifier.emailId.rawValue:
            return txtEmail
        case BudgetDetailFieldIdentifier.phoneId.rawValue:
            return txtPhone
        case BudgetDetailFieldIdentifier.locationId.rawValue:
            return locationField
        default:
            return nil
        }
        
    }
    
    func getIdentifier(for field: UIView) -> Int {
        switch field {
        case txtDescription:
            return BudgetDetailFieldIdentifier.descriptionId.rawValue
        case categoryDropdownFieldView :
            return BudgetDetailFieldIdentifier.categoryId.rawValue
        case subCategoryDrodownFieldView:
            return BudgetDetailFieldIdentifier.subCategoryId.rawValue
        case txtName:
            return BudgetDetailFieldIdentifier.nameId.rawValue
        case txtEmail:
            return BudgetDetailFieldIdentifier.emailId.rawValue
        case txtPhone:
            return BudgetDetailFieldIdentifier.phoneId.rawValue
        case locationField:
            return BudgetDetailFieldIdentifier.locationId.rawValue
        default:
            return BudgetDetailFieldIdentifier.unknownId.rawValue
        }
    }
    
    func showAlert(_ title: String, message: String, actions: [UIAlertAction]) {
        let alert = UIAlertController.init(title: title, message: message, preferredStyle: .alert)
        
        for action in actions {
            alert.addAction(action)
        }
        
        navigationController?.present(alert, animated: true, completion: nil)
    }
    
    func hideKeyboard() {
        self.view.endEditing(true)
    }
    
    
}

// MARK: - Buttons Actions

extension BudgetDetailViewController {
    
    @objc private func saveAction() {
        viewModel?.saveAction()
        navigationController?.popViewController(animated: true)
        
        let budgetListViewController = getViewController(BudgetListViewController.self) as? BudgetListViewController
        
        if let budgetListViewController = budgetListViewController {
            budgetListViewController.updateData()
        }
        
    }
    
}
