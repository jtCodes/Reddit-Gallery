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
                                    availThumb: "", ytVideoId: videoID, isYt: videoID == "" ? false : true)
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

let whiteThemeDict = ["quote" : UIColor(red: 0.4706, green: 0.6, blue: 0.1333, alpha: 1.0),
                      "table" : UIColor.white, "cell" : UIColor.white, "com" : UIColor.black,
                      "name" : UIColor.green, "details" : UIColor.gray.withAlphaComponent(0.7),
                      "sub" : UIColor.black.withAlphaComponent(0.85)]

let darkThemeDict = ["navBar" : UIColor(red:0.16, green:0.16, blue:0.17, alpha:1.0),
                     "quote" : UIColor(red: 0.4706, green: 0.6, blue: 0.1333, alpha: 1.0),
                     "table" : UIColor(red:0.09, green:0.09, blue:0.10, alpha:1.0),
                     "cell" : UIColor(red:0.12, green:0.12, blue:0.13, alpha:1.0),
                     "com" : UIColor(red:0.73, green:0.73, blue:0.74, alpha:1.0),
                     "name" : UIColor(red:0.73, green:0.73, blue:0.74, alpha:1.0),
                     "details" : UIColor.gray.withAlphaComponent(0.7),
                     "sub" : UIColor(red:0.64, green:0.50, blue:0.68, alpha:1.0),
                     "seperator" : UIColor(red:0.21, green:0.24, blue:0.29, alpha:0.9),
                     "url" : UIColor(red:0.31, green:0.60, blue:0.91, alpha:1.0)]

let themeDict = darkThemeDict
