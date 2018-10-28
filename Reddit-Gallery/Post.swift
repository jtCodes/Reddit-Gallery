//
//  Post.swift
//  Reddit-Gallery
//
//  Created by J Tan on 10/27/18.
//  Copyright © 2018 J Tan. All rights reserved.
//

import Foundation

struct Post {
    let title: String
    let thumbnail: String
    let url: String
    let is_video: Bool
    let maxThumb: String
    let fallBackThumb: String
    var availThumb: String
    let ytVideoId: String
    let isYt: Bool
}
