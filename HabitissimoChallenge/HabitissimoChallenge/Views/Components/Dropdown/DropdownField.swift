//
//  DropdownField.swift
//  HabitissimoChallenge
//
//  Created by Eduard Borras Ruiz on 26/4/21.
//

import UIKit
import DropDown

protocol DropdownFieldDelegate {
    func selectedItem(_ item: DropdownField)
    func loadDataSource(field: DropdownField,
                        success: @escaping (_ modelList: [PicklistItem]) -> ())
}

@IBDesignable
class DropdownField: UIView {
    
    // MARK: IBOutlets
    @IBOutlet weak var titleLabel: UILabel!
    
    
    //MARK: Properties
    
    private let nibName = "DropdownField"
    private var contentView: UIView?
    var delegate: DropdownFieldDelegate?
    var selectedItem: PicklistItem?
    private var dataSource: [PicklistItem] = []
    
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
        let gesture = UITapGestureRecognizer(target: self, action:  #selector(self.clickAction))
        self.contentView?.addGestureRecognizer(gesture)
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
    
    // MARK: Actions
    
    @objc func clickAction(sender : UITapGestureRecognizer) {
        //TODO: Poner el loading
        delegate?.loadDataSource(field: self, success: { (items) in
            
            self.dataSource = items
            //TODO: Quitar el loading
            if self.dataSource.count > 0 {
                let dropDown = DropDown()
                dropDown.anchorView = self.contentView // UIView or UIBarButtonItem
                dropDown.bottomOffset = CGPoint(x: 0, y:(dropDown.anchorView?.plainView.bounds.height)!)

                var dataSourceValues: [String] = []
                for item in self.dataSource {
                    dataSourceValues.append(item.name)
                }
                
                dropDown.dataSource = dataSourceValues
                dropDown.show()
                
                dropDown.selectionAction = { [unowned self] (index: Int, item: String) in
                    self.selectedItem = self.dataSource[index]
                    self.delegate?.selectedItem(self)
                }
            }
        })
        


    }

}
