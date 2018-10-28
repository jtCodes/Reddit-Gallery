//
//  SubRedditDecode.swift
//  Reddit-Gallery
//
//  Created by J Tan on 10/27/18.
//  Copyright © 2018 J Tan. All rights reserved.
//

import Foundation

struct SubRedditDecode: Decodable {
    struct Root: Decodable {
        let data: RootData
    }
    
    struct RootData: Decodable {
        let children: [Child]
    }
    
    struct Child: Decodable {
        let data: Data
    }
    
    struct Data: Decodable {
        let title: String
        let thumbnail: String
        let url: String
        let is_video: Bool
    }
    
    struct Preview: Decodable {
        let images: [Image]
    }
    
    struct Image: Decodable {
        let source: Source
    }
    
    struct Source: Decodable {
        let width: Int
        let height: Int
    }
}
