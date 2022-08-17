//
//  ListitemEntity.swift
//  ShoppingApp
//
//  Created by Mert Şahin on 17.08.2022.
//

import Foundation


class ListItemEntity{
    var id : UUID
    var name : String
    
    
    init(id : UUID, name : String){
        self.id = id
        self.name = name
    }
}

