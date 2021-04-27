//
//  BudgetListViewModel.swift
//  HabitissimoChallenge
//
//  Created by Eduard Borras Ruiz on 23/4/21.
//

import UIKit

class BudgetListViewModel: NSObject {
    
    // MARK: - Get functions
    
    private func getBudgetData() -> [Any] {
        return []
    }

}

// MARK - UITableViewDelegate & UITableViewDataSource

extension BudgetListViewModel: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        getBudgetData().count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return UITableViewCell()
    }
    
    
}
