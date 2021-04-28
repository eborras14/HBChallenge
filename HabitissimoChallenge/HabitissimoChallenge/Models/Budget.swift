//
//  Budget.swift
//  HabitissimoChallenge
//
//  Created by Eduard Borras Ruiz on 23/4/21.
//

import UIKit

@objc(Budget) class Budget: AM8ORMEntity {
    
    @objc var descriptionBudget: String = ""
    @objc var categoryName: String = ""
    @objc var categoryId: String = ""
    @objc var subCategoryName: String = ""
    @objc var name: String = ""
    @objc var email: String = ""
    @objc var phoneNumber: String = ""
    @objc var locationName: String = ""

}
