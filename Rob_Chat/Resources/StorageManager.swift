//
//  StorageManager.swift
//  Rob_Chat
//
//  Created by Robert O'Brien on 31/08/2020.
//  Copyright © 2020 Robert O'Brien. All rights reserved.
//

import Foundation
import FirebaseStorage

final class StorageManager {
    
    static let shared = StorageManager()
    
    private let storage = Storage.storage().reference()
    
    /*
     /images/name-gmail-com_profile_picture.png
     */
    
    public typealias UploadPictureCompletion = (Result<String, Error>) -> Void
    
    /// Uploads picture to firebase storage and returns completion with url string to download
    public func uploadProfilePic(with data: Data, fileName: String, completion: @escaping  UploadPictureCompletion) {
        
        storage.child("images/\(fileName)").putData(data, metadata: nil, completion: {metadata, error in
            
            guard error == nil else {
                //failed
                print("failed to upload data to firebase for picture")
                completion(.failure(StorageError.failedToUpload))
                return
            }
            
            self.storage.child("images/\(fileName)").downloadURL(completion: {url, error in
                
                guard let url = url else {
                    print("")
                    completion(.failure(StorageError.failedToGetDownloadUrl))
                    return
                }
                
                let urlString = url.absoluteString
                print("dowload url returned: \(urlString)")
                completion(.success(urlString))
            })
            
            
        })
        
        
    }
    
    public enum StorageError: Error {
        case failedToUpload
        case failedToGetDownloadUrl
    }
    
    public func downloadURL(for path: String,  completion: @escaping (Result<URL, Error>) -> Void) {
        let reference = storage.child(path)
        
        reference.downloadURL(completion: {
            url, error in
            guard let url = url, error == nil else{
                completion(.failure(StorageError.failedToGetDownloadUrl))
                return
                
            }
            
            completion(.success(url))
        })
        
        
    }
}


