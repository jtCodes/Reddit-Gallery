//
//  Post.swift
//  Reddit-Gallery
//
//  Created by J Tan on 10/27/18.
//  Copyright © 2018 J Tan. All rights reserved.
//

import Foundation

enum PostHint: String {
    case image = "image"
    case rVideo = "rich:video"
    case hVideo = "hosted:video"
    case link = "link"
}

let ytDomains = ["youtu.be", "youtube.com"]

struct Post {
    let title: String
    let postHint: String?
    let thumbnail: String
    let url: String
    let isVideo: Bool
    let maxThumb: String
    let fallBackThumb: String
    var availThumb: String
    let ytVideoId: String
    let isYt: Bool
    let isRedditPreviewVideo: Bool
    let redditPreviewUrl: String?
}

