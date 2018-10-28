//
//  RedditApi.swift
//  Reddit-Gallery
//
//  Created by J Tan on 10/27/18.
//  Copyright © 2018 J Tan. All rights reserved.
//

import Foundation
import Alamofire

func fetchPosts(url: String, completion: @escaping (_ success: [Any]) -> Void) {
    var posts = [Post]()
    
    Alamofire.request(reqUrl).responseJSON { response in
        if let data = response.data {
            if let decodedSubRedditData = try? JSONDecoder().decode(SubRedditDecode.Root.self,from: data) {
                for postData in decodedSubRedditData.data.children {
                    let videoID = postData.data.url.youtubeID ?? ""
                    let post = Post(title: postData.data.title,
                                    thumbnail: postData.data.thumbnail,
                                    url: postData.data.url,
                                    is_video: postData.data.is_video,
                                    maxThumb: "http://img.youtube.com/vi/" + videoID + "/maxresdefault.jpg",
                                    fallBackThumb: "http://img.youtube.com/vi/" + videoID + "/sddefault.jpg",
                                    availThumb: "", ytVideoId: videoID)
                    if videoID != "" {
                        posts.append(post)
                    }
                }
                completion([posts])
            }
        }
    }
}

func verifyURL(urlPath: String, completion: @escaping (_ isOK: Bool)->()) {
    if let url = URL(string: urlPath) {
        var request = URLRequest(url: url)
        request.httpMethod = "HEAD"
        let task = URLSession.shared.dataTask(with: request, completionHandler: { (data, response, error) in
            if let httpResponse = response as? HTTPURLResponse, error == nil {
                completion(httpResponse.statusCode == 200)
            } else {
                completion(false)
            }
        })
        task.resume()
    } else {
        completion(false)
    }
}

extension String {
    var youtubeID: String? {
        let pattern = "((?<=(v|V)/)|(?<=be/)|(?<=(\\?|\\&)v=)|(?<=embed/))([\\w-]++)"
        
        let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive)
        let range = NSRange(location: 0, length: count)
        
        guard let result = regex?.firstMatch(in: self, range: range) else {
            return nil
        }
        
        return (self as NSString).substring(with: result.range)
    }
}
