//
//  BudgetListViewModel.swift
//  HabitissimoChallenge
//
//  Created by Eduard Borras Ruiz on 23/4/21.
//

import UIKit

class BudgetListViewModel: NSObject {
    
    // MARK: Properties
    
    private var datasource: [Budget] = []
    var delegate: ViewModelUtilsProtocol?
    
    
    // MARK: - Get functions
    
    func loadBudgetData() {
        datasource = (BudgetController.sharedInstance() as? BudgetController)?.findAll() as? [Budget] ?? []
    }
    
    // MARK: - Constructor
    
    override init() {
        super.init()
        loadBudgetData()
    }

}

// MARK - UITableViewDelegate & UITableViewDataSource

extension BudgetListViewModel: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        datasource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: BudgetCell.identifier) as? BudgetCell ?? BudgetCell()

        cell.configureCell(datasource[indexPath.row])
        cell.selectionStyle = .none
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return BudgetCell.getCellHeight()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let budget = datasource[indexPath.row].mutableCopy() as? Budget
        
        if let budget = budget {
            let budgetDetail = BudgetDetailViewController.init(budget)
            delegate?.showViewController?(budgetDetail)
        }

    }
    
    
}
