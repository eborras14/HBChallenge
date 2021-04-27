//
//  BudgetController.swift
//  HabitissimoChallenge
//
//  Created by Eduard Borras Ruiz on 27/4/21.
//

import UIKit

class BudgetController: BaseController {
    
    override class func sharedInstance() -> Any! {
        return BudgetController.init(BudgetDao.sharedInstance() as? BudgetDao)
    }

}
