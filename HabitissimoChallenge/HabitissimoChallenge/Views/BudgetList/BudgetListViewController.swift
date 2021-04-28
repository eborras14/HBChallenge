//
//  BudgetListViewController.swift
//  HabitissimoChallenge
//
//  Created by Eduard Borras Ruiz on 23/4/21.
//

import UIKit

class BudgetListViewController: UIViewController {
    
    // MARK: - Properties
    var viewModel: BudgetListViewModel = BudgetListViewModel()
    
    // MARK: - IBOutlets
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
}

// MARK: - SetupUI
extension BudgetListViewController {
    
    private func setupUI() {
        
        setupDelegates()
        
        configureNavBar()
        
        registerCells()
        
        setupTableView()
                
    }
    
    private func setupDelegates() {
        
        viewModel.delegate = self
        
    }
    
    private func setupTableView() {
        tableView.delegate = viewModel
        tableView.dataSource = viewModel
    }
    
    private func configureNavBar() {
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(newBudgetAction))
        self.title = NSLocalizedString("BudgetTitle", comment: "")
    }
    
    private func registerCells() {
        tableView.register(BudgetCell.nib, forCellReuseIdentifier: BudgetCell.identifier)
    }
}

// MARK: - Update methods

extension BudgetListViewController {
    
    func updateData() {
        viewModel.loadBudgetData()
        tableView.reloadData()
    }
    
}

// MARK: - Buttons Actions

extension BudgetListViewController {
    
    @objc private func newBudgetAction() {
        let budget = Budget()
        let budgetDetail = BudgetDetailViewController.init(budget)
        self.navigationController?.show(budgetDetail, sender: nil)
    }
    
}

extension BudgetListViewController: ViewModelUtilsProtocol {
    
    func showViewController(_ viewController: UIViewController) {
        self.navigationController?.show(viewController, sender: nil)
    }
    
    func showAlert(_ title: String, message: String, actions: [UIAlertAction]) {
        let alert = UIAlertController.init(title: title, message: message, preferredStyle: .alert)
        
        for action in actions {
            alert.addAction(action)
        }
        
        navigationController?.present(alert, animated: true, completion: nil)
    }
    
}




