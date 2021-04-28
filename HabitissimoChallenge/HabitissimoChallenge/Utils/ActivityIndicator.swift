//
//  ActivityIndicator.swift
//  HabitissimoChallenge
//
//  Created by Eduard Borras Ruiz on 28/4/21.
//

import Foundation

class ActivityIndicator {
    
    static func showActivity() {
        guard let view = UIApplication.shared.windows.first!.rootViewController?.view else { return }
        guard let loading = DejalActivityView(for: view) else { return }
        let alphaView: UIView = UIView(frame: view.frame)
        alphaView.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.2)
        alphaView.tag = 1311
        view.addSubview(alphaView)
        view.addSubview(loading)
    }
    
    static func hideActitvity() {
        let view = UIApplication.shared.windows.first!.rootViewController?.view
        view?.viewWithTag(1311)?.removeFromSuperview()
        DejalActivityView.remove()
    }
    
}
