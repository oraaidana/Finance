//
//  User.swift
//  finance
//
//  Created on 11/21/25.
//

import Foundation

struct User: Identifiable, Codable, Equatable {
    let id: String
    let email: String
    let name: String
    var isEmailVerified: Bool
    
    init(id: String, email: String, name: String, isEmailVerified: Bool = false) {
        self.id = id
        self.email = email
        self.name = name
        self.isEmailVerified = isEmailVerified
    }
}

