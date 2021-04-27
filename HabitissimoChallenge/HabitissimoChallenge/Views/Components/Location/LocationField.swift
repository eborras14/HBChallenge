//
//  LocationField.swift
//  HabitissimoChallenge
//
//  Created by Eduard Borras Ruiz on 27/4/21.
//

import UIKit
import DropDown

protocol LocationFieldDelegate {
    func selectedItem(_ item: LocationField)
    func loadDataSource(field: LocationField,
                        success: @escaping (_ modelPicklist: [PicklistItem]) -> ())
}


@IBDesignable
class LocationField: UIView {
    
    // MARK: IBOutlets
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var removeBtnView: UIView!
    
    //MARK: Properties
    
    private let nibName = "LocationField"
    private var contentView: UIView?
    private var dropdown = DropDown()
    private var originalDataSource: [PicklistItem] = []

    
    var dataSource: [PicklistItem] = []
    var delegate: LocationFieldDelegate?
    var selectedItem: PicklistItem?
    
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
    
    private func commonInit() {
        guard let view = loadViewFromNib() else { return }
        view.frame = self.bounds
        self.addSubview(view)
        
        contentView = view
        removeBtnView.isHidden = true
        textField.delegate = self
        
        configureDropdown()
        dropdownAction()
    }
    
    private func configureDropdown() {
        dropdown.anchorView = self.contentView
        dropdown.bottomOffset = CGPoint(x: 0, y:(dropdown.anchorView?.plainView.bounds.height)!)
    }
    
    private func loadViewFromNib() -> UIView? {
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: nibName, bundle: bundle)
        return nib.instantiate(withOwner: self, options: nil).first as? UIView
    }
    
    // MARK: Configure methods
    
    func configure(title: String) {
        self.textField.text = title
        
        if title == "" {
            hideTrash()
        }
        else {
            showTrash()
        }
        
    }
    
    // MARK: IBActions
    
    private func dropdownAction() {
        self.dropdown.selectionAction = { [unowned self] (index: Int, item: String) in
            selectedItem = dataSource[index]
            delegate?.selectedItem(self)
            
            showTrash()
        }
    }
    
    @IBAction func removeAction(_ sender: Any) {
        selectedItem = nil
        delegate?.selectedItem(self)
        hideTrash()
    }
    
    
}

// MARK: Filter method

extension LocationField {
    
    func filterData(_ text: String) {
        
        dataSource = originalDataSource
        
        let filteredItems = dataSource.filter({
            return  $0.name.lowercased().contains(text.lowercased())
        })
        
        dataSource = filteredItems
        dropdown.dataSource = mapPicklistToStringList(filteredItems)
    }
    
}

// MARK: Utils methods

extension LocationField {
    
    private func mapPicklistToStringList(_ originalDataSource: [PicklistItem]) -> [String] {
        
        var dataSourceValues: [String] = []
        for item in originalDataSource {
            dataSourceValues.append(item.name)
        }
        
        return dataSourceValues
    }
    
    private func showTrash() {
        contentView?.endEditing(true)
        textField.isUserInteractionEnabled = false
        removeBtnView.isHidden = false
    }
    
    private func hideTrash() {
        textField.isUserInteractionEnabled = true
        removeBtnView.isHidden = true
    }
}

// MARK: UITextFieldDelegate

extension LocationField: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        delegate?.loadDataSource(field: self, success: {[unowned self] (picklistItems) in
            
            originalDataSource = picklistItems
            dataSource = picklistItems
            //TODO: Quitar el loading
            if dataSource.count > 0 {
                if textField.text?.count ?? 0 > 0 {
                    dropdown.dataSource = mapPicklistToStringList(dataSource)
                    dropdown.show()
                }
            }
        })
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if let text = textField.text,
           let textRange = Range(range, in: text) {
           let updatedText = text.replacingCharacters(in: textRange,  with: string)
            
            filterData(updatedText)
            
            if updatedText.count > 0 &&
                dropdown.dataSource.count > 0 {
                dropdown.show()
            }else {
                dropdown.hide()
            }
        }
        return true
    }
}
