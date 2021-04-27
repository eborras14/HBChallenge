//
//  Location.swift
//  HabitissimoChallenge
//
//  Created by Eduard Borras Ruiz on 27/4/21.
//

import UIKit
import ObjectMapper

class Location: Mappable {

    var name: String = ""
    var zip: String = ""
    
    
    required init?(map: Map) {
    }
    
    func mapping(map: Map) {
        
        name <- map["name"]
        zip <- map["zip"]

    }
    
    func mapToPicklist() -> PicklistItem {
        let picklistItem = PicklistItem()
        picklistItem.name = "\(name) - \(zip)"
        picklistItem.value = name
        
        return picklistItem
    }
    
}
