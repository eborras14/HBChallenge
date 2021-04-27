//
//  Category.swift
//  HabitissimoChallenge
//
//  Created by Eduard Borras Ruiz on 26/4/21.
//

import UIKit
import ObjectMapper

class Category: Mappable {
    
    var id: String = ""
    var normalName: String = ""
    var parentId: String = ""
    var description: String = ""
    var name: String = ""
    
    
    required init?(map: Map) {
    }
    
    func mapping(map: Map) {
        
        id <- map["id"]
        normalName <- map["normalized_name"]
        parentId <- map["parent_id"]
        description <- map["description"]
        name <- map["name"]

    }
    

}
