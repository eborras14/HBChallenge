//
//  DropdownField.swift
//  HabitissimoChallenge
//
//  Created by Eduard Borras Ruiz on 26/4/21.
//

import UIKit

@IBDesignable
class DropdownField: UIView {
    
    // MARK: IBOutlets
    @IBOutlet weak var titleLabel: UILabel!
    
    
    //MARK: Properties
    
    let nibName = "DropdownField"
    var contentView:UIView?
    
    //MARK: LifeCycle methods
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    // MARK: Setup UI
    
    func commonInit() {
        guard let view = loadViewFromNib() else { return }
        view.frame = self.bounds
        self.addSubview(view)
        contentView = view
    }
    
    func loadViewFromNib() -> UIView? {
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: nibName, bundle: bundle)
        return nib.instantiate(withOwner: self, options: nil).first as? UIView
    }
    
    // MARK: Configure methods
    
    func configure(title: String) {
        
        titleLabel.text = title
        
    }

}
