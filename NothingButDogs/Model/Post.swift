//
//  Post.swift
//  NothingButDogs
//
//  Created by Naoki Muroya on 2019/01/31.
//  Copyright © 2019 thatnaoki. All rights reserved.
//

import Foundation

class Post {
    
    var userId: String?
    var userName: String?
    var postImageURL: String?
    var createdAt: String?
    var documentId: String?
    var numberOfLike: Int?
    
    init(userId: String?, userName: String?, postImageURL: String?, createdAt: String?, documentId: String?, numberOfLike: Int?) {
        
        self.userId = userId
        self.userName = userName
        self.postImageURL = postImageURL
        self.documentId = documentId
        self.numberOfLike = numberOfLike
        
    }
    
}
