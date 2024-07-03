//
//  Flower.swift
//  CombineDemo
//
//  Created by hut on 2024/7/2.
//

import Foundation

struct Flower: Hashable, Codable {
    var id: Int = 0
    
    var name: String = "Jasmine-default"
    var icon: String = "Jasmine"
    
    var des: String = ""
    
    init(id: Int) {
        self.id = id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: Flower, rhs: Flower) -> Bool {
        return lhs.id == rhs.id
    }
    
}
