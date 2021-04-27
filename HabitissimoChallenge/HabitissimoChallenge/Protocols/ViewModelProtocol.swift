//
//  ViewModelProtocol.swift
//  HabitissimoChallenge
//
//  Created by Eduard Borras Ruiz on 27/4/21.
//

import Foundation
import UIKit

protocol ViewModelProtocol {
    func bindData()
}

protocol ViewModelFieldsProtocol {
    func getField(for identifier: Int) -> UIView?
    func getIdentifier(for field: UIView) -> Int
}
