//
//  ViewModelProtocol.swift
//  HabitissimoChallenge
//
//  Created by Eduard Borras Ruiz on 27/4/21.
//

import Foundation
import UIKit

@objc protocol ViewModelProtocol {
    @objc func bindData()
}

@objc protocol ViewModelUtilsProtocol {
    func getField(for identifier: Int) -> UIView?
    func getIdentifier(for field: UIView) -> Int
    @objc optional func showAlert(_ title: String, message: String, actions: [UIAlertAction])

}
