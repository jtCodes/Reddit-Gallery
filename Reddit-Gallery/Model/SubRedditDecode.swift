//
//  SubRedditDecode.swift
//  Reddit-Gallery
//
//  Created by J Tan on 10/27/18.
//  Copyright © 2018 J Tan. All rights reserved.
//

import Foundation

// Struct for easy json decoding

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
        let domain: String
        let thumbnail: String
        let post_hint: String?
        let preview: Preview?
        let media: Media?
        let url: String
        let is_video: Bool
    }
    
    struct Preview: Decodable {
        let images: [Image]?
        let reddit_video_preview: VideoPreview?
    }
    
    struct VideoPreview: Decodable {
        let scrubber_media_url : String
        let hls_url: String
    }
    
    struct Image: Decodable {
        let source: Source?
    }
    
    struct Source: Decodable {
        let width: Int
        let height: Int
    }
    
    struct Media: Decodable {
        let reddit_video: RedditVideo?
    }
    
    struct RedditVideo: Decodable {
        let scrubber_media_url : String
        let hls_url: String
    }
}
