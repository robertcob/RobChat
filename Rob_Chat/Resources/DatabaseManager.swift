//
//  DatabaseManager.swift
//  Rob_Chat
//
//  Created by Robert O'Brien on 24/08/2020.
//  Copyright © 2020 Robert O'Brien. All rights reserved.
//

import Foundation
import FirebaseDatabase

// defining class as final so it cant have any sub-classes
final class DatabaseManager {
    
    static let shared = DatabaseManager()
    
    private let database = Database.database().reference()
    

    

}
//MARK: - Account Management
extension DatabaseManager {
    
    public func userExists(with email: String, completion: @escaping ((Bool) -> Void)){
        
        var safeEmail = email.replacingOccurrences(of: ".", with: "-")
        safeEmail = safeEmail.replacingOccurrences(of: "@", with: "-")

        database.child(safeEmail).observeSingleEvent(of: .value, with: { snapshot in
            guard  snapshot.value as? String != nil  else{
                completion(false)
                return
            }
            completion(true)
        })
    }
    
    /// Inserts new user into database
    //remember we are delimiting based on user email
    //therfore NO USER should have the same email
    public func insertUser(with user: ChatAppUser) {
        database.child(user.safeEmail).setValue([
            "first_name" : user.firstName,
            "last_name" : user.lastName
        ])
    }
    
}

struct ChatAppUser {
    let firstName: String
    let lastName: String
    let emailAddress: String
    // profile pic URl
    
    var safeEmail:String {
//      we cant use a raw email as a database delimiter, becuase of @ and . symbols
//      so We replace those small occurances in every email and insert the clean email
        var safeEmail = emailAddress.replacingOccurrences(of: ".", with: "-")
        safeEmail = safeEmail.replacingOccurrences(of: "@", with: "-")
        return safeEmail
        
    }
}

