//
//  LoginTableViewModels.swift
//  MessagingApp
//
//  Created by Seun Olalekan on 2021-10-13.
//

import Foundation

struct LoginTableViewRows {
    
    var title : String
    var kind : LoginTableViewKind
    var completion : (()->Void)?

    
}

enum LoginTableViewKind {
    
    case logout
    case info
    
}
