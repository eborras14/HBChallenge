//
//  BudgetCell.swift
//  HabitissimoChallenge
//
//  Created by Eduard Borras Ruiz on 27/4/21.
//

import UIKit

class BudgetCell: UITableViewCell {

    // MARK: IBOutlets
    
    @IBOutlet weak var lblBudget: UILabel!
    
    // MARK: - Static properties
    
    static let identifier = String(describing: BudgetCell.self)
    
    static var nib: UINib {
        return UINib(nibName: identifier, bundle: nil)
    }
    
    static func getCellHeight() -> CGFloat {
        return 45.0
    }
    
    // MARK: LifeCycle methods
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    // MARK: Setup cell

    func configureCell(_ budget: Budget) {
        
        lblBudget.text = "\(budget.name) - \(budget.subCategoryName)"
        
    }
    
}
