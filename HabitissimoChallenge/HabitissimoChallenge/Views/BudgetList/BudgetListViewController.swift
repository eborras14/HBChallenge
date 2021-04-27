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
        
        configureNavBar()
        
        setupTableView()
                
    }
    
    private func setupTableView() {
        tableView.delegate = viewModel
        tableView.dataSource = viewModel
    }
    
    private func configureNavBar() {
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(newBudgetAction))
        self.title = NSLocalizedString("BudgetTitle", comment: "")

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




