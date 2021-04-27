//
//  BudgetDao.swift
//  HabitissimoChallenge
//
//  Created by Eduard Borras Ruiz on 27/4/21.
//

import UIKit

class BudgetDao: BaseDao {
    
    override class func sharedInstance() -> Any! {
        return BudgetDao(Budget.self)
    }

}
