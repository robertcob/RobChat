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
    
    static func safeEmail(emailAddress:String) -> String {
        var safeEmail = emailAddress.replacingOccurrences(of: ".", with: "-")
        safeEmail = safeEmail.replacingOccurrences(of: "@", with: "-")
        return safeEmail
    }
    

    

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
    public func insertUser(with user: ChatAppUser, completion: @escaping (Bool) -> Void) {
        database.child(user.safeEmail).setValue([
            "first_name" : user.firstName,
            "last_name" : user.lastName
            ], withCompletionBlock: {error, _ in
                guard error == nil else {
                    print("Failed to write to database")
                    completion(false)
                    return
                }
                
                self.database.child("users").observeSingleEvent(of: .value, with: {snapshot in
                    if var usersCollection = snapshot.value as? [[String: String]] {
                        //append to user dictionary
                        let newElement = [
                            "name":user.firstName + " " + user.lastName,
                            "email": user.safeEmail
                        ]
                        usersCollection.append(newElement)
                        
                        self.database.child("users").setValue(usersCollection, withCompletionBlock: { error, _ in
                            guard error == nil else {
                                completion(false)
                                return
                            }
                            
                            completion(true)
                        })
                        
                        
                    }
                        
                    else {
                        //create the array
                        let newCollection: [[String: String]] = [
                            [
                                "name":user.firstName + " " + user.lastName,
                                "email": user.safeEmail
                                
                            ]
                        ]
                        self.database.child("users").setValue(newCollection, withCompletionBlock: { error, _ in
                            guard error == nil else {
                                completion(false)
                                return
                            }
                            
                            completion(true)
                        })
                        
                    }
                })
        } )
    }
    
    public func getAllUsers(completion: @escaping (Result<[[String: String]], Error>) -> Void) {
        
        database.child("users").observeSingleEvent(of: .value, with: { snapshot in
            guard let value = snapshot.value as? [[String: String]] else {
                
                completion(.failure(DatabaseError.failedToFetch))
                return
            }
            
            completion(.success(value))
        })
    }
    public enum DatabaseError: Error {
        case failedToFetch
    }
    
}


/*
 users => [
    [
        "name":
        "safe_email"
    ],
    [
        "name":
        "safe_email"
    ]
]
 
 
 */

// MARK: -Sending messages/ conversations
extension DatabaseManager {
    
    /*
     
     
     "rootId" {
     
        "messages": [
     
            {
                    "id", String
                    "type": text, photo video,
                    "content": String,
                    "date" :Date()
                    "sender_email" : String,
                    'idRead": true/false (bool)
     
            }
     
        ]
     }
     
        conversation => [
     
            [
                "conversation_id":
                "other_user_email":
                "latest_mesage": => {
                    "date": Date()
                    "latest_message": "message"
                    "is_read" : true/false
                }
     
            ],
        ]
     */
    
    /// create a new convo with target user email and first message sent
    public func createNewConversation(with otherUserEmail: String, firstMessage: Message, completion: @escaping (Bool) -> Void) {
        guard let currentEmail = UserDefaults.standard.value(forKey: "email") as? String else {
            return
        }
        
        let safeEmail = DatabaseManager.safeEmail(emailAddress: currentEmail)
        let ref = database.child("\(safeEmail)")
        
        ref.observeSingleEvent(of: .value, with: { snapshot in
            guard var userNode = snapshot.value as? [String: Any] else {
                completion(false)
                print("User not found!")
                return
            }
            let messageDate = firstMessage.sentDate
            let dateString = ChatViewController.dateFormatter.string(from: messageDate)
            
            
            var message = ""
            switch firstMessage.kind {
            
            case .text(let messageText):
                message = messageText
            case .attributedText(_):
            
                break
            case .photo(_):
                
                break
            case .video(_):
                
                break
            case .location(_):
                
                break
            case .emoji(_):
                
                break
            case .audio(_):
                
                break
            case .contact(_):
                
                break
            case .linkPreview(_):
                
                break
            case .custom(_):
                
                break
            }
            let conversationID = "conversation_\(firstMessage.messageId)"
            let newConversationData: [String: Any] = [
                "id": conversationID ,
                "other_User_Email": otherUserEmail,
                "latest_Message": [
                    "date": dateString,
                    "message": message,
                    "is_Read": false
                    ]
            ]
            
            if var conversations = userNode["conversations"] as? [[String: Any]]{
                //convo array exists for current user
                //append
                
                conversations.append(newConversationData)
                userNode["conversations"] = conversations
                ref.setValue(userNode, withCompletionBlock: {[weak self] error, _ in
                    guard error == nil else {
                        completion(false)
                        return
                    }
                    self?.finishCreatingConversation(conversationID: conversationID, firstMessage: firstMessage, completion: completion)
                })
            }
            else {
                
                //conversation array does not exist create it
                //create
                
                userNode["conversations"] = [
                    newConversationData
                ]
                
                ref.setValue(userNode, withCompletionBlock: { [weak self] error, _ in
                    guard error == nil else {
                        completion(false)
                        return
                    }
                    
                    self?.finishCreatingConversation(conversationID: conversationID, firstMessage: firstMessage, completion: completion)
    
                })
                
                
                
            }
        })
        
    }
    
    private func finishCreatingConversation(conversationID: String, firstMessage: Message, completion: @escaping (Bool) -> Void) {
//    {
//        "id": String,
//        "type": text, photo, video,
//        "content", String,
//        "date": Date(),
//        "sender_email": String,
//        "isRead": true/false,
//        }
//
        
        var message = ""
        switch firstMessage.kind {
            
        case .text(let messageText):
            message = messageText
        case .attributedText(_):
            
            break
        case .photo(_):
            
            break
        case .video(_):
            
            break
        case .location(_):
            
            break
        case .emoji(_):
            
            break
        case .audio(_):
            
            break
        case .contact(_):
            
            break
        case .linkPreview(_):
            
            break
        case .custom(_):
            
            break
        }
        
        let messageDate = firstMessage.sentDate
        let dateString = ChatViewController.dateFormatter.string(from: messageDate)
        
        guard let myEmail = UserDefaults.standard.value(forKey: "email") as? String else {
            completion(false)
            return
        }
        let currentUserEmail = DatabaseManager.safeEmail(emailAddress: myEmail)
        
        let collectionMessage: [String: Any] = [
            "id": firstMessage.messageId,
            "type": firstMessage.kind.messageKindString,
            "content": message,
            "date": dateString,
            "sender_email": currentUserEmail,
            "is_read": false
            
        ]
        let value : [String: Any] = [
            "messages": [
                collectionMessage
            ]
        ]
        print("adding convo: \(conversationID)")
        database.child("\(conversationID)").setValue(value, withCompletionBlock: { error, _ in
            guard error == nil else {
                completion(false)
                return
            }
            completion(true)
        })
    }
    
    /// fetches and returns all convos for the user with passed in email
    public func getAllConversations(for email: String, completion: @escaping (Result<String, Error>) -> Void) {
        
    }
    
    /// getsall messages for a given conversation
    public func getAllMessagesForConversation(with id: String, completion: @escaping (Result<String, Error>) -> Void)
    {
        
    }
    
    /// sends a message with target conversation and message
    public func sendMessage(to conversation: String, message: Message, completion: @escaping (Bool) -> Void) {
        
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
    
    var profilePictureFileName: String {
      //  /images/name-gmail-com_profile_picture.png
        return "\(safeEmail)_profile_picture.png"
    }
}

